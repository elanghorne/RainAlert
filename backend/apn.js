const http2 = require('http2')
const jwt = require('jsonwebtoken')
const fs = require('fs')
require('dotenv').config()

function generateAPNToken() {
    const privateKey = fs.readFileSync(process.env.APN_KEY_PATH)
    return jwt.sign(
        { iss: process.env.APN_TEAM_ID },
        privateKey,
        {
            algorithm: 'ES256',
            keyid: process.env.APN_KEY_ID,
            expiresIn: '1h'
        }
    )
}

function sendAPNRequest(notificationString, deviceToken) {
    return new Promise((resolve, reject) => {
        const token = generateAPNToken()
        const bundleId = process.env.BUNDLE_ID

        const client = http2.connect('https://api.push.apple.com')

        const payload = JSON.stringify({
            aps: {
                alert: {
                    title: 'RainAlert',
                    body: notificationString
                },
                sound: 'default'
            }
        })

        const req = client.request({
            ':method': 'POST',
            ':path': `/3/device/${deviceToken}`,
            'authorization': `bearer ${token}`,
            'apns-topic': bundleId,
            'apns-push-type': 'alert',
            'content-type': 'application/json',
            'content-length': Buffer.byteLength(payload)
        })

        req.write(payload)
        req.end()

        req.on('response', (headers) => {
            const status = headers[':status']
            if (status === 200) {
                console.log(`APN sent to ${deviceToken}`)
                client.close()
                resolve()
            } else {
                let data = ''
                req.on('data', chunk => data += chunk)
                req.on('end', () => {
                    console.error('APN failed:', status, data)
                    client.close()
                    reject(new Error(`APN failed: ${status} ${data}`))
                })
            }
        })

        req.on('error', (err) => { client.close(); reject(err) })
        client.on('error', (err) => { client.close(); reject(err) })
    })
}

module.exports = { sendAPNRequest }

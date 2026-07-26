const db = require('./database')

const isTimeForRainCheck = true

function getDeviceArray() {
    return new Promise((resolve, reject) => {
        db.all("SELECT * FROM devices", [], function(err, rows) {
            if (err) {
                console.error(err)
                return reject(err)
            }
            resolve(rows)
        })
    })
}

function getDeviceTimeWindows(device) {
    return new Promise((resolve, reject) => {
        db.all(`
            SELECT *
            FROM time_windows
            WHERE device_token = ?
            `,
            [device.device_token],
            function(err, rows) {
                if (err) {
                    console.error(err)
                    return reject(err)
                }
                resolve(rows)
            })
    })
}

function getDeviceDailyForecast(device) {
    return new Promise((resolve, reject) => {
        db.get(`
            SELECT *
            FROM daily_forecasts
            WHERE device_token = ?
            `,
            [device.device_token],
            function(err, rows) {
                if (err) {
                    console.error(err)
                    return reject(err)
                }
                resolve(rows)
            })
    })
}

function getDeviceLocations(device) {
    return new Promise((resolve, reject) => {
        db.all(`
            SELECT *
            FROM locations
            WHERE device_token = ?
            `,
            [device.device_token],
            function(err, rows) {
                if (err) {
                    console.error(err)
                    return reject(err)
                }
                resolve(rows)
            })
    })
}

function isForecastTime(currentTime, dailyForecast) {
    // check if time matches forecast notification time
    return true
}

async function inActiveTimeWindow(device, currentTime) {
    const timeWindows = await getDeviceTimeWindows(device)
    console.log(timeWindows)
    // check if current time falls within user window
    return true
}

async function sendForecast(device, dailyForecast) {
    const locations = await getDeviceLocations(device)
    console.log(locations)

    if (dailyForecast.include_current_location) {
        const currentLocation = { device_token: device.device_token, location_id: null, latitude: device.current_latitude, longitude: device.current_longitude, name: "current location" }
        locations.push(currentLocation)
    }

    // send weather requests for daily forecasts per location

    // parse weather data per location

    // build string based on weather results

    // send apn request
}

function checkForImminentRain(latitude, longitude) {
    // sends weather request for minutely data

    // returns how many minutes until rain (integer), intensity of rain (string). null if no rain in next *20* minutes
}

function sendRainAlert(rainData, deviceToken) {
    // build apn request based on rainData

    // send apn request
}

async function runScheduler() {
    const devices = await getDeviceArray()
    console.log(devices)

    const currentTime = "someTime"

    for (let i = 0; i < devices.length; i++) {
        const dailyForecast = await getDeviceDailyForecast(devices[i])
        console.log(dailyForecast)

        if (isForecastTime(currentTime, dailyForecast)) {
            await sendForecast(devices[i], dailyForecast)
        }

        if (isTimeForRainCheck && devices[i].alerts_on && inActiveTimeWindow(devices[i]), currentTime) {
            // for now, rain checks are only for current location

            const rainData = checkForImminentRain(devices[i].current_latitude, devices[i].current_longitude)

            if (rainData) {
                sendRainAlert(rainData, devices[i].device_token)
            }

        }
    }
}

// wake at each minute mark
runScheduler()
// sleep
const { error } = require('node:console')
const db = require('./database')
const express = require('express')
const app = express()

app.use(express.json())

// for uptime robot
app.get('/health', (req, res) => {
    res.sendStatus(200)
})

app.post('/device', async (req, res) => {
    const deviceData = req.body
    if (deviceData == null) {
        return res.sendStatus(400)
    }

    return res.sendStatus(await handleDeviceData(deviceData))
    
})

app.post('/schedule', async (req, res) => {
    const deviceData = req.body
    if (deviceData == null) {
        return res.sendStatus(400)
    }

    return res.sendStatus(await handleScheduleData(deviceData))
    
})

app.post('/location', async (req, res) => {
    const deviceData = req.body
    if (deviceData == null) {
        return res.sendStatus(400)
    }

    return res.sendStatus(await handleLocationData(deviceData))
    
})

app.post('/forecast', async (req, res) => {
    const deviceData = req.body
    if (deviceData == null) {
        return res.sendStatus(400)
    }

    return res.sendStatus(await handleForecastData(deviceData))
    
})

function handleDeviceData(deviceData)  {
    return new Promise((resolve, reject) => {
        db.run(`
            INSERT INTO devices VALUES (?, ?, ?, ?)
            ON CONFLICT(device_token) DO UPDATE SET
                current_latitude = excluded.current_latitude,
                current_longitude = excluded.current_longitude,
                alerts_on = excluded.alerts_on
            `, 
            [
                deviceData.deviceToken,
                deviceData.currentLatitude,
                deviceData.currentLongitude,
                deviceData.alertsOn
            ], 
            (err) => {
                if (err) {
                    console.error(err)
                    return reject(500)
                }
                console.log("Updated 'devices' table.")
                return resolve(200)
            })
    })
}

function handleScheduleData(scheduleData)  {
    return new Promise ((resolve, reject) => {
        db.serialize(() => {
            db.run("DELETE FROM time_windows WHERE device_token = ?", [scheduleData.deviceToken])

            for (let i = 0; i < scheduleData.data.length; i++) {
                db.run("INSERT INTO time_windows VALUES (?, ?, ?, ?)",
                    [
                        scheduleData.deviceToken,
                        scheduleData.data[i].id,
                        scheduleData.data[i].startTime,
                        scheduleData.data[i].endTime
                    ],
                    (err) => {
                        if (err) {
                            console.error(err)
                            return reject(500)
                        }
                        console.log("Updated 'time_windows' table")
                        return resolve(200)
                    })
            }
        })
    })
}

function handleLocationData(locationData)  {
    return new Promise ((resolve, reject) => {
        db.serialize(() => {
            db.run("DELETE FROM locations WHERE device_token = ?", [locationData.deviceToken])
            
            let errorOccurred = false
            for (let i = 0; i < locationData.data.length; i++) {
                db.run("INSERT INTO locations VALUES (?, ?, ?, ?, ?)",
                    [
                        locationData.deviceToken,
                        locationData.data[i].id,
                        locationData.data[i].latitude,
                        locationData.data[i].longitude,
                        locationData.data[i].name
                    ],
                    (err) => {
                        if (err) {
                            console.error(err)
                            errorOccurred = true
                        }
                        console.log("Updated 'locations' table")
                        
                        if (i === locationData.data.length - 1) {
                            if (errorOccurred) {
                                return reject(500)
                            }
                            return resolve(200)
                        }})
                    }
            })
                       
        })
    }
    
function handleForecastData(forecastData)  {
    return new Promise ((resolve, reject) => {
        db.run(`
        INSERT INTO daily_forecasts VALUES (?, ?, ?, ?)
        ON CONFLICT(device_token) DO UPDATE SET
            forecast_time = excluded.forecast_time,
            include_current_location = excluded.include_current_location,
            include_significant_locations = excluded.include_significant_locations
        `, 
        [
            forecastData.deviceToken,
            forecastData.forecastData.forecastTime,
            forecastData.forecastData.includeCurrentLocation,
            forecastData.forecastData.includeSignificantLocations
        ], 
        (err) => {
            if (err) {
                console.error(err)
                return reject(500)
            }
            console.log("Updated 'daily_forecasts' table.")
            return resolve(200)
        })
    })
}

app.listen(3000, () => console.log("Server is listening to port 3000."))
    
// handleDeviceData(dummyDeviceData)
// handleScheduleData(dummyScheduleData)
// handleLocationData(dummyLocationData)
// handleForecastData(dummyForecastData)

// const dummyDeviceData  = {
//   "alertsOn": true,
//   "deviceToken": "552b2796d4794a87f6ac7e2188199a276cdc743cf0e774eff1ed2f80f60c662f",
//   "currentLongitude": -84.52,
//   "currentLatitude": 34.13
// }

// const dummyScheduleData = {
//   "data": [
//     {
//       "endTime": "2026-07-20T03:59:00Z",
//       "startTime": "2026-07-19T09:00:00Z",
//       "id": "3E56A266-6308-49A1-8A7B-5929378B5E04"
//     },
//     {
//       "endTime": "2026-07-23T04:00:00Z",
//       "startTime": "2026-07-23T04:00:00Z",
//       "id": "9E82DD62-C4E7-4E4D-9B6A-20382029BF56"
//     }
//   ],
//   "deviceToken": "552b2796d4794a87f6ac7e2188199a276cdc743cf0e774eff1ed2f80f60c662f"
// }

// const dummyLocationData = {
//   "data": [
//     {
//       "id": "9FF93BA0-DBA3-481F-918B-7DB7BDCB1535",
//       "longitude": -84.4662987,
//       "latitude": 39.1417473,
//       "name": "Home"
//     },
//     {
//       "id": "17D64E9C-6205-4140-96AF-65F0369CFE13",
//       "longitude": -84.2349194,
//       "latitude": 39.1933566,
//       "name": "Work"
//     }
//   ],
//   "deviceToken": "552b2796d4794a87f6ac7e2188199a276cdc743cf0e774eff1ed2f80f60c662f"
// }

// const dummyForecastData = {
//   "deviceToken": "552b2796d4794a87f6ac7e2188199a276cdc743cf0e774eff1ed2f80f60c662f",
//   "forecastData": {
//     "includeSignificantLocations": true,
//     "forecastTime": "2026-07-19T10:00:00Z",
//     "includeCurrentLocation": true
//   }
// }
const db = require('./database')

const dummyDeviceData  = {
  "alertsOn": true,
  "deviceToken": "552b2796d4794a87f6ac7e2188199a276cdc743cf0e774eff1ed2f80f60c662f",
  "currentLongitude": -84.52,
  "currentLatitude": 34.13
}

const dummyScheduleData = {
  "data": [
    {
      "endTime": "2026-07-20T03:59:00Z",
      "startTime": "2026-07-19T09:00:00Z",
      "id": "3E56A266-6308-49A1-8A7B-5929378B5E04"
    },
    {
      "endTime": "2026-07-23T04:00:00Z",
      "startTime": "2026-07-23T04:00:00Z",
      "id": "9E82DD62-C4E7-4E4D-9B6A-20382029BF56"
    }
  ],
  "deviceToken": "552b2796d4794a87f6ac7e2188199a276cdc743cf0e774eff1ed2f80f60c662f"
}

const dummyLocationData = {
  "data": [
    {
      "id": "9FF93BA0-DBA3-481F-918B-7DB7BDCB1535",
      "longitude": -84.4662987,
      "latitude": 39.1417473,
      "name": "Home"
    },
    {
      "id": "17D64E9C-6205-4140-96AF-65F0369CFE13",
      "longitude": -84.2349194,
      "latitude": 39.1933566,
      "name": "Work"
    }
  ],
  "deviceToken": "552b2796d4794a87f6ac7e2188199a276cdc743cf0e774eff1ed2f80f60c662f"
}

const dummyForecastData = {
  "deviceToken": "552b2796d4794a87f6ac7e2188199a276cdc743cf0e774eff1ed2f80f60c662f",
  "forecastData": {
    "includeSignificantLocations": true,
    "forecastTime": "2026-07-19T10:00:00Z",
    "includeCurrentLocation": true
  }
}

function handleDeviceData(dummyDeviceData)  {
    db.run(`
        INSERT INTO devices VALUES (?, ?, ?, ?)
        ON CONFLICT(device_token) DO UPDATE SET
            current_latitude = excluded.current_latitude,
            current_longitude = excluded.current_longitude,
            alerts_on = excluded.alerts_on
        `, 
        [
            dummyDeviceData.deviceToken,
            dummyDeviceData.currentLatitude,
            dummyDeviceData.currentLongitude,
            dummyDeviceData.alertsOn
        ], 
        (err) => {
            if (err) console.error(err)
            console.log("Updated 'devices' table.")
        })
}

function handleScheduleData(dummyScheduleData)  {
    db.serialize(() => {
        db.run("DELETE FROM time_windows WHERE device_token = ?", [dummyScheduleData.deviceToken])

        for (let i = 0; i < dummyScheduleData.data.length; i++) {
            db.run("INSERT INTO time_windows VALUES (?, ?, ?, ?)",
                [
                    dummyScheduleData.deviceToken,
                    dummyScheduleData.data[i].id,
                    dummyScheduleData.data[i].startTime,
                    dummyScheduleData.data[i].endTime
                ],
                (err) => {
                    if (err) console.error(err)
                    console.log("Updated 'time_windows' table")
                })
        }
    })
}
    
function handleLocationData(dummyLocationData)  {
    db.serialize(() => {
        db.run("DELETE FROM locations WHERE device_token = ?", [dummyLocationData.deviceToken])
        
        for (let i = 0; i < dummyLocationData.data.length; i++) {
            db.run("INSERT INTO locations VALUES (?, ?, ?, ?, ?)",
                [
                    dummyLocationData.deviceToken,
                    dummyLocationData.data[i].id,
                    dummyLocationData.data[i].latitude,
                    dummyLocationData.data[i].longitude,
                    dummyLocationData.data[i].name
                ],
                (err) => {
                    if (err) console.error(err)
                    console.log("Updated 'locations' table")
                })
        }
    })
}
    
function handleForecastData(dummyForecastData)  {
    db.run(`
        INSERT INTO daily_forecasts VALUES (?, ?, ?, ?)
        ON CONFLICT(device_token) DO UPDATE SET
            forecast_time = excluded.forecast_time,
            include_current_location = excluded.include_current_location,
            include_significant_locations = excluded.include_significant_locations
        `, 
        [
            dummyForecastData.deviceToken,
            dummyForecastData.forecastData.forecastTime,
            dummyForecastData.forecastData.includeCurrentLocation,
            dummyForecastData.forecastData.includeSignificantLocations
        ], 
        (err) => {
            if (err) console.error(err)
            console.log("Updated 'daily_forecasts' table.")
        })
}
    
handleDeviceData(dummyDeviceData)
handleScheduleData(dummyScheduleData)
handleLocationData(dummyLocationData)
handleForecastData(dummyForecastData)
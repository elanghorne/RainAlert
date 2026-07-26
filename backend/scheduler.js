const db = require('./database')
require('dotenv').config()
const { sendAPNRequest } = require('./apn')

const apiKey = process.env.API_KEY
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

async function getAPIData(location) {
    const url = `https://api.openweathermap.org/data/3.0/onecall?lat=${location.latitude}&lon=${location.longitude}&appid=${apiKey}&exclude=minutely,hourly,current,alerts`
    try {
        const response = await fetch(url);
        if (!response.ok) {
        throw new Error(`HTTP error! Status: ${response.status}`);
    }
        const data = await response.json();
        console.log(data);
        return data
    } catch (error) {
        console.error('Fetch error:', error.message);
  }
}   

async function sendForecast(device, dailyForecast) {
    const locations = await getDeviceLocations(device)
    // console.log(locations)

    if (dailyForecast.include_current_location) {
        const currentLocation = { device_token: device.device_token, location_id: null, latitude: device.current_latitude, longitude: device.current_longitude, name: "your current location" }
        locations.push(currentLocation)
    }

    // send weather requests for daily forecasts per location
    let locationsWithPotentialRain = []
    for (let i = 0; i < locations.length; i++) {
        const data = await getAPIData(locations[i])
        // parse weather data per location
        if (data.daily[0].pop > 0) {
            locationsWithPotentialRain.push(locations[i].name)
        }
    }

    // build string based on weather results. current max locations is 4 (including current). current will always be last in the list.
    let notificationString = ""
    switch (locationsWithPotentialRain.length) {
        case 0:
            notificationString = "No rain in the forecast today. Enjoy the clear weather!" // maybe let the user turn this off if they only want notifs when rain is expected
            break
        case 1: 
            notificationString = `It looks like it might rain at ${locationsWithPotentialRain[0]} today. Don't forget an umbrella!`
            break
        case 2:
            notificationString = `It looks like it might rain at ${locationsWithPotentialRain[0]} and ${locationsWithPotentialRain[1]} today. Don't forget an umbrella!`
            break
        case 3:
            notificationString = `It looks like it might rain at ${locationsWithPotentialRain[0]}, ${locationsWithPotentialRain[1]}, and ${locationsWithPotentialRain[2]} today. Don't forget an umbrella!`
            break
        case 4:
            notificationString = `It looks like it might rain at ${locationsWithPotentialRain[0]}, ${locationsWithPotentialRain[1]}, ${locationsWithPotentialRain[2]}, and your current location today. Don't forget an umbrella!`
            break
        default:
            notificationString = "There must be some sort of mistake here."
    }
    
    sendAPNRequest(notificationString, device.device_token)

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
    // console.log(devices)

    const currentTime = "someTime"
    // set isTimeForRainCheck

    for (let i = 0; i < devices.length; i++) {
        const dailyForecast = await getDeviceDailyForecast(devices[i])
        // console.log(dailyForecast)

        if (isForecastTime(currentTime, dailyForecast)) {
            await sendForecast(devices[i], dailyForecast)
        }

        if (isTimeForRainCheck && devices[i].alerts_on && await inActiveTimeWindow(devices[i], currentTime)) {
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
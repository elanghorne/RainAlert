const db = require('./database')
require('dotenv').config()
const { sendAPNRequest } = require('./apn')

const apiKey = process.env.API_KEY
const DAILY_ONLY = "daily"
const HOURLY_ONLY = "hourly"
const MINUTELY_ONLY = "minutely"
const MINUTES_BETWEEN_RAIN_CHECKS = 6

function getDevices() {
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

// function getDeviceLocations(device) {
//     return new Promise((resolve, reject) => {
//         db.all(`
//             SELECT *
//             FROM locations
//             WHERE device_token = ?
//             `,
//             [device.device_token],
//             function(err, rows) {
//                 if (err) {
//                     console.error(err)
//                     return reject(err)
//                 }
//                 resolve(rows)
//             })
//     })
// }

function getDeviceLocations(device) {
    return new Promise((resolve, reject) => {
        db.all(`
            SELECT *
            FROM devices JOIN locations
            WHERE devices.device_token = locations.device_token AND locations.device_token = ?
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

function isForecastTime(dailyForecast) {
    const currentDate = new Date()
    const currentUTCHour = currentDate.getUTCHours()
    const currentUTCMinute = currentDate.getUTCMinutes()

    const forecastDate = new Date(dailyForecast.forecast_time)
    const forecastUTCHour = forecastDate.getUTCHours()
    const forecastUTCMinute = forecastDate.getUTCMinutes()

    return (currentUTCHour === forecastUTCHour && currentUTCMinute === forecastUTCMinute)
}

async function inActiveTimeWindow(device, currentTime) {
    const timeWindows = await getDeviceTimeWindows(device)
    console.log(timeWindows)
    if (timeWindows.length === 0) {
        return true
    }

    const currentDate = new Date()
    const currentUTCHour = currentDate.getUTCHours()
    const currentUTCMinute = currentDate.getUTCMinutes()

    for (let i = 0; i < timeWindows.length; i++) {
        const windowStartTime = new Date(timeWindows[i].start_time)
        const windowStartUTCHour = windowStartTime.getUTCHours()
        const windowStartUTCMinute = windowStartTime.getUTCMinutes()

        const windowEndTime = new Date(timeWindows[i].end_time)
        const windowEndUTCHour = windowEndTime.getUTCHours()
        const windowEndUTCMinute = windowEndTime.getUTCMinutes()

        const currentMinutes = currentUTCHour * 60 + currentUTCMinute
        const startMinutes = windowStartUTCHour * 60 + windowStartUTCMinute
        const endMinutes = windowEndUTCHour * 60 + windowEndUTCMinute

        if (currentMinutes >= startMinutes && currentMinutes <= endMinutes) {
            return true
        }
    }

    return false
}

async function getAPIData(location, filter) {
    let exclusions = ["minutely", "hourly", "daily"]
    const removalIndex = exclusions.indexOf(filter)
    exclusions.splice(removalIndex, 1)

    const url = `https://api.openweathermap.org/data/3.0/onecall?lat=${location.latitude}&lon=${location.longitude}&appid=${apiKey}&exclude=${exclusions[0]},${exclusions[1]},current,alerts`
    try {
        const response = await fetch(url);
        if (!response.ok) {
            throw new Error(`HTTP error! Status: ${response.status}`);
        }
        const data = await response.json();
        // console.log(data);
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
        const data = await getAPIData(locations[i], DAILY_ONLY)
        // parse weather data per location
        if (data.daily[0].pop > 0) {
            locationsWithPotentialRain.push(locations[i].name)
        }
    }

    // current max locations is 4 (including current). current will always be last in the list.
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
    
    await sendAPNRequest(notificationString, device.device_token)

}

function intensityToString(intensity) {
    let intensityString = ""
    if (intensity <= 2.5) {
        intensityString = "light"
    } else if (intensity <= 7.6) {
        intensityString = "moderate"
    } else if (intensity <= 40) {
        intensityString = "heavy"
    } else {
        intensityString = "intense"
    }

    return intensityString
}

async function checkForImminentRain(device) {
    // sends weather request for minutely data
    const currentLocation = { device_token: device.device_token, location_id: null, latitude: device.current_latitude, longitude: device.current_longitude, name: "your current location" } // this is kind of hacky. need a cleaner way to do this

    const data = await getAPIData(currentLocation, MINUTELY_ONLY)
    let firstMinuteOfRain = null
    let lastMinuteOfRain = null
    let sumOfRainInmm = 0
    let peakRainIntensity = 0

    for (let i = 0; i < data.minutely.length; i++) {
        let currentMinuteRainIntensity = data.minutely[i].precipitation
        sumOfRainInmm += currentMinuteRainIntensity
        peakRainIntensity = Math.max(peakRainIntensity, currentMinuteRainIntensity)

        if (firstMinuteOfRain === null && currentMinuteRainIntensity > 0) {
            firstMinuteOfRain = i
        }

        if (firstMinuteOfRain != null && currentMinuteRainIntensity > 0) {
            lastMinuteOfRain = i
        }
    }

    let avgRainIntensity = (sumOfRainInmm / (lastMinuteOfRain - firstMinuteOfRain + 1)) 
    // returns string with how many minutes until rain and intensity of rain. null if no rain in next *60* minutes (very subject to change)
    const peakString = intensityToString(peakRainIntensity)
    const avgString = intensityToString(avgRainIntensity)

    // firstMinuteOfRain check ensures string is only assigned if rain is expected. need to add estimated length of rain time
    let notificationString = null
    if (firstMinuteOfRain != null && peakString == avgString) {
        notificationString = `Rain is expected in ${firstMinuteOfRain} minutes. Expect ${avgString} rain.`
    } else if (firstMinuteOfRain != null && peakString != avgString) {
        notificationString =  `Rain is expected in ${firstMinuteOfRain} minutes. Expect ${avgString} to ${peakString} rain.`
    }

    return notificationString
}

function sendRainAlert(rainAlertString, deviceToken) {
    sendAPNRequest(rainAlertString, deviceToken)
}

async function runScheduler() {
    console.log("Running scheduler...")
    const devices = await getDevices()

    const currentDate = new Date()
    const currentMinute = currentDate.getUTCMinutes()
    const isTimeForRainCheck = (currentMinute % MINUTES_BETWEEN_RAIN_CHECKS) === 0

    for (let i = 0; i < devices.length; i++) {
        const dailyForecast = await getDeviceDailyForecast(devices[i])
        // console.log(dailyForecast)

        if (isForecastTime(dailyForecast)) {
            await sendForecast(devices[i], dailyForecast)
        }

        if (isTimeForRainCheck && devices[i].alerts_on && await inActiveTimeWindow(devices[i])) {
            // for now, rain checks are only for current location

            const rainAlertString = await checkForImminentRain(devices[i])

            if (rainAlertString != null) {
                await sendRainAlert(rainAlertString, devices[i].device_token)
            }

        }
    }
    console.log("Scheduler run complete.")
}


runScheduler()
setInterval(runScheduler, (1000 * 60))
const sqlite3 = require('sqlite3').verbose()
const db = new sqlite3.Database('./rainalert.db', (err) => {
    if (err) console.error(err.message);
    console.log('Connected to the database.');
});

db.serialize(() => {
    db.run("PRAGMA foreign_keys = ON");
    db.run("CREATE TABLE IF NOT EXISTS devices (device_token CHAR(64) PRIMARY KEY, current_latitude DOUBLE, current_longitude DOUBLE, alerts_on BOOL)");
    db.run("CREATE TABLE IF NOT EXISTS daily_forecasts (device_token CHAR(64) PRIMARY KEY, forecast_time TIMESTAMPTZ, include_current_location BOOL, include_significant_locations BOOL, FOREIGN KEY (device_token) REFERENCES devices(device_token))");
    db.run("CREATE TABLE IF NOT EXISTS time_windows (device_token CHAR(64), window_id CHAR(36), start_time TIMESTAMPTZ, end_time TIMESTAMPTZ, PRIMARY KEY (device_token, window_id), FOREIGN KEY (device_token) REFERENCES devices(device_token))");
    db.run("CREATE TABLE IF NOT EXISTS locations( device_token CHAR(64), location_id CHAR(36), latitude DOUBLE, longitude DOUBLE, name VARCHAR(100), PRIMARY KEY (device_token, location_id), FOREIGN KEY (device_token) REFERENCES devices(device_token))"); 
})

module.exports = db

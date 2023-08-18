// PrayerTimesResponse.swift
struct PrayerTimesResponse: Decodable {
    let city: String
    let country: String
    let timezone: String
    let date: String
    let prayer_times: [PrayerTime]
}

// PrayerTime.swift
struct PrayerTime: Decodable {
    let name: String
    let time: String
}

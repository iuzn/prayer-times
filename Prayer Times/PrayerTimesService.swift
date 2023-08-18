// PrayerTimesService.swift
import Foundation

func fetchPrayerTimes(completion: @escaping (Result<PrayerTimesResponse, Error>) -> Void) {
    let url = URL(string: "https://ptapi.vercel.app/api")!

    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        if let error = error {
            completion(.failure(error))
            return
        }

        do {
            let decoder = JSONDecoder()
            let prayerTimesResponse = try decoder.decode(PrayerTimesResponse.self, from: data!)
            completion(.success(prayerTimesResponse))
        } catch {
            completion(.failure(error))
        }
    }

    task.resume()
}

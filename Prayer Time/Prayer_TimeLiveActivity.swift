import ActivityKit
import WidgetKit
import SwiftUI

struct PrayerTimesResponse: Decodable {
    let city: String
    let country: String
    let timezone: String
    let date: String
    let prayer_times: [PrayerTime]
}

struct PrayerTime: Decodable {
    let name: String
    let time: String
}

struct PrayerTimeAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var name: String
        var time: String
    }
    var city: String
    var country: String
    var timezone: String
}

struct Prayer_TimeLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PrayerTimeAttributes.self) { context in
            VStack {
                Text("City: \(context.attributes.city), Country: \(context.attributes.country)")
                Text("Next Prayer Time: \(context.state.name) at \(context.state.time)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.state.name)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.time)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Prayer Time in \(context.attributes.city), \(context.attributes.country): \(context.state.name) at \(context.state.time)")
                }
            } compactLeading: {
                Text(context.state.name)
            } compactTrailing: {
                Text(context.state.time)
            } minimal: {
                Text(context.state.time)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension PrayerTimeAttributes {
    fileprivate static var preview: PrayerTimeAttributes {
        var attributes = PrayerTimeAttributes(city: "", country: "", timezone: "")
        fetchPrayerTimes { result in
            switch result {
            case .success(let prayerTimesResponse):
                attributes.city = prayerTimesResponse.city
                attributes.country = prayerTimesResponse.country
                attributes.timezone = prayerTimesResponse.timezone
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        return attributes
    }
}

extension PrayerTimeAttributes.ContentState {
    fileprivate static var nextPrayerTime: PrayerTimeAttributes.ContentState {
        var contentState = PrayerTimeAttributes.ContentState(name: "", time: "")
        fetchPrayerTimes { result in
            switch result {
            case .success(let prayerTimesResponse):
                let nextPrayerTime = prayerTimesResponse.prayer_times.first
                if let nextPrayerTime = nextPrayerTime {
                    contentState.name = nextPrayerTime.name
                    contentState.time = nextPrayerTime.time
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        return contentState
    }
}

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

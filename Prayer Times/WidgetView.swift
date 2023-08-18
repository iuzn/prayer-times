import WidgetKit
import SwiftUI

struct WidgetData: TimelineEntry {
    let date: Date
    let prayerTime: PrayerTime
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> WidgetData {
        WidgetData(date: Date(), prayerTime: PrayerTime(name: "Fajr", time: "05:30"))
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetData) -> ()) {
        let entry = WidgetData(date: Date(), prayerTime: PrayerTime(name: "Fajr", time: "05:30"))
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetData>) -> ()) {
        fetchPrayerTimes { result in
            switch result {
            case .success(let prayerTimesResponse):
                var entries: [WidgetData] = []
                for prayerTime in prayerTimesResponse.prayer_times {
                    let entry = WidgetData(date: Date(), prayerTime: prayerTime)
                    entries.append(entry)
                }
                let timeline = Timeline(entries: entries, policy: .atEnd)
                completion(timeline)
            case .failure(let error):
                print("Failed to fetch prayer times: \(error)")
            }
        }
    }
}

struct WidgetView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text(entry.prayerTime.name)
                .font(.title)
            Text(entry.prayerTime.time)
                .font(.largeTitle)
        }
        .padding()
    }
}

struct PrayerTimesWidget: Widget {
    let kind: String = "PrayerTimesWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WidgetView(entry: entry)
        }
        .configurationDisplayName("Prayer Times")
        .description("Displays the next prayer time.")
    }
}

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: .now, city: "İstanbul", prayerTimes:[PrayerTime(name: "İmsak", time: "04:00"), PrayerTime(name: "Güneş", time: "05:30"), PrayerTime(name: "Öğle", time: "13:00"), PrayerTime(name: "İkindi", time: "16:00"), PrayerTime(name: "Akşam", time: "19:00"), PrayerTime(name: "Yatsı", time: "21:00")], nextPrayerTime: PrayerTime(name: "İkindi", time: "16:00"), timeRemaining: "01:30:00")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry =  SimpleEntry(date: .now, city: "İstanbul", prayerTimes:[PrayerTime(name: "İmsak", time: "04:00"), PrayerTime(name: "Güneş", time: "05:30"), PrayerTime(name: "Öğle", time: "13:00"), PrayerTime(name: "İkindi", time: "16:00"), PrayerTime(name: "Akşam", time: "19:00"), PrayerTime(name: "Yatsı", time: "21:00")], nextPrayerTime: PrayerTime(name: "İkindi", time: "16:00"), timeRemaining: "01:30:00")
        
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        fetchPrayerTimes { (result) in
            switch result {
            case .success(let prayerTimesResponse):
                let nextPrayerTime = getNextPrayerTime(from: prayerTimesResponse.prayer_times)
                let timeRemaining = calculateTimeRemaining(for: nextPrayerTime)
                let currentDate = Date()
                let entry = SimpleEntry(date: currentDate, city: prayerTimesResponse.city, prayerTimes: prayerTimesResponse.prayer_times, nextPrayerTime: nextPrayerTime, timeRemaining: timeRemaining)
                entries.append(entry)

                let timeline = Timeline(entries: entries, policy: .atEnd)
                
                completion(timeline)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }



    // Fetch Prayer Times
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
    
    func getNextPrayerTime(from prayerTimes: [PrayerTime]) -> PrayerTime? {
        let now = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)

        for prayerTime in prayerTimes {
            let timeComponents = prayerTime.time.split(separator: ":")
            if let hour = Int(timeComponents[0]), let minute = Int(timeComponents[1]) {
                if (hour > currentHour) || (hour == currentHour && minute > currentMinute) {
                    return prayerTime
                }
            }
        }

        // If we've passed all the prayer times for today, the next prayer time is the first one tomorrow.
        return prayerTimes.first
    }
    func calculateTimeRemaining(for nextPrayerTime: PrayerTime?) -> String {
        guard let nextPrayerTime = nextPrayerTime else { return "--:--:--" }

        let now = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        let currentSecond = calendar.component(.second, from: now)

        let timeComponents = nextPrayerTime.time.split(separator: ":")
        if let nextHour = Int(timeComponents[0]), let nextMinute = Int(timeComponents[1]) {
            var remainingSeconds = (nextHour * 3600 + nextMinute * 60) - (currentHour * 3600 + currentMinute * 60 + currentSecond)
            if remainingSeconds < 0 {
                // If we've passed the prayer time, add 24 hours to get the time until the next day's prayer time.
                remainingSeconds += 24 * 3600
            }

            let hours = remainingSeconds / 3600
            let minutes = (remainingSeconds % 3600) / 60
            let seconds = remainingSeconds % 60

            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            // If we couldn't parse the prayer time, display a placeholder.
            return "--:--:--"
        }
    }

}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let city: String
    let prayerTimes: [PrayerTime]
    let nextPrayerTime: PrayerTime?
    let timeRemaining: String
}

struct CountdownView: View {
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var timeRemaining: String

    var body: some View {
        Text(timeRemaining)
            .onReceive(timer) { _ in
                let nextPrayerTimeComponents = timeRemaining.split(separator: ":").map { Int($0) }
                if let hours = nextPrayerTimeComponents[0], let minutes = nextPrayerTimeComponents[1], let seconds = nextPrayerTimeComponents[2] {
                    let totalSeconds = hours * 3600 + minutes * 60 + seconds
                    if totalSeconds > 0 {
                        let remainingSeconds = totalSeconds - 1
                        let newHours = remainingSeconds / 3600
                        let newMinutes = (remainingSeconds % 3600) / 60
                        let newSeconds = remainingSeconds % 60
                        timeRemaining = String(format: "%02d:%02d:%02d", newHours, newMinutes, newSeconds)
                    }
                }
            }
    }
}

struct Prayer_TimeEntryView : View {
    @Environment(\.widgetFamily) private var widgetFamily
    var entry: Provider.Entry

    @ViewBuilder
    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            smallWidget
        case .systemMedium:
            mediumWidget
        case .systemLarge:
            largeWidget
        case .systemExtraLarge:
            Text("Bilinmeyen widget ailesi")
        case .accessoryCircular:
            Text("Bilinmeyen widget ailesi")
        case .accessoryRectangular:
            Text("Bilinmeyen widget ailesi")
        case .accessoryInline:
            Text("Bilinmeyen widget ailesi")
        @unknown default:
            Text("Bilinmeyen widget ailesi")
        }
    }



    var smallWidget: some View  {
            VStack(spacing: 20) {
                if entry.nextPrayerTime != nil {
                    Text("Kalan Süre")
                        .font(.subheadline)
                    
                    CountdownView(timeRemaining: entry.timeRemaining)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .containerBackground(.fill.tertiary, for: .widget)
        }

    var mediumWidget: some View {
        GeometryReader { geometry in
            HStack (alignment: .top){
            VStack(spacing: 20) {
                if let nextPrayerTime = entry.nextPrayerTime {
                    VStack(spacing: 5) {
                        // First Segment
                        ZStack {
                            Image(systemName: "location.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .opacity(0.2)
                                .frame(width: geometry.size.width/4, height: geometry.size.width/4)
                            
                            Text(entry.city)
                                .font(.caption)
                                .bold()
                                .foregroundColor(.white)
                        }
                        .frame(width: geometry.size.width*2/5, height: geometry.size.width/10)
                        .background(LinearGradient(gradient: Gradient(colors: [.red, .black]), startPoint: .top, endPoint: .bottom))
                        .cornerRadius(5)

                        // Second Segment
                        ZStack {
                            Image(systemName: "sun.max.fill")
                                .resizable()
                                .scaledToFit()
                                .opacity(0.2)
                                .frame(width: geometry.size.width/4, height: geometry.size.width/4)
                            
                            VStack {
                                Text(nextPrayerTime.name)
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Text(nextPrayerTime.time)
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(width: geometry.size.width*2/5, height: geometry.size.width/8)
                        .background(LinearGradient(gradient: Gradient(colors: [.yellow, .black]), startPoint: .top, endPoint: .bottom))
                        .cornerRadius(5)

                        // Third Segment
                        ZStack {
                            Image(systemName: "clock.fill")
                                .resizable()
                                .scaledToFit()
                                .opacity(0.2)
                                .frame(width: geometry.size.width/4, height: geometry.size.width/4)
                            
                            VStack {
                                Text("Kalan Süre")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                                Text(entry.timeRemaining)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(width: geometry.size.width*2/5, height: geometry.size.width/6)
                        .background(LinearGradient(gradient: Gradient(colors: [.brown, .black]), startPoint: .top, endPoint: .bottom))
                        .cornerRadius(5)
                    }
                }
              
            }
                // Right-side VStack
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(entry.prayerTimes, id: \.name) { prayerTime in
                        let isActiveTime = prayerTime.name == entry.nextPrayerTime?.name
                        HStack {
                            isActiveTime ?
                               Text(prayerTime.name)
                                   .font(.caption2)
                                   .bold()
                           :
                               Text(prayerTime.name)
                                   .font(.caption2)
                            Spacer()

                            isActiveTime ?
                            Text(prayerTime.time)
                                .font(.caption2)
                                .bold()
                                .opacity(1)
                            :
                            Text(prayerTime.time)
                                .font(.caption2)
                                .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                        
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, isActiveTime ? 4 : 2.5)
                        .background(isActiveTime ?Color.green.opacity(0.2): Color.gray.opacity(0.1))
                        .cornerRadius(5)
                    
                    }
                }
                .frame(width: geometry.size.width*3/5)
    
            }
            .padding(.horizontal, -4)
            .containerBackground(.fill.tertiary, for: .widget)
        }
    }


    var largeWidget: some View {
        GeometryReader { geometry in
            HStack {
                VStack(spacing: 10) {

                    if let nextPrayerTime = entry.nextPrayerTime {
                        VStack(spacing: 10) {
                        
                            // First Segment
                            ZStack {
                                Image(systemName: "location.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .opacity(0.2)
                                    .frame(width: geometry.size.width/4, height: geometry.size.width/4)
                                
                                Text(entry.city)
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundColor(.white)
                            }
                            .frame(width: geometry.size.width/3, height: geometry.size.width/4)
                            .background(LinearGradient(gradient: Gradient(colors: [.red, .black]), startPoint: .top, endPoint: .bottom))
                            .cornerRadius(10)

                            // Second Segment
                            ZStack {
                                Image(systemName: "sun.max.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .opacity(0.2)
                                    .frame(width: geometry.size.width/4, height: geometry.size.width/4)
                                VStack {

                                Text("Sonraki Vakit")
                                        .font(.caption2)
                                        .foregroundColor(.white)
                                Text(nextPrayerTime.name)
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Text(nextPrayerTime.time)
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            }
                            .frame(width: geometry.size.width/3, height: geometry.size.width/4)
                            .background(LinearGradient(gradient: Gradient(colors: [.yellow, .black]), startPoint: .top, endPoint: .bottom))
                            .cornerRadius(10)

                            // Third Segment
                            ZStack {
                                Image(systemName: "clock.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .opacity(0.2)
                                    .frame(width: geometry.size.width/4, height: geometry.size.width/4)
                                
                                VStack {
                                    Text("Kalan Süre")
                                        .font(.caption2)
                                        .foregroundColor(.white)
                                    Text(entry.timeRemaining)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(width: geometry.size.width/3, height: geometry.size.width/4)
                            .background(LinearGradient(gradient: Gradient(colors: [.brown, .black]), startPoint: .top, endPoint: .bottom))
                            .cornerRadius(10)
                        }
                    }
                }
                
                // Right-side VStack
                VStack {
                    ForEach(entry.prayerTimes, id: \.name) { prayerTime in
                        HStack {
                            Text(prayerTime.name)
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Spacer()

                            Text(prayerTime.time)
                                .font(.caption)
                                .opacity(0.6)
                        }
                        .padding(10)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.green, lineWidth: 1))
                    }
                }
                .frame(width: geometry.size.width/2)
            }
            .padding()
            .containerBackground(.fill.tertiary, for: .widget)
        }
    }


}


struct Prayer_Time: Widget {
    let kind: String = "Prayer_Time"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            Prayer_TimeEntryView(entry: entry)
        }
        .configurationDisplayName("Namaz Vakti")
        .description("Bu widget bir sonraki namaz vaktine kalan süreyi gösterir.")
    }
}


#Preview(as: .systemSmall) {
    Prayer_Time()
} timeline: {
    SimpleEntry(date: .now, city: "İstanbul", prayerTimes:[PrayerTime(name: "İmsak", time: "04:00"), PrayerTime(name: "Güneş", time: "05:30"), PrayerTime(name: "Öğle", time: "13:00"), PrayerTime(name: "İkindi", time: "16:00"), PrayerTime(name: "Akşam", time: "19:00"), PrayerTime(name: "Yatsı", time: "21:00")], nextPrayerTime: PrayerTime(name: "İkindi", time: "16:00"), timeRemaining: "01:30:00")
}

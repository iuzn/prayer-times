//
//  ContentView.swift
//  Prayer Times
//
//  Created by ibrahim uzun on 6/6/23.
//

import SwiftUI
extension Color {
    static var newGreen: Color {
        return Color(UIColor.newGreen)
    }
}

extension UIColor {
    static var newGreen: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return UIColor(red: 0.01, green: 0.4, blue: 0.04, alpha: 0.8) // Dark mode için renk
                default:
                    return UIColor(red: 0.08, green: 0.6, blue: 0.2, alpha: 0.7) // Light mode için aynı renk
                }
            }
        } else {
            return UIColor(red: 0.01, green: 0.4, blue: 0.04, alpha: 0.9) // iOS 13.0'dan önceki sürümler için renk
        }
    }
}

struct PrayerTimesView: View {
    @State var prayerTimes: [PrayerTime] = []
    @State var nextPrayerTime: PrayerTime?
    @State var timeRemaining: String = "--:--:--"
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var body: some View {
        VStack {
            VStack {
                Text("Bir Sonraki Namaz Vakti")
                    .font(.subheadline)
                    .opacity(0.8)
                    .padding(4)
                Text("\(nextPrayerTime?.name ?? "--")")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(2)
                    .foregroundColor(.newGreen)

                Text("\(nextPrayerTime?.time ?? "--")")
                    .font(.title)
                    .fontWeight(.bold)
                Divider()
                Text("Kalan Süre")
                    .font(.subheadline)
                    .opacity(0.8)
                    .padding(4)
                Text("\(timeRemaining)")
                    .font(.title)
                    .fontWeight(.bold)
            }
            .padding(20)
            .background(Color.green.opacity(0.2))
            .cornerRadius(20)
            .padding([.leading, .trailing], 30) // Extra padding to prevent sticking to sides.

            ZStack {
                List(prayerTimes, id: \.name) { prayerTime in
                    let isActiveTime = prayerTime.name == nextPrayerTime?.name

                    HStack {
                        
                         isActiveTime ?
                            Text(prayerTime.name)
                                .font(.headline)
                                .bold()
                        :
                            Text(prayerTime.name)
                                .font(.headline)
                        
                        Spacer()
                        
                        isActiveTime ?
                        Text(prayerTime.time)
                            .font(.subheadline)
                            .bold()
                            .opacity(1)
                        :
                        Text(prayerTime.time)
                            .font(.subheadline)
                            .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                    
                    }

                    .foregroundColor(prayerTime.name == nextPrayerTime?.name  ? .newGreen : .primary)
                
                }
                
            }
            .navigationTitle("Namaz Vakitleri")
            .onAppear {
                fetchPrayerTimes { result in
                    switch result {
                    case .success(let prayerTimesResponse):
                        self.prayerTimes = prayerTimesResponse.prayer_times.map { PrayerTime(name: $0.name, time: $0.time) }
                        self.setNextPrayerTime()
                    case .failure(let error):
                        print("Failed to fetch prayer times: \(error)")
                    }
                }
            }
            .onReceive(timer) { _ in
                self.updateTimeRemaining()
            }
        }
    }

    private func setNextPrayerTime() {
        let now = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)

        for prayerTime in prayerTimes {
            let timeComponents = prayerTime.time.split(separator: ":")
            if let hour = Int(timeComponents[0]), let minute = Int(timeComponents[1]) {
                if (hour > currentHour) || (hour == currentHour && minute > currentMinute) {
                    nextPrayerTime = prayerTime
                    return
                }
            }
        }

        // If we've passed all the prayer times for today, the next prayer time is the first one tomorrow.
        nextPrayerTime = prayerTimes.first
    }

    private func updateTimeRemaining() {
        guard let nextPrayerTime = nextPrayerTime else { return }

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

            timeRemaining = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            // If we couldn't parse the prayer time, display a placeholder.
            timeRemaining = "--:--:--"
        }
    }

}


#Preview {
    PrayerTimesView()
}


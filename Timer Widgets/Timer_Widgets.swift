//
//  TimerWidget.swift
//  WidgetExtension
//
//  Created by Pawel Wiszenko on 15.10.2020.
//  Copyright © 2020 Pawel Wiszenko. All rights reserved.
//

import SwiftUI
import WidgetKit

enum WidgetKind {
    static var appGroup: String { widgetKind(#function) }
    static var clock: String { widgetKind(#function) }
    static var coreData: String { widgetKind(#function) }
    static var countdown: String { widgetKind(#function) }
    static var deepLink: String { widgetKind(#function) }
    static var dynamicIntent: String { widgetKind(#function) }
    static var environment: String { widgetKind(#function) }
    static var intent: String { widgetKind(#function) }
    static var lockScreen: String { widgetKind(#function) }
    static var network: String { widgetKind(#function) }
    static var preview: String { widgetKind(#function) }
    static var timer: String { widgetKind(#function) }
    static var urlImage: String { widgetKind(#function) }
    static var urlCachedImage: String { widgetKind(#function) }

    private static func widgetKind(_ kind: String) -> String {
        kind + "Widget"
    }
}


private struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let midnight = Calendar.current.startOfDay(for: Date())
        let nextMidnight = Calendar.current.date(byAdding: .day, value: 1, to: midnight)!
        let entries = [SimpleEntry(date: midnight)]
        let timeline = Timeline(entries: entries, policy: .after(nextMidnight))
        completion(timeline)
    }
}

private struct SimpleEntry: TimelineEntry {
    let date: Date
}

private struct TimerWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        Text(entry.date, style: .timer)
    }
}

struct TimerWidget: Widget {
    
    private let kind: String = WidgetKind.timer

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TimerWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Timer Widget")
        .description("A Widget that displays the current time (including seconds) as a timer.")
        .supportedFamilies([.systemSmall])
    }
}

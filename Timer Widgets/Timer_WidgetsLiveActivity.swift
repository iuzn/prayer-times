//
//  Timer_WidgetsLiveActivity.swift
//  Timer Widgets
//
//  Created by ibrahim uzun on 6/7/23.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct Timer_WidgetsAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct Timer_WidgetsLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: Timer_WidgetsAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension Timer_WidgetsAttributes {
    fileprivate static var preview: Timer_WidgetsAttributes {
        Timer_WidgetsAttributes(name: "World")
    }
}

extension Timer_WidgetsAttributes.ContentState {
    fileprivate static var smiley: Timer_WidgetsAttributes.ContentState {
        Timer_WidgetsAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: Timer_WidgetsAttributes.ContentState {
         Timer_WidgetsAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: Timer_WidgetsAttributes.preview) {
   Timer_WidgetsLiveActivity()
} contentStates: {
    Timer_WidgetsAttributes.ContentState.smiley
    Timer_WidgetsAttributes.ContentState.starEyes
}

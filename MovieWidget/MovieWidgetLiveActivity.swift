//
//  MovieWidgetLiveActivity.swift
//  MovieWidget
//
//  Created by ArkarPhyo on 28/9/2567 BE.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct MovieWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct MovieWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MovieWidgetAttributes.self) { context in
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

extension MovieWidgetAttributes {
    fileprivate static var preview: MovieWidgetAttributes {
        MovieWidgetAttributes(name: "World")
    }
}

extension MovieWidgetAttributes.ContentState {
    fileprivate static var smiley: MovieWidgetAttributes.ContentState {
        MovieWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: MovieWidgetAttributes.ContentState {
         MovieWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: MovieWidgetAttributes.preview) {
   MovieWidgetLiveActivity()
} contentStates: {
    MovieWidgetAttributes.ContentState.smiley
    MovieWidgetAttributes.ContentState.starEyes
}

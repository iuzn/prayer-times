//
//  AppIntent.swift
//  Prayer Time
//
//  Created by ibrahim uzun on 6/7/23.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("This is a prayer time widget.")

    // An example configurable parameter.
    @Parameter(title: "City", default: "Istanbul")
    var city: String
}

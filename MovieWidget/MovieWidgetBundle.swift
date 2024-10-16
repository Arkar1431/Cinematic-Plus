//
//  MovieWidgetBundle.swift
//  MovieWidget
//
//  Created by ArkarPhyo on 28/9/2567 BE.
//

import WidgetKit
import SwiftUI

@main
struct MovieWidgetBundle: WidgetBundle {
    var body: some Widget {
        MovieWidget()
        MovieWidgetLiveActivity()
    }
}

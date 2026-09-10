//
//  The_Last_BrushstrokeApp.swift
//  The Last Brushstroke
//
//  Created by Shyam Prakash on 08/09/26.
//

import SwiftUI

@main
struct The_Last_BrushstrokeApp: App {

    @State private var coordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            ContentView(
                coordinator: coordinator
            )
        }
    }
}

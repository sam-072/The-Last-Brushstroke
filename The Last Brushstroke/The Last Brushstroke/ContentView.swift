//
//  ContentView.swift
//  The Last Brushstroke
//
//  Created by Shyam Prakash on 08/09/26.
//

import SwiftUI

struct ContentView: View {

    let coordinator: AppCoordinator

    var body: some View {
        PaintingView(
            coordinator: coordinator
        )
    }
}

#Preview {
    ContentView(
        coordinator: AppCoordinator()
    )
}
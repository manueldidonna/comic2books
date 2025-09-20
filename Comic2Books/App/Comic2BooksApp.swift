//
//  Comic2BooksApp.swift
//  Comic2Books
//
//  Created by Manuel Di Donna on 17/07/24.
//

import SwiftUI

@main
struct Comic2BooksApp: App {
  @State private var state = AppState()

  var body: some Scene {
    WindowGroup {
      ContentView()
        .frame(minWidth: 800, idealWidth: 1000, minHeight: 480)
    }
    .environment(state)
    .windowStyle(.titleBar)
    .windowToolbarStyle(.unified)
  }
}

private struct ContentView: View {
  var body: some View {
    ConverterScreen()
  }
}

#Preview {
  ContentView()
    .frame(width: 800)
}

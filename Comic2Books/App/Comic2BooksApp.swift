//
//  Comic2BooksApp.swift
//  Comic2Books
//
//  Created by Manuel Di Donna on 17/07/24.
//

import SwiftUI

@main
struct Comic2BooksApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
        .frame(minWidth: 800, idealWidth: 1000, minHeight: 480)
    }
    .windowStyle(.hiddenTitleBar)
    .windowToolbarStyle(.unifiedCompact(showsTitle: false))
  }
}

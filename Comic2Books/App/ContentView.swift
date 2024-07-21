//
//  ContentView.swift
//  Comic2Books
//
//  Created by Manuel Di Donna on 17/07/24.
//

import SwiftUI

struct ContentView: View {
  @State private var state = AppState()
  var body: some View {
    ConverterScreen()
      .environment(state)
  }
}

#Preview {
  ContentView()
    .frame(width: 800)
}

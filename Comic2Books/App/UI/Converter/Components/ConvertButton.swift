//
//  ConvertButton.swift
//  Comic2Books
//
//  Created by Manuel Di Donna on 21/07/24.
//

import SwiftUI

@MainActor
struct ConvertButton: View {
  @Environment(AppState.self) private var appState

  @State private var converting = false
  @State private var openOutputDirectory = false
  @State private var task: Task<Void, Error>?
  @State private var progress: Double = .zero

  var body: some View {
    Button(action: performConversion) {
      Text(converting ? "Stop — \(Int(progress * 100))%" : "Convert")
        .frame(maxWidth: .infinity)
        .monospacedDigit()
    }
    .tint(converting ? .red : .accent)
    .controlSize(.large)
    .buttonStyle(.borderedProminent)
    .disabled(appState.importedComics.isEmpty)
    .alert("Conversion completed!", isPresented: $openOutputDirectory) {
      Button("Show in Finder") {
        NSWorkspace.shared.activateFileViewerSelecting([EPUBRequest.outputDirectory])
      }
      Button("Cancel", role: .cancel, action: {})
    } message: {
      Text("You can find your files in the Downloads folder")
    }
    .padding()
  }

  private func performConversion() {
    task?.cancel()

    guard !converting else { return }

    let options = appState.converterOptions
    let comics = appState.importedComics

    task = Task {
      self.converting = true
      defer {
        self.converting = false
        self.progress = .zero
      }

      for (index, comic) in comics.enumerated() {
        try Task.checkCancellation()
        let request = EPUBRequest(comic: comic, options: options)
        try await request.execute { progress in
          let totalPerRequest = 1 / Double(comics.count)
          self.progress = (Double(index) * totalPerRequest) + (progress * totalPerRequest)
        }
      }
      self.openOutputDirectory = true
    }
  }
}

#Preview {
  ConvertButton()
    .frame(width: 280)
    .environment(AppState())
}

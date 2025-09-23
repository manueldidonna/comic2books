//
//  ExporterWindow.swift
//  Comic2Books
//
//  Created by Manuel Di Donna on 20/09/25.
//

import Foundation
import SwiftUI

struct ExportRequest: Equatable, Hashable, Identifiable {
  let destinationURL: URL
  var id: URL { destinationURL }
}

extension View {
  func comicsExporter(for request: Binding<ExportRequest?>) -> some View {
    sheet(item: request) { currentRequest in
      ExporterScreen(destinationURL: currentRequest.destinationURL)
        .customizeExporterSheet()
    }
  }

  @ViewBuilder
  private func customizeExporterSheet() -> some View {
    if #available(macOS 15.0, *) {
      self
        .presentationSizing(.form)
    } else {
      self
    }
  }
}

// MARK: - ExporterScreen

private struct ExporterScreen: View {
  let destinationURL: URL

  @Environment(AppState.self) private var appState

  @State private var error: (any Error)?
  @State private var exportStarted = false
  @State private var exportingComics: Set<Comic.ID> = []

  var body: some View {
    ScrollView {
      LazyVStack(alignment: .leading, spacing: 12) {
        if let error {
          ErrorBanner(error: error)
        }

        ForEach(appState.importedComics) { comic in
          ComicRow(
            comic: comic,
            isExporting: exportingComics.contains(comic.id),
            exportStarted: exportStarted,
            failed: error != nil
          )
        }
      }
      .scenePadding()
    }
    .toolbar {
      ExporterToolbar(
        exportFinished: exportFinished,
        destinationURL: destinationURL
      )
    }
    .task {
      await convertComics()
    }
  }

  private var exportFinished: Bool {
    exportStarted && exportingComics.isEmpty && error == nil
  }
}

// MARK: - UI Subviews

private struct ErrorBanner: View {
  let error: any Error

  var body: some View {
    Text(error.localizedDescription)
      .multilineTextAlignment(.leading)
      .font(.body)
      .padding()
      .foregroundStyle(.red)
      .background(.red.tertiary, in: .rect(cornerRadius: 12))
  }
}

private struct ComicRow: View {
  let comic: Comic
  let isExporting: Bool
  let exportStarted: Bool
  let failed: Bool

  var body: some View {
    HStack(alignment: .center, spacing: 12) {
      Text(comic.title)
        .frame(maxWidth: .infinity, alignment: .leading)
        .lineLimit(1)

      statusIcon
    }
    .font(.body)
  }

  @ViewBuilder
  private var statusIcon: some View {
    if isExporting {
      if !failed {
        ProgressView().controlSize(.mini)
      } else {
        Image(systemName: "exclamationmark.circle")
          .foregroundStyle(.red)
          .fontWeight(.semibold)
      }
    } else if exportStarted {
      Image(systemName: "checkmark.circle")
        .foregroundStyle(.green)
        .fontWeight(.semibold)
    }
  }
}

// MARK: - Conversion Logic

extension ExporterScreen {
  private func convertComics() async {
    do {
      let comics = appState.importedComics
      guard !comics.isEmpty else { return }

      exportingComics = Set(comics.map(\.id))
      exportStarted = true

      try await accessDestinationAndConvert(comics: comics)
    } catch {
      self.error = error
    }
  }

  private func accessDestinationAndConvert(comics: [Comic]) async throws {
    guard destinationURL.startAccessingSecurityScopedResource() else {
      throw NSError(
        domain: "MoveFileError",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Cannot access destination folder"]
      )
    }
    defer { destinationURL.stopAccessingSecurityScopedResource() }

    try await convertInBatches(comics: comics)
  }

  private func convertInBatches(comics: [Comic]) async throws {
    let maxParallel = 4
    var index = 0

    while index < comics.count {
      let end = min(index + maxParallel, comics.count)
      let batch = Array(comics[index..<end])

      try await withThrowingTaskGroup(of: Void.self) { group in
        for comic in batch {
          group.addTask {
            try await convertSingleComic(comic)
          }
        }
        try await group.waitForAll()
      }

      index = end
    }
  }

  private func convertSingleComic(_ comic: Comic) async throws {
    let converter = EPUBConverter()
    let request = EPUBRequest(
      title: comic.title,
      author: comic.author,
      options: appState.converterOptions,
      useMangaReadingDirection: comic.isManga,
      inputURL: comic.location,
    )

    guard request.inputURL.startAccessingSecurityScopedResource() else {
      throw NSError(
        domain: "ComicConverter",
        code: 1,
        userInfo: [
          NSLocalizedDescriptionKey: "Cannot access comic file: Permission Denied"
        ]
      )
    }
    defer { request.inputURL.stopAccessingSecurityScopedResource() }

    try await converter.convert(request: request, saveTo: destinationURL)
    exportingComics.remove(comic.id)
  }
}

// MARK: - ExporterToolbar

private struct ExporterToolbar: ToolbarContent {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.openURL) private var openURL

  let exportFinished: Bool
  let destinationURL: URL

  var body: some ToolbarContent {
    if exportFinished {
      ToolbarItem(placement: .primaryAction) {
        Button("Show in Finder") {
          openDestination()
        }
      }
    }

    ToolbarItem(placement: .cancellationAction) {
      if #available(macOS 26.0, *) {
        Button(role: exportFinished ? .close : .cancel) {
          dismiss()
        }
      } else {
        Button(role: .cancel) {
          dismiss()
        } label: {
          Text(exportFinished ? "Close" : "Cancel")
        }
      }
    }
  }

  private func openDestination() {
    if destinationURL.startAccessingSecurityScopedResource() {
      defer { destinationURL.stopAccessingSecurityScopedResource() }
      NSWorkspace.shared.open(destinationURL)
    } else {
      NSWorkspace.shared.open(destinationURL)
    }
  }
}

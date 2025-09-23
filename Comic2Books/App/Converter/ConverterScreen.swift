//
//  ConverterScreen.swift
//  Comic2Books
//
//  Created by Manuel Di Donna on 20/09/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct ConverterScreen: View {
  @State private var isSettingsVisible: Bool = true
  @Environment(AppState.self) private var appState

  var body: some View {
    NavigationStack {
      ConverterComicsTable(
        comics: appState.importedComics,
        onRemove: { id in
          appState.removeComic(with: id)
        }
      )
      .emptyPlaceholder(visible: appState.importedComics.isEmpty)
      .insettedConvertButton(visible: !appState.importedComics.isEmpty)
      .navigationTitle("Comic2Books")
      .toolbar {
        if #available(macOS 26.0, *) {
          ToolbarSpacer(.fixed, placement: .primaryAction)
        }

        ToolbarItem(placement: .primaryAction) {
          Button {
            isSettingsVisible.toggle()
          } label: {
            Image(systemName: "sidebar.right")
          }

        }
      }
      .comicsImporter()
    }
    .inspector(isPresented: $isSettingsVisible) {
      ConvertSettingsView()
        .frame(width: 340)
        .inspectorColumnWidth(340)
    }
  }
}

extension View {
  fileprivate func emptyPlaceholder(visible: Bool) -> some View {
    self  //
      .opacity(visible ? 0 : 1)
      .overlay {
        if visible {
          EmptyComicsView()
        }
      }
  }

  fileprivate func comicsImporter() -> some View {
    self
      .modifier(ComicsDropHandler())
      .toolbar {
        ImportToolbar()
      }
  }

  @ViewBuilder
  fileprivate func insettedConvertButton(visible: Bool) -> some View {
    if #available(macOS 26.0, *) {
      self.safeAreaBar(edge: .bottom) {
        if visible {
          ConvertButton()
            .buttonStyle(.glassProminent)
            .controlSize(.extraLarge)
            .frame(maxWidth: .infinity, alignment: .leading)
            .scenePadding()
        }
      }
    } else {
      self.safeAreaInset(edge: .bottom) {
        if visible {
          ConvertButton()
            .buttonStyle(.borderedProminent)
            .controlSize(.extraLarge)
            .frame(maxWidth: .infinity, alignment: .leading)
            .scenePadding()
            .background(.regularMaterial)
        }
      }
    }
  }
}

// MARK: - Converter Button

private struct ConvertButton: View {
  @Environment(AppState.self) private var appState
  @Environment(\.openWindow) private var openWindow

  @State private var isImporterPresented = false
  @State private var exportRequest: ExportRequest?

  var body: some View {
    Button {
      isImporterPresented = true
    } label: {
      Text("Convert")
    }
    .fileImporter(
      isPresented: $isImporterPresented,
      allowedContentTypes: [.directory],
      allowsMultipleSelection: false
    ) { result in
      switch result {
      case .success(let urls):
        if let url = urls.first {
          self.exportRequest = .init(destinationURL: url)
        }
      case .failure(let error):
        print(error)
      }
    }
    .comicsExporter(for: $exportRequest)
  }
}

// MARK: - Empty View

private struct EmptyComicsView: View {
  var body: some View {
    ContentUnavailableView(
      "Convert your comics to EPUB",
      systemImage: "doc.badge.arrow.up",
      description: Text("Support input from zip, cbz, rar, cbr and pdf")
    )
  }
}

// MARK: - Drop Handler

private struct ComicsDropHandler: ViewModifier {
  @Environment(AppState.self) private var appState

  func body(content: Content) -> some View {
    content
      .dropDestination(for: URL.self) { items, _ in
        let validItems =
          items
          .filter { url in
            guard let type = url.type else { return false }
            return UTType.allowedComicTypes.contains(type)
          }
          .map(Comic.init(location:))
        appState.importComics(validItems)
        return true
      }
  }
}

// MARK: - Toolbar

private struct ImportToolbar: ToolbarContent {
  @State private var isFileImporterPresented = false
  @Environment(AppState.self) private var appState

  var body: some ToolbarContent {
    ToolbarItemGroup(placement: .primaryAction) {
      Button {
        isFileImporterPresented = true
      } label: {
        Image(systemName: "plus")
      }
      .help("Import Comics")
      .fileImporter(
        isPresented: $isFileImporterPresented,
        allowedContentTypes: UTType.allowedComicTypes,
        allowsMultipleSelection: true
      ) { result in
        switch result {
        case .success(let comicURLs):
          let comics = comicURLs.map { Comic(location: $0) }
          appState.importComics(comics)
        case .failure(let failure):
          print(failure)
        }
      }

      if !appState.importedComics.isEmpty {
        Button(role: .destructive) {
          appState.removeAllComics()
        } label: {
          Image(systemName: "trash")

        }
        .help("Remove all comics")
      }
    }
  }
}

#Preview {
  @Previewable @State var appState = AppState()
  ConverterScreen()
    .environment(appState)
}

#Preview {
  EmptyComicsView()
}

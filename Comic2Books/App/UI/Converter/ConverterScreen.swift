//
//  ConverterScreen.swift
//  Comic2Books
//
//  Created by Manuel Di Donna on 18/07/24.
//

import SwiftUI
import UniformTypeIdentifiers

struct ConverterScreen: View {
  @Environment(AppState.self) private var appState
  @State private var dropping = false

  var body: some View {
    HStack(spacing: 0) {
      ConverterOptionsPanel()
      ImportedComicsList()
        .clipShape(.rect(cornerRadius: 8))
        .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
        .padding(12)
    }
    .overlay {
      if dropping { DragDropOverlay() }
    }
    .modifier(ComicsImporter(isTargeted: $dropping) { comics in
      appState.importComics(comics)
    })
    .toolbar {
      ToolbarItem(placement: .secondaryAction) {
        Button(action: { appState.removeAllComics() }) {
          Image(systemName: "trash")
        }
        .help("Remove all comics")
        .disabled(appState.importedComics.isEmpty)
      }
    }
  }
}

private struct DragDropOverlay: View {
  var body: some View {
    VStack {
      Image(systemName: "doc.badge.arrow.up")
        .font(.system(size: 64))
      Text("Drop your comics")
        .font(.title)
    }
    .foregroundStyle(.white)
    .fontWeight(.semibold)
    .containerRelativeFrame([.horizontal, .vertical])
    .background(.accent)
  }
}

// MARK: Comics Import Utilities

private struct ComicsImporter: ViewModifier {
  @Binding var isTargeted: Bool
  let onImport: ([Comic]) -> Void

  func body(content: Content) -> some View {
    content
      .dropDestination(for: URL.self) { items, _ in
        let validItems = items
          .filter { url in
            guard let type = url.type else { return false }
            return UTType.allowedComicTypes.contains(type)
          }
          .map(Comic.init(location:))
        self.onImport(validItems)
        return true
      } isTargeted: { isTargeted = $0 }
      .toolbar {
        ImportComicsToolbarButton(onImport: onImport)
      }
  }
}

private struct ImportComicsToolbarButton: ToolbarContent {
  let onImport: ([Comic]) -> Void

  @State private var importing = false

  var body: some ToolbarContent {
    ToolbarItem(placement: .navigation) {
      Button(action: { importing = true }) {
        Image(systemName: "plus")
      }
      .fileImporter(
        isPresented: $importing,
        allowedContentTypes: UTType.allowedComicTypes,
        allowsMultipleSelection: true
      ) { result in
        switch result {
        case let .success(success):
          onImport(success.map(Comic.init(location:)))
        case let .failure(failure):
          print(failure)
        }
      }
    }
  }
}

#Preview {
  ConverterScreen()
}

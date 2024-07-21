//
//  ComicFilesList.swift
//  Comic2Books
//
//  Created by Manuel Di Donna on 18/07/24.
//

import SwiftUI

struct ImportedComicsList: View {
  @Environment(AppState.self) private var appState

  var body: some View {
    Table(of: Comic.self) {
      TableColumn("Title") { comic in
        @Bindable var comic = comic
        TextField(comic.defaultTitle, text: $comic.inputTitle)
      }
      .width(min: 300)
      TableColumn("Author") { comic in
        @Bindable var comic = comic
        TextField(comic.defaultAuthor, text: $comic.inputAuthor)
      }
    } rows: {
      ForEach(appState.importedComics) { comic in
        TableRow(comic)
          .contextMenu {
            Button("Remove", role: .destructive) {
              appState.removeComic(with: comic.id)
            }
            .keyboardShortcut(.delete, modifiers: .command)
          }
      }
    }
    .animation(.smooth, value: appState.importedComics)
    .textFieldStyle(.plain)
    .overlay {
      if appState.importedComics.isEmpty {
        emptyListView
      }
    }
  }

  private var emptyListView: some View {
    ContentUnavailableView("Convert your comics to EPUB",
                           systemImage: "doc.badge.arrow.up",
                           description: Text("Support input from zip, cbz, rar, cbr and pdf"))
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background()
  }
}

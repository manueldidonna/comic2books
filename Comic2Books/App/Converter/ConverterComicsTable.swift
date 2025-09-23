//
//  ImportedComicsList2.swift
//  Comic2Books
//
//  Created by Manuel Di Donna on 20/09/25.
//

import SwiftUI

struct ConverterComicsTable: View {
  var comics: [Comic]
  let onRemove: (Comic.ID) -> Void

  var body: some View {
    Table(of: Comic.self) {
      TableColumn("Manga") { comic in
        @Bindable var comic = comic
        Toggle("Manga", isOn: $comic.isManga)
          .labelsHidden()
          .toggleStyle(.checkbox)
          .help("Set reading direction to Right to Left")
      }
      .width(min: 40, max: 60)

      TableColumn("Title") { comic in
        @Bindable var comic = comic
        TextField(
          comic.initialTitle,
          text: $comic.inputTitle,
          prompt: Text(verbatim: comic.initialTitle)
        )
        .padding(.vertical, 8)
      }
      .width(min: 300)

      TableColumn("Author") { comic in
        @Bindable var comic = comic
        TextField(
          comic.initialAuthor,
          text: $comic.inputAuthor,
          prompt: Text(verbatim: comic.initialAuthor)
        )
        .padding(.vertical, 8)
      }

    } rows: {
      ForEach(comics) { comic in
        TableRow(comic)
          .contextMenu {
            Button("Remove", systemImage: "trash", role: .destructive) {
              onRemove(comic.id)
            }
            .keyboardShortcut(.delete, modifiers: .command)
          }
      }
    }
    .tableStyle(.inset)
    .textFieldStyle(.plain)
  }
}

#Preview {
  ConverterComicsTable(
    comics: [
      .init(location: .temporaryDirectory, initialTitle: "Superman"),
      .init(location: .temporaryDirectory, initialTitle: "Spider-Man"),
    ],
    onRemove: { _ in }
  )
}

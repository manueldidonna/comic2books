//
//  Comic.swift
//  Comic2Books
//
//  Created by Manuel Di Donna on 18/07/24.
//

import Foundation
import Observation

@Observable
final class Comic: NSObject, Identifiable {
  let location: URL

  init(location: URL) {
    self.location = location
    inputTitle = location.deletingPathExtension().lastPathComponent
  }

  var inputTitle: String = ""
  var inputAuthor: String = ""
}

extension Comic {
  var defaultTitle: String {
    location.deletingPathExtension().lastPathComponent
  }

  var defaultAuthor: String { "Comic2Books" }

  var title: String {
    inputTitle.isEmpty ? defaultTitle : inputTitle
  }

  var author: String {
    inputAuthor.isEmpty ? defaultAuthor : inputAuthor
  }
}

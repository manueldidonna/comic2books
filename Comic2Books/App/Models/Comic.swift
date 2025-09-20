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
  let initialTitle: String
  let initialAuthor: String

  var inputTitle: String = ""
  var inputAuthor: String = ""

  init(location: URL, initialTitle: String, initialAuthor: String = "Comic2Books") {
    self.location = location
    self.initialTitle = initialTitle
    self.initialAuthor = initialAuthor
    self.inputTitle = initialTitle
    self.inputAuthor = initialAuthor
  }
}

extension Comic {
  convenience init(location: URL) {
    self.init(location: location, initialTitle: location.deletingPathExtension().lastPathComponent)
  }

  var title: String {
    inputTitle.isEmpty ? initialTitle : inputTitle
  }

  var author: String {
    inputAuthor.isEmpty ? initialAuthor : inputAuthor
  }
}

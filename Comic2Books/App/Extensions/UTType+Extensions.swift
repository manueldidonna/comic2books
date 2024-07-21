//
//  UTType+Extensions.swift
//  Comic2Books
//
//  Created by Manuel Di Donna on 18/07/24.
//

import Foundation
import UniformTypeIdentifiers

extension UTType {
  // static let cbr = UTType(mimeType: "application/x-rar")!
  static let cbr = UTType(filenameExtension: "cbr")!
  static let cbz = UTType(filenameExtension: "cbz")!
  static let rar = UTType(filenameExtension: "rar")!

  static let allowedComicTypes: [UTType] = [.cbz, .cbr, .zip, .rar, .pdf]
}

extension URL {
  var type: UTType? {
    try? resourceValues(forKeys: [.contentTypeKey]).contentType
  }
}

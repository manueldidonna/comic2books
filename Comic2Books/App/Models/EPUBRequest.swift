//
//  EPUBRequest.swift
//  Comic2Books
//
//  Created by Manuel Di Donna on 18/07/24.
//

import Foundation

struct EPUBRequest: Sendable, Equatable, Hashable {
  nonisolated struct Options: Hashable, Equatable, Sendable, Codable {
    var device: Device = Device.all.first!
    var useMangaReadingDirection: Bool = false
    var grayscale: Bool = false
    var losslessCompression: Bool = false
    var compressionQuality: Double = 85
    var resizeToFitDeviceSize: Bool = true
    var appleBooksCompatibility: Bool = false
    var sendToKindleCompatibility: Bool = true
    var autoSplitDoublePage: Bool = true
    var keepDoublePageIfSplit: Bool = true
    var hasCover: Bool = true
    var titlePage: Bool = true
    var improveContrastAutomatically: Bool = true
    var contrastReadjustement: Double = 0
  }

  let title: String
  let author: String
  let options: Options

  let inputURL: URL
}

extension EPUBRequest.Options {
  private nonisolated static let diskURL: URL = .applicationSupportDirectory.appending(
    path: "converter_options.json"
  )

  @concurrent
  func saveToDisk() async throws {
    let data = try JSONEncoder().encode(self)
    try data.write(to: Self.diskURL, options: .atomic)
  }

  @concurrent
  static func readFromDisk() async throws -> EPUBRequest.Options {
    guard FileManager.default.fileExists(atPath: diskURL.path) else {
      return EPUBRequest.Options()
    }

    let data = try Data(contentsOf: diskURL)
    let options = try JSONDecoder().decode(EPUBRequest.Options.self, from: data)
    return options
  }
}

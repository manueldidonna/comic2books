//
//  AppState.swift
//  Comic2Books
//
//  Created by Manuel Di Donna on 19/07/24.
//

import Algorithms
import Foundation
import Observation

@Observable
final class AppState {
  private(set) var importedComics: [Comic] = []

  var converterOptions = EPUBRequest.Options(
    device: .standard,
    useMangaReadingDirection: false,
    grayscale: false,
    losslessCompression: false,
    compressionQuality: 90,
    resizeToFitDeviceSize: true
  )

  func importComics(_ comics: [Comic]) {
    let currentComics = importedComics + comics
    importedComics = currentComics.uniqued(on: \.location)
  }

  func removeComic(with id: Comic.ID) {
    guard let index = importedComics.firstIndex(where: { $0.id == id }) else { return }
    importedComics.remove(at: index)
  }
}

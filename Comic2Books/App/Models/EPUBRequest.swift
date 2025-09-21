//
//  EPUBRequest.swift
//  Comic2Books
//
//  Created by Manuel Di Donna on 18/07/24.
//

import Foundation

struct EPUBRequest: Sendable, Equatable, Hashable {
  struct Options: Hashable, Equatable, Sendable {
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

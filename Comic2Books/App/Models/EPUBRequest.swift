//
//  EPUBRequest.swift
//  Comic2Books
//
//  Created by Manuel Di Donna on 18/07/24.
//

import Foundation

struct EPUBRequest: Sendable {
  static let outputDirectory: URL = .downloadsDirectory.appending(path: "Comic2Books")

  struct Options: Hashable, Equatable, Sendable {
    var device: Device = .standardResolution
    var useMangaReadingDirection: Bool = false
    var grayscale: Bool = false
    var losslessCompression: Bool = false
    var compressionQuality: Double = 85
    var resizeToFitDeviceSize: Bool = true
    var appleBooksCompatibility: Bool = false
    var autoSplitDoublePage: Bool = true
    var keepDoublePageIfSplit: Bool = true
    var hasCover: Bool = true
    var titlePage: Bool = true
    var improveContrastAutomatically: Bool = true
    var contrastReadjustement: Double = 0
  }

  private let commands: [String]
  private let destURL: URL

  init(comic: Comic, options: Options) {
    let script = Bundle.main.path(forResource: "go-comic-converter-arm", ofType: nil)!
    destURL = Self.outputDirectory.appending(path: comic.title + ".epub")
    commands = [
      script,
      options.appleBooksCompatibility
        ? "-applebookcompatibility"
        : "-autosplitdoublepage=\(options.autoSplitDoublePage) -keepdoublepageifsplitted=\(options.keepDoublePageIfSplit)",
      "-profile=\(options.device.code)",
      "-noblankimage=0",
      "-aspect-ratio=0",
      "-crop=0",
      "-strip",
      "-hascover=\(options.hasCover || options.appleBooksCompatibility)",
      "-titlepage=\(options.titlePage && !options.appleBooksCompatibility ? 1 : 0)",
      options.losslessCompression ? "-format=png" : "-format=jpeg -quality=\(max(0, min(100, Int(options.compressionQuality))))",
      "-manga=\(options.useMangaReadingDirection)",
      options.improveContrastAutomatically ? "-autocontrast" : "-autocontrast=false -contrast=\(max(-100, min(100, Int(options.contrastReadjustement))))",
      "-grayscale=\(options.grayscale ? 1 : 0)",
      "-title \"\(comic.title)\"",
      "-author \"\(comic.author)\"",
      !options.resizeToFitDeviceSize ? "-noresize" : "",
      "-output \"\(destURL.path(percentEncoded: false))\"",
      "-input \"\(comic.location.path(percentEncoded: false))\"",
      "-json",
    ]
  }

  func execute(onProgress: ((Double) -> Void)? = nil) async throws {
    try? FileManager.default.createDirectory(at: Self.outputDirectory, withIntermediateDirectories: true)
    let task = try bash(commands.joined(separator: " "))
    defer {
      if task.isRunning {
        task.terminate()
        deleteTempFiles()
      }
    }

    let output = task.standardOutput as! Pipe

    // Listen for progress
    let jsonDecoder = JSONDecoder()
    let progresses = output.bytesToRead.lines.compactMap { line -> Double? in
      guard !line.isEmpty else { return nil }
      guard let data = line.data(using: .utf8) else { return nil }
      guard let payload = try? jsonDecoder.decode(ConversionProgressPayload.self, from: data) else { return nil }
      return payload.progress
    }

    for try await progress in progresses {
      onProgress?(progress)
    }
  }

  private func deleteTempFiles() {
    let fm = FileManager.default
    guard let files = try? fm.contentsOfDirectory(at: Self.outputDirectory, includingPropertiesForKeys: [.pathKey]) else { return }
    for file in files where file.path().hasSuffix(".tmp") {
      try? fm.removeItem(at: file)
    }
  }
}

private extension EPUBRequest {
  struct ConversionProgressPayload: Codable {
    private let data: Data
    private struct Data: Codable {
      let progress: Progress
      let steps: Progress
      struct Progress: Codable {
        let current: Int
        let total: Int
      }
    }

    var progress: Double {
      guard data.steps.current == 1 else { return 1 }
      let stepProgress = Double(data.progress.current) / Double(data.progress.total)
      return 0.95 * stepProgress
    }
  }
}

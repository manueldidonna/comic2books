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
    var device: Device
    var useMangaReadingDirection: Bool
    var grayscale: Bool
    var losslessCompression: Bool
    var compressionQuality: Double
    var resizeToFitDeviceSize: Bool
  }

  private let commands: [String]
  private let tempURL: URL
  private let destURL: URL

  init(comic: Comic, options: Options) {
    let script = Bundle.main.path(forResource: "go-comic-converter-arm", ofType: nil)!
    tempURL = URL.temporaryDirectory.appending(path: comic.title + ".epub")
    destURL = Self.outputDirectory.appending(path: comic.title + ".epub")
    commands = [
      script,
      "-applebookcompatibility",
      "-profile=\(options.device.id)",
      "-autocontrast",
      "-noblankimage=0",
      "-aspect-ratio=0",
      "-crop=0",
      "-strip",
      "-titlepage=0",
      options.losslessCompression ? "-format=png" : "-format=jpeg -quality=\(Int(options.compressionQuality))",
      "-manga=\(options.useMangaReadingDirection ? 1 : 0)",
      "-grayscale=\(options.grayscale ? 1 : 0)",
      "-title \"\(comic.title)\"",
      "-author \"\(comic.author)\"",
      !options.resizeToFitDeviceSize ? "-noresize" : "",
      "-output \"\(tempURL.path(percentEncoded: false))\"",
      "-input \"\(comic.location.path(percentEncoded: false))\"",
      "-json",
    ]
  }

  func execute(onProgress: ((Double) -> Void)? = nil) async throws {
    // Execute script
    // let bash = Process.bash()
    // let output = Pipe()
    // bash.standardOutput = output
    // try bash.run(command: commands.joined(separator: " "))

    let task = try bash(commands.joined(separator: " "))
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

    // Move epub to output directory
    do {
      try? FileManager.default.createDirectory(at: Self.outputDirectory, withIntermediateDirectories: true)
      try FileManager.default.moveItem(at: tempURL, to: destURL)
    } catch {
      try? FileManager.default.removeItem(at: tempURL)
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

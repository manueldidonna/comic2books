//
//  EPUBConverter.swift
//  Comic2Books
//
//  Created by Manuel Di Donna on 20/09/25.
//

import Foundation

actor EPUBConverter {
  enum ConversionError: Error, Sendable, Equatable {
    case conversionFailed(String)
    case directoryAccessDenied
  }

  func convert(request: EPUBRequest, saveTo destinationURL: URL) async throws {
    let outputURL = URL.temporaryDirectory.appending(path: request.title + ".epub")

    let arguments = getScriptArguments(from: request, outputURL: outputURL)
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/bash")
    process.standardOutput = Pipe()

    let errorPipe = Pipe()
    process.standardError = errorPipe

    defer {
      if process.isRunning {
        print("Conversion terminated while running")
        process.terminate()
        deleteTempFile(at: outputURL)
      }
    }

    let command = "\(Bundle.main.goComicConverterPath) \(arguments.joined(separator: " "))"
    print(command)
    process.arguments = ["-c", command]
    try process.run()

    while process.isRunning {
      try Task.checkCancellation()
      try await Task.sleep(for: .seconds(1))
    }

    let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
    let errorOutput = String(data: errorData, encoding: .utf8) ?? ""

    if process.terminationStatus != 0 {
      let message = """
        GoComicConverter failed with exit code \(process.terminationStatus)
        \(errorOutput)
        """

      throw NSError(
        domain: "GoComicConverterError",
        code: Int(process.terminationStatus),
        userInfo: [NSLocalizedDescriptionKey: message]
      )
    }

    try moveFile(
      from: outputURL,
      to: destinationURL.appending(path: outputURL.lastPathComponent)
    )
  }

  private func moveFile(from sourceURL: URL, to destinationURL: URL) throws {
    let fileManager = FileManager.default

    if fileManager.fileExists(atPath: destinationURL.path) {
      try fileManager.removeItem(at: destinationURL)
    }

    try fileManager.moveItem(at: sourceURL, to: destinationURL)
  }

  private func deleteTempFile(at location: URL) {
    try? FileManager.default.removeItem(atPath: location.path() + ".tmp")
  }

  private func getScriptArguments(from request: EPUBRequest, outputURL: URL) -> [String] {
    let options = request.options

    var args: [String] = []

    // MARK: - Apple Books & Double Page
    if options.appleBooksCompatibility {
      args.append("-applebookcompatibility")
    } else {
      args.append("-autosplitdoublepage=\(options.autoSplitDoublePage)")
      if options.autoSplitDoublePage {
        args.append("-keepdoublepageifsplit=\(options.keepDoublePageIfSplit)")
      }
    }

    // MARK: - Device
    args.append("-profile=\(options.device.code)")
    args.append("-noblankimage=0")
    args.append("-aspect-ratio=0")
    args.append("-crop=0")
    args.append("-strip")

    if options.sendToKindleCompatibility,
      !options.appleBooksCompatibility,
      options.device.group == "kindle"
    {
      args.append("-limitmb=200")
    }

    // MARK: - Cover & Title
    args.append("-hascover=\(options.hasCover || options.appleBooksCompatibility)")
    args.append("-titlepage=\(options.titlePage && !options.appleBooksCompatibility ? 1 : 0)")
    args.append("-title='\(request.title)'")
    args.append("-author='\(request.author)'")

    // MARK: - Compression
    if options.losslessCompression {
      args.append("-format=png")
    } else {
      args.append("-format=jpeg")
      args.append("-quality=\(max(0, min(100, Int(options.compressionQuality))))")
    }

    // MARK: - Reading & Contrast
    args.append("-manga=\(options.useMangaReadingDirection)")

    if options.improveContrastAutomatically {
      args.append("-autocontrast")
    } else {
      args.append("-autocontrast=false")
      args.append("-contrast=\(max(-100, min(100, Int(options.contrastReadjustement))))")
    }

    args.append("-grayscale=\(options.grayscale ? 1 : 0)")

    // MARK: - Resize
    if !options.resizeToFitDeviceSize {
      args.append("-noresize")
    }

    // MARK: - Input / Output
    args.append("-input='\(request.inputURL.path(percentEncoded: false))'")
    args.append("-output='\(outputURL.path(percentEncoded: false))'")

    // MARK: - Extra
    args.append("-quiet")

    return args
  }
}

// MARK: - Script Path

extension Bundle {
  fileprivate var goComicConverterPath: String {
    var utsname = utsname()
    uname(&utsname)
    let machine = withUnsafePointer(to: &utsname.machine) {
      $0.withMemoryRebound(to: CChar.self, capacity: Int(_SYS_NAMELEN)) {
        String(cString: $0)
      }
    }
    let archSuffix = machine == "arm64" ? "silicon" : "intel"
    return path(forResource: "go-comic-converter-\(archSuffix)", ofType: nil)!
  }
}

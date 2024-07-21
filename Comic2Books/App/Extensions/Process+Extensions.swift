//
//  Process+Bash.swift
//  Comic2Books
//
//  Created by Manuel Di Donna on 18/07/24.
//

import Foundation

/// Executes a shell command with `/bin/bash`.
/// - Parameter command: The command to execute.
/// - Returns: The standard output from executing `command`.
@discardableResult
func bash(_ command: String) throws -> Process {
  let process = Process.bash()
  process.standardOutput = Pipe()
  try process.run(command: command)
  return process
}

extension Process {
  static func bash() -> Process {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/bash")
    return process
  }

  func run(command: String) throws {
    arguments = ["-c", command]
    try run()
  }
}

extension Pipe {
  var bytesToRead: FileHandle.AsyncBytes {
    fileHandleForReading.bytes
  }
}

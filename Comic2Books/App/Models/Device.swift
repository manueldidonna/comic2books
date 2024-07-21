//
//  Device.swift
//  Comic2Books
//
//  Created by Manuel Di Donna on 18/07/24.
//

import Foundation

struct Device: Hashable, Equatable, Sendable, Identifiable {
  let id: String
  let group: String?
  let name: String
  let resolution: String
}

extension Device {
  static func get(inGroup group: String?) -> [Device] {
    return all.filter { $0.group == group || $0.group == nil }
  }

  private static let all: [Device] = [
    .standard, .high, // nil
  ]
}

extension Device {
  static let standard = Device(id: "SR", group: nil, name: "Standard", resolution: "1200x1920")
  static let high = Device(id: "HR", group: nil, name: "High", resolution: "2400x3840")
}

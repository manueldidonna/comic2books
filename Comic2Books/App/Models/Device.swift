//
//  Device.swift
//  Comic2Books
//
//  Created by Manuel Di Donna on 18/07/24.
//

import Foundation

struct Device: Hashable, Equatable, Sendable, Identifiable {
  let code: String
  let group: String?
  let name: String
  let width: Int
  let height: Int

  var resolution: String {
    "\(width)x\(height)"
  }

  var id: String { name }
}

extension Device {
  static func get(inGroup group: String?) -> [Device] {
    return all.filter { $0.group == group || $0.group == nil }
  }

  static let all: [Device] = [
    .standard, .high, // Tablet
    .kindle1, .kindle11, .kindle2, .kindleKeyboardTouch, .kindle, .kindleDXDXG,
    .kindlePaperwhite12, .kindlePaperwhite34VoyageOasis, .kindlePaperwhite5SignatureEdition, .kindleOasis23, .kindleScribe,
  ]
}

extension Device {
  // MARK: Tablet

  static let standard = Device(code: "SR", group: nil, name: "Standard Res", width: 1200, height: 1920)
  static let high = Device(code: "HR", group: nil, name: "High Res", width: 2400, height: 3840)

  // MARK: Kindle

  static let kindle1 = Device(code: "K1", group: "kindle", name: "Kindle 1", width: 600, height: 670)
  static let kindle11 = Device(code: "K11", group: "kindle", name: "Kindle 11", width: 1072, height: 1448)
  static let kindle2 = Device(code: "K2", group: "kindle", name: "Kindle 2", width: 600, height: 670)
  static let kindleKeyboardTouch = Device(code: "K34", group: "kindle", name: "Kindle Keyboard/Touch", width: 600, height: 800)
  static let kindle = Device(code: "K578", group: "kindle", name: "Kindle", width: 600, height: 800)
  static let kindleDXDXG = Device(code: "KDX", group: "kindle", name: "Kindle DX/DXG", width: 824, height: 1000)
  static let kindlePaperwhite12 = Device(code: "KPW", group: "kindle", name: "Kindle Paperwhite 1/2", width: 758, height: 1024)
  static let kindlePaperwhite34VoyageOasis = Device(code: "KV", group: "kindle", name: "Kindle Paperwhite 3/4/Voyage/Oasis", width: 1072, height: 1448)
  static let kindlePaperwhite5SignatureEdition = Device(code: "KPW5", group: "kindle", name: "Kindle Paperwhite 5/Signature Edition", width: 1236, height: 1648)
  static let kindleOasis23 = Device(code: "KO", group: "kindle", name: "Kindle Oasis 2/3", width: 1264, height: 1680)
  static let kindleScribe = Device(code: "KS", group: "kindle", name: "Kindle Scribe", width: 1860, height: 2480)
}

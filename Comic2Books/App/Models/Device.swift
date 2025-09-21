//
//  Device.swift
//  Comic2Books
//
//  Created by Manuel Di Donna on 18/07/24.
//

import Foundation

nonisolated struct Device: Hashable, Equatable, Sendable, Identifiable, Codable {
  nonisolated enum Group: String, Codable, Hashable, Equatable, Sendable, CaseIterable, Comparable {
    static func < (lhs: Device.Group, rhs: Device.Group) -> Bool {
      lhs.rawValue < rhs.rawValue
    }

    case kindle
    case kobo
    case remarkable
    case tablet
  }

  let code: String
  let group: Group
  let name: String
  let width: Int
  let height: Int

  var resolution: String {
    "\(width)x\(height)"
  }

  var id: String { code }
}

extension Device {
  nonisolated static let all: [Device] = [
    Device(
      code: "SR",
      group: .tablet,
      name: "Standard Res",
      width: 1200,
      height: 1920
    ),
    Device(
      code: "HR",
      group: .tablet,
      name: "High Res",
      width: 2400,
      height: 3840
    ),

    // Kindle
    Device(code: "K1", group: .kindle, name: "Kindle 1", width: 600, height: 670),
    Device(code: "K11", group: .kindle, name: "Kindle 11", width: 1072, height: 1448),
    Device(code: "K2", group: .kindle, name: "Kindle 2", width: 600, height: 670),
    Device(code: "K34", group: .kindle, name: "Kindle Keyboard/Touch", width: 600, height: 800),
    Device(code: "K578", group: .kindle, name: "Kindle", width: 600, height: 800),
    Device(code: "KDX", group: .kindle, name: "Kindle DX/DXG", width: 824, height: 1000),
    Device(code: "KPW", group: .kindle, name: "Kindle Paperwhite 1/2", width: 758, height: 1024),
    Device(
      code: "KV",
      group: .kindle,
      name: "Kindle Paperwhite 3/4/Voyage/Oasis",
      width: 1072,
      height: 1448
    ),
    Device(
      code: "KPW5",
      group: .kindle,
      name: "Kindle Paperwhite 5/Signature Edition",
      width: 1236,
      height: 1648
    ),
    Device(code: "KO", group: .kindle, name: "Kindle Oasis 2/3", width: 1264, height: 1680),
    Device(code: "KS", group: .kindle, name: "Kindle Scribe", width: 1860, height: 2480),

    // Kobo
    Device(code: "KoMT", group: .kobo, name: "Kobo Mini/Touch", width: 600, height: 800),
    Device(code: "KoG", group: .kobo, name: "Kobo Glo", width: 768, height: 1024),
    Device(code: "KoGHD", group: .kobo, name: "Kobo Glo HD", width: 1072, height: 1448),
    Device(code: "KoA", group: .kobo, name: "Kobo Aura", width: 758, height: 1024),
    Device(code: "KoAHD", group: .kobo, name: "Kobo Aura HD", width: 1080, height: 1440),
    Device(code: "KoAH2O", group: .kobo, name: "Kobo Aura H2O", width: 1080, height: 1430),
    Device(code: "KoAO", group: .kobo, name: "Kobo Aura ONE", width: 1404, height: 1872),
    Device(code: "KoN", group: .kobo, name: "Kobo Nia", width: 758, height: 1024),
    Device(
      code: "KoC",
      group: .kobo,
      name: "Kobo Clara HD/Kobo Clara 2E",
      width: 1072,
      height: 1448
    ),
    Device(
      code: "KoL",
      group: .kobo,
      name: "Kobo Libra H2O/Kobo Libra 2",
      width: 1264,
      height: 1680
    ),
    Device(code: "KoF", group: .kobo, name: "Kobo Forma", width: 1440, height: 1920),
    Device(code: "KoS", group: .kobo, name: "Kobo Sage", width: 1440, height: 1920),
    Device(code: "KoE", group: .kobo, name: "Kobo Elipsa", width: 1404, height: 1872),

    // reMarkable
    Device(code: "RM1", group: .remarkable, name: "reMarkable 1", width: 1404, height: 1872),
    Device(code: "RM2", group: .remarkable, name: "reMarkable 2", width: 1404, height: 1872),
  ]
}

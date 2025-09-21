//
//  ConvertSettingsView.swift
//  Comic2Books
//
//  Created by Manuel Di Donna on 20/09/25.
//

import Algorithms
import SwiftUI

struct ConvertSettingsView: View {
  @Environment(AppState.self) private var appState

  @State private var converting = false
  @State private var openOutputDirectory = false

  var body: some View {
    @Bindable var appState = appState
    Form {
      Section {
        Toggle(isOn: $appState.converterOptions.appleBooksCompatibility) {
          Text("\(Image(systemName: "apple.logo")) Books")
          Text("Export in a format compatible with Apple Books")
        }
      }
      Section {
        Toggle(isOn: $appState.converterOptions.useMangaReadingDirection) {
          Text("Manga")
          Text("Set reading direction to Right to Left")
        }
        if !appState.converterOptions.appleBooksCompatibility {
          Toggle(isOn: $appState.converterOptions.hasCover) {
            Text("Has Cover")
            Text("The first page will be used as a cover")
          }
          Toggle(isOn: $appState.converterOptions.titlePage) {
            Text("Title Page")
            Text("Show title on the first page")
          }

          Toggle(isOn: $appState.converterOptions.autoSplitDoublePage) {
            Text("Split Double Page")
            Text("Split page when width > height")
          }
          if appState.converterOptions.autoSplitDoublePage {
            Toggle(isOn: $appState.converterOptions.keepDoublePageIfSplit) {
              Text("Keep Double Page")
              Text("Keep double page if split")
            }
          }
        }
      }

      Section {
        DevicePicker(selection: $appState.converterOptions.device)
        Toggle(isOn: $appState.converterOptions.resizeToFitDeviceSize) {
          Text("Resize")
          Text("Reduce image size if exceed device size")
        }

        Picker(selection: $appState.converterOptions.losslessCompression) {
          Text("Lossless").tag(true)
          Text("Lossy").tag(false)
        } label: {
          Text("Compression")
        }
        if !appState.converterOptions.losslessCompression {
          Stepper(value: $appState.converterOptions.compressionQuality, in: 70 ... 100, step: 1, format: .number) {
            Text("Quality")
            Text("Degree of loss in the compression process")
          }
        }
        if appState.converterOptions.device.group == .kindle && !appState.converterOptions.appleBooksCompatibility {
          Toggle(isOn: $appState.converterOptions.sendToKindleCompatibility) {
            Text("SendToKindle")
            Text("Limit output to 200MB for upload via SendToKindle")
          }
        }
      }

      Section {
        Toggle(isOn: $appState.converterOptions.grayscale) {
          Text("Grayscale")
          Text("Ideal for eInk devices")
        }
        Toggle(isOn: $appState.converterOptions.improveContrastAutomatically) {
          Text("Auto Contrast")
          Text("Improve contrast automatically")
        }
        if !appState.converterOptions.improveContrastAutomatically {
          Stepper(value: $appState.converterOptions.contrastReadjustement, in: -100 ... 100, step: 1, format: .number) {
            Text("Contrast readjustement")
          }
        }
      }
    }
    .formStyle(.grouped)
  }
}

private struct DevicePicker: View {
  @Binding var selection: Device
  
  private static let devices = Device.all.grouped(by: \.group).sorted(using: KeyPathComparator(\.key))

  var body: some View {
    Picker(selection: $selection) {
      ForEach(Self.devices, id: \.key) { group, devices in
        Section(group.rawValue.uppercased()) {
          ForEach(devices) { device in
            Text(device.name).tag(device)
          }
        }
      }
    } label: {
      Text("Device")
      Text(selection.resolution)
    }
  }
}

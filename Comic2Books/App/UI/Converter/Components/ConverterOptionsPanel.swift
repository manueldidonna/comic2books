//
//  ConvertOptionsPanel.swift
//  Comic2Books
//
//  Created by Manuel Di Donna on 18/07/24.
//

import OSLog
import SwiftUI

struct ConverterOptionsPanel: View {
  @Environment(AppState.self) private var appState

  @State private var converting = false
  @State private var openOutputDirectory = false

  var body: some View {
    @Bindable var appState = appState
    Form {
      Section {
        Toggle(isOn: $appState.converterOptions.useMangaReadingDirection) {
          Text("Manga")
          Text("Set reading direction to Right to Left")
        }
      }
      Section {
        Picker(selection: $appState.converterOptions.device) {
          ForEach(Device.get(inGroup: nil)) { device in
            Text(device.name).tag(device)
          }
        } label: {
          Text("Resolution")
          Text(appState.converterOptions.device.resolution)
        }
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
        Toggle(isOn: $appState.converterOptions.grayscale) {
          Text("Grayscale")
          Text("Ideal for eInk devices")
        }
      }
    }
    .formStyle(.grouped)
    .safeAreaInset(edge: .bottom) {
      ConvertButton()
    }
    .frame(width: 280)
  }
}

#Preview {
  ConverterOptionsPanel()
    .environment(AppState())
}

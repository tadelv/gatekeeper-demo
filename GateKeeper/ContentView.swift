//
//  ContentView.swift
//  GateKeeper
//
//  Created by Vid Tadel on 31/07/2023.
//

import SwiftUI
import SwiftUINavigation

final class ContentViewModel: ObservableObject {
  enum Destination {
    case sheet
    case detail
  }

  @Published var destination: Destination?
}

struct ContentView: View {
  @ObservedObject var model: ContentViewModel

  var body: some View {
    NavigationStack {
      VStack {
        Image(systemName: "globe")
          .imageScale(.large)
          .foregroundStyle(.tint)
        Text("Hello, world!")
        Button("Go to detail") {
          model.destination = .detail
        }
        Button("Go to sheet") {
          model.destination = .sheet
        }
      }
      .padding()
      .navigationTitle("Root")
      .navigationDestination(
        unwrapping: $model.destination,
        case: /ContentViewModel.Destination.detail
      ) { _ in
        Text("Drill down")
      }
      .sheet(
        unwrapping: $model.destination,
        case: /ContentViewModel.Destination.sheet
      ) { _ in
        Text("In sheet")
      }
    }
  }
}

#Preview {
  ContentView(model: ContentViewModel())
}

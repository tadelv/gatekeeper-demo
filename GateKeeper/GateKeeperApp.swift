//
//  GateKeeperApp.swift
//  GateKeeper
//
//  Created by Vid Tadel on 31/07/2023.
//

import SwiftUI

@main
struct GateKeeperApp: App {
  let client = LoginStatusClient.previewValue
  let contentViewModel = ContentViewModel()

  var body: some Scene {
    WindowGroup {
      GateKeeperContainer(
        model: GateKeeperModel(
          statusClient: client,
          processDeeplink: { _ in
            contentViewModel.destination = .detail
          }
        )
      ) {
          VStack {
            Text("Inactive")
            Button("Go to Logged out") {
              client.changeStatus(.loggedOut)
            }
          }
          .font(.title)
        } loggedOutcontent: {
          VStack {
            Text("Logged out")
            Button("Go to logged in") {
              client.changeStatus(.loggedIn)
            }
          }
          .font(.title)
        } loggedInContent: {
          VStack {
            Text("Logged in")
            Button("Log out") {
              client.changeStatus(.loggedOut)
            }
            Button("Deactivate") {
              client.changeStatus(.inactive)
            }
            ContentView(model: contentViewModel)
          }
        }
    }
  }
}

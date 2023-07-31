//
//  GateKeeper.swift
//  GateKeeper
//
//  Created by Vid Tadel on 31/07/2023.
//

import Foundation
import SwiftUI

enum LoginStatus {
  case inactive
  case loggedOut
  case loggedIn
}

final class GateKeeperModel: ObservableObject {
  init(statusClient: LoginStatusClient, status: LoginStatus = .inactive) {
    self.status = status
    self.statusClient = statusClient
  }
  
  @Published var status: LoginStatus = .inactive

  let statusClient: LoginStatusClient

  func awake() async {
    await hookStatus()
  }

  @MainActor
  func hookStatus() async {
    for await newStatus in statusClient.loginStatus() {
      self.status = newStatus
    }
  }
}

struct GateKeeperContainer<
  InactiveContent: View,
  LoggedOutContent: View,
  LoggedInContent: View
>: View {
  @ObservedObject var model: GateKeeperModel

  let inactiveContent: () -> InactiveContent
  let loggedOutcontent: () -> LoggedOutContent
  let loggedInContent: () -> LoggedInContent

  var body: some View {
    Group {
      switch model.status {
      case .inactive:
        inactiveContent()
      case .loggedOut:
        loggedOutcontent()
      case .loggedIn:
        loggedInContent()
      }
    }
    .task {
      await model.awake()
    }
  }
}

struct GateKeeperPreview: PreviewProvider {
  static var previews: some View {
    let client = LoginStatusClient.previewValue
    return GateKeeperContainer(
      model: GateKeeperModel(statusClient: client)) {
        VStack {
          Text("Inactive")
          Button("Go to Logged out") {
            client.changeStatus(.loggedOut)
          }
        }
      } loggedOutcontent: {
        VStack {
          Text("Logged out")
          Button("Go to logged in") {
            client.changeStatus(.loggedIn)
          }
        }
      } loggedInContent: {
        VStack {
          Text("Logged in")
          Button("Log out") {
            client.changeStatus(.loggedOut)
          }
          Button("Deactivate") {
            client.changeStatus(.inactive)
          }
        }
      }
      .font(.title)
  }
}

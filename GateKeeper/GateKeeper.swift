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
  init(
    statusClient: LoginStatusClient,
    processDeeplink: @escaping (URL) -> Void,
    status: LoginStatus = .inactive
  ) {
    self.status = status
    self.statusClient = statusClient
    self.processDeeplink = processDeeplink
  }
  
  @Published var status: LoginStatus = .inactive

  let statusClient: LoginStatusClient

  var urlCache: [URL] = []
  let processDeeplink: (URL) -> Void

  func awake() async {
    await hookStatus()
  }

  @MainActor
  func hookStatus() async {
    for await newStatus in statusClient.loginStatus() {
      self.status = newStatus
      if newStatus == .loggedIn,
         let url = urlCache.last {
        urlCache = []
        sendDeeplink(url)
      }
    }
  }

  func processUrl(_ url: URL) {
    guard status == .loggedIn else {
      urlCache.append(url)
      return
    }
    sendDeeplink(url)
  }

  func sendDeeplink(_ url: URL) {
    Task { @MainActor in
      processDeeplink(url)
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
    .onOpenURL { url in
      model.processUrl(url)
    }
  }
}

#Preview {
  let client = LoginStatusClient.previewValue
  return GateKeeperContainer(
    model: GateKeeperModel(
      statusClient: client,
      processDeeplink: { _ in }
    )
  ) {
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

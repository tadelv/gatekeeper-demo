//
//  GateKeeperTests.swift
//  GateKeeperTests
//
//  Created by Vid Tadel on 31/07/2023.
//

import XCTest
@testable import GateKeeper

@MainActor
final class GateKeeperModelTests: XCTestCase {
  func testProcessURL() async {
    let client = LoginStatusClient.previewValue
    let exp = expectation(description: "calls process deeplink")

    let model = GateKeeperModel(statusClient: client) { _ in
      exp.fulfill()
    }

    Task {
      await model.awake()
    }

    model.processUrl(URL(string: "https://www.example.com")!)

    client.changeStatus(.loggedIn)

    await fulfillment(of: [exp], timeout: 2)
  }

  func testProcessURLLoggedIn() async {
    let client = LoginStatusClient.previewValue
    let exp = expectation(description: "calls process deeplink")

    let model = GateKeeperModel(statusClient: client) { _ in
      exp.fulfill()
    }

    Task {
      await model.awake()
    }

    client.changeStatus(.loggedIn)

    model.processUrl(URL(string: "https://www.example.com")!)

    await fulfillment(of: [exp], timeout: 2)
  }
}

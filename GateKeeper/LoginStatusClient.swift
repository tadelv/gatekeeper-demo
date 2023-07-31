//
//  LoginStatusClient.swift
//  GateKeeper
//
//  Created by Vid Tadel on 31/07/2023.
//

import Foundation

struct LoginStatusClient {
  var loginStatus: () -> AsyncStream<LoginStatus>
  var changeStatus: (LoginStatus) -> Void
}

extension LoginStatusClient {
  static var previewValue: LoginStatusClient {
    var continuation: AsyncStream<LoginStatus>.Continuation?
    let stream = AsyncStream<LoginStatus> {
      continuation = $0
    }

    return LoginStatusClient {
      stream
    } changeStatus: { newStatus in
      continuation?.yield(newStatus)
    }

  }
}

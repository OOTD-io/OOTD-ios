//
//  AppRouter.swift
//  OOTD-swift
//
//  Created by Jules on 9/3/25.
//

import SwiftUI

extension Notification.Name {
    static let didReceivePasswordRecoveryURL = Notification.Name("didReceivePasswordRecoveryURL")
}

class AppRouter: ObservableObject {
    @Published var showResetPasswordView = false
}

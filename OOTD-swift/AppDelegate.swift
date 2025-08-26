//
//  AppDelegate.swift
//  OOTD-swift
//
//  Created by Rahqi Sarsour on 5/27/25.
//

import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      
      let user = supabase.auth.currentUser

    return true
  }
}

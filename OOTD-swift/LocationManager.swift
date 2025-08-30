//
//  LocationManager.swift
//  OOTD-swift
//
//  Created by Riyad Sarsour on 8/30/25.
//

import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus

    override init() {
        self.authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestLocationPermission() {
        print("[LocationManager] requestLocationPermission called.")
        print("[LocationManager] Current status: \(manager.authorizationStatus.rawValue)")
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            print("[LocationManager] Permission already granted. Requesting location.")
            manager.requestLocation()
        case .notDetermined:
            print("[LocationManager] Permission not determined. Requesting authorization.")
            manager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            print("[LocationManager] Permission denied or restricted.")
            break
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("[LocationManager] Did update locations: \(locations.first?.coordinate.latitude ?? 0),\(locations.first?.coordinate.longitude ?? 0)")
        location = locations.first
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.authorizationStatus = manager.authorizationStatus
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }
}

//
//  LocationManager.swift
//  Paku
//
//  Created by Kyle Bashour on 10/6/20.
//

import Combine
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {

    @Published var status: CLAuthorizationStatus

    static let shared = LocationManager()

    typealias Callback = (Result<CLLocation, Error>) -> Void

    private var callbacks: [Callback] = []
    private let manager = CLLocationManager()

    override init() {
        status = manager.authorizationStatus

        super.init()

        manager.delegate = self
    }

    func requestPermission() {
        manager.requestAlwaysAuthorization()
    }

    func requestLocation(callback: @escaping Callback) {
        callbacks.append(callback)
        manager.requestLocation()
    }

    // MARK: CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        status = manager.authorizationStatus
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NSLog("Location manager did fail with error %@", error.localizedDescription)

        let callbacks = self.callbacks
        self.callbacks.removeAll()

        for callback in callbacks {
            callback(.failure(error))
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!

        let callbacks = self.callbacks
        self.callbacks.removeAll()

        for callback in callbacks {
            callback(.success(location))
        }
    }
}

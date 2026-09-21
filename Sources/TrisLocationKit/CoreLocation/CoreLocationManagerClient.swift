//
//  CoreLocationManagerClient.swift
//  TrisLocationKit
//
//  Created by COMATOKI on 2026-09-22.
//

import Foundation
@preconcurrency import CoreLocation

@MainActor
protocol CoreLocationManagerClient: AnyObject {

    var authorizationStatus: CLAuthorizationStatus { get }

    var onAuthorizationChanged: ((CLAuthorizationStatus) -> Void)? { get set }

    var onLocationsUpdated: (([CLLocation]) -> Void)? { get set }

    var onFailure: ((any Error) -> Void)? { get set }

    func requestWhenInUseAuthorization()

    func requestAlwaysAuthorization()

    func requestLocation()

    func startUpdatingLocation()

    func stopUpdatingLocation()
}

@MainActor
final class SystemCoreLocationManagerClient: NSObject,
                                             CoreLocationManagerClient {

    private let locationManager: CLLocationManager

    var onAuthorizationChanged: ((CLAuthorizationStatus) -> Void)?

    var onLocationsUpdated: (([CLLocation]) -> Void)?

    var onFailure: ((any Error) -> Void)?

    override init() {
        locationManager = CLLocationManager()

        super.init()

        locationManager.delegate = self
    }

    var authorizationStatus: CLAuthorizationStatus {
        locationManager.authorizationStatus
    }

    func requestWhenInUseAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    func requestAlwaysAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }

    func requestLocation() {
        locationManager.requestLocation()
    }

    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
}

extension SystemCoreLocationManagerClient:
    @MainActor CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(
        _ manager: CLLocationManager
    ) {
        onAuthorizationChanged?(
            manager.authorizationStatus
        )
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        onLocationsUpdated?(locations)
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: any Error
    ) {
        onFailure?(error)
    }
}

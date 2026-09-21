//
//  MockCoreLocationManagerClient.swift
//  TrisLocationKit
//
//  Created by COMATOKI on 2026-09-22.
//

import CoreLocation

@testable import TrisLocationKit

@MainActor
final class MockCoreLocationManagerClient: CoreLocationManagerClient {

    var authorizationStatus: CLAuthorizationStatus

    var onAuthorizationChanged: ((CLAuthorizationStatus) -> Void)?
    var onLocationsUpdated: (([CLLocation]) -> Void)?
    var onFailure: ((any Error) -> Void)?

    private(set) var requestWhenInUseAuthorizationCallCount = 0
    private(set) var requestAlwaysAuthorizationCallCount = 0
    private(set) var requestLocationCallCount = 0
    private(set) var startUpdatingLocationCallCount = 0
    private(set) var stopUpdatingLocationCallCount = 0

    init(
        authorizationStatus: CLAuthorizationStatus = .notDetermined
    ) {
        self.authorizationStatus = authorizationStatus
    }

    func requestWhenInUseAuthorization() {
        requestWhenInUseAuthorizationCallCount += 1
    }

    func requestAlwaysAuthorization() {
        requestAlwaysAuthorizationCallCount += 1
    }

    func requestLocation() {
        requestLocationCallCount += 1
    }

    func startUpdatingLocation() {
        startUpdatingLocationCallCount += 1
    }

    func stopUpdatingLocation() {
        stopUpdatingLocationCallCount += 1
    }

    func sendAuthorizationStatus(
        _ status: CLAuthorizationStatus
    ) {
        authorizationStatus = status
        onAuthorizationChanged?(status)
    }

    func sendLocations(
        _ locations: [CLLocation]
    ) {
        onLocationsUpdated?(locations)
    }

    func sendFailure(
        _ error: any Error
    ) {
        onFailure?(error)
    }
}

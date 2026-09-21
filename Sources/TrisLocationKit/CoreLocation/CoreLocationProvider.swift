//
//  CoreLocationProvider.swift
//  TrisLocationKit
//
//  Created by COMATOKI on 2026-09-21.
//

import Foundation
@preconcurrency import CoreLocation

@MainActor
public final class CoreLocationProvider: NSObject, LocationProviding {

    private let locationManager: CLLocationManager

    private var authorizationContinuations: [
        CheckedContinuation<LocationAuthorizationStatus, Never>
    ] = []

    private var currentLocationContinuations: [
        CheckedContinuation<LocationPoint, any Error>
    ] = []

    private var locationStreamContinuations: [
        UUID: AsyncThrowingStream<LocationPoint, Error>.Continuation
    ] = [:]

    private var isUpdatingLocation = false

    public override init() {
        locationManager = CLLocationManager()

        super.init()

        locationManager.delegate = self
    }

    public var authorizationStatus: LocationAuthorizationStatus {
        locationManager.authorizationStatus.locationAuthorizationStatus
    }

    public func requestWhenInUseAuthorization() async -> LocationAuthorizationStatus {
        guard authorizationStatus == .notDetermined else {
            return authorizationStatus
        }

        return await withCheckedContinuation { continuation in
            authorizationContinuations.append(continuation)

            if authorizationContinuations.count == 1 {
                locationManager.requestWhenInUseAuthorization()
            }
        }
    }

    public func requestAlwaysAuthorization() {
        switch authorizationStatus {
        case .notDetermined,
             .authorizedWhenInUse:
            locationManager.requestAlwaysAuthorization()

        case .restricted,
             .denied,
             .authorizedAlways,
             .unknown:
            break
        }
    }

    public func requestCurrentLocation() async throws -> LocationPoint {
        try validateAuthorization()

        return try await withCheckedThrowingContinuation { continuation in
            currentLocationContinuations.append(continuation)

            if !isUpdatingLocation,
               currentLocationContinuations.count == 1 {
                locationManager.requestLocation()
            }
        }
    }

    public func locationUpdates() -> AsyncThrowingStream<LocationPoint, Error> {
        AsyncThrowingStream { continuation in
            do {
                try validateAuthorization()
            } catch {
                continuation.finish(throwing: error)
                return
            }

            let id = UUID()

            locationStreamContinuations[id] = continuation

            continuation.onTermination = { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.removeLocationStream(id: id)
                }
            }

            guard !isUpdatingLocation else {
                return
            }

            isUpdatingLocation = true
            locationManager.startUpdatingLocation()
        }
    }

    public func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()

        isUpdatingLocation = false

        let continuations = locationStreamContinuations.values
        locationStreamContinuations.removeAll()

        for continuation in continuations {
            continuation.finish()
        }

        if !currentLocationContinuations.isEmpty {
            locationManager.requestLocation()
        }
    }
}

private extension CoreLocationProvider {

    func validateAuthorization() throws {
        switch authorizationStatus {
        case .notDetermined:
            throw LocationError.authorizationNotDetermined

        case .restricted:
            throw LocationError.authorizationRestricted

        case .denied:
            throw LocationError.authorizationDenied

        case .authorizedWhenInUse,
             .authorizedAlways:
            return

        case .unknown:
            throw LocationError.requestFailed
        }
    }

    func removeLocationStream(id: UUID) {
        locationStreamContinuations.removeValue(forKey: id)

        guard locationStreamContinuations.isEmpty else {
            return
        }

        locationManager.stopUpdatingLocation()
        isUpdatingLocation = false

        if !currentLocationContinuations.isEmpty {
            locationManager.requestLocation()
        }
    }

    func finishAuthorizationRequests(
        with status: LocationAuthorizationStatus
    ) {
        let continuations = authorizationContinuations
        authorizationContinuations.removeAll()

        for continuation in continuations {
            continuation.resume(returning: status)
        }
    }

    func finishCurrentLocationRequests(
        with location: LocationPoint
    ) {
        let continuations = currentLocationContinuations
        currentLocationContinuations.removeAll()

        for continuation in continuations {
            continuation.resume(returning: location)
        }
    }

    func finishCurrentLocationRequests(
        throwing error: LocationError
    ) {
        let continuations = currentLocationContinuations
        currentLocationContinuations.removeAll()

        for continuation in continuations {
            continuation.resume(throwing: error)
        }
    }

    func finishLocationStreams(
        throwing error: LocationError
    ) {
        locationManager.stopUpdatingLocation()
        isUpdatingLocation = false

        let continuations = locationStreamContinuations.values
        locationStreamContinuations.removeAll()

        for continuation in continuations {
            continuation.finish(throwing: error)
        }
    }
}

extension CoreLocationProvider: @MainActor CLLocationManagerDelegate {
    
    public func locationManagerDidChangeAuthorization(
        _ manager: CLLocationManager
    ) {
        let status = manager.authorizationStatus.locationAuthorizationStatus

        if status != .notDetermined {
            finishAuthorizationRequests(with: status)
        }

        switch status {
        case .denied:
            finishCurrentLocationRequests(
                throwing: .authorizationDenied
            )

            finishLocationStreams(
                throwing: .authorizationDenied
            )

        case .restricted:
            finishCurrentLocationRequests(
                throwing: .authorizationRestricted
            )

            finishLocationStreams(
                throwing: .authorizationRestricted
            )

        case .notDetermined,
             .authorizedWhenInUse,
             .authorizedAlways,
             .unknown:
            break
        }
    }

    public func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let latestLocation = locations.last else {
            return
        }

        finishCurrentLocationRequests(
            with: latestLocation.locationPoint
        )

        for location in locations {
            let point = location.locationPoint

            for continuation in locationStreamContinuations.values {
                continuation.yield(point)
            }
        }
    }

    public func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: any Error
    ) {
        let locationError = mapLocationError(error)

        finishCurrentLocationRequests(
            throwing: locationError
        )

        if locationError != .locationUnavailable {
            finishLocationStreams(
                throwing: locationError
            )
        }
    }
}

private extension CoreLocationProvider {

    func mapLocationError(
        _ error: any Error
    ) -> LocationError {
        guard let coreLocationError = error as? CLError else {
            return .requestFailed
        }

        switch coreLocationError.code {
        case .denied:
            return .authorizationDenied

        case .locationUnknown:
            return .locationUnavailable

        default:
            return .requestFailed
        }
    }
}

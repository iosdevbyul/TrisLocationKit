//
//  LocationProviding.swift
//  TrisLocationKit
//
//  Created by COMATOKI on 2026-09-21.
//

@MainActor
public protocol LocationProviding: AnyObject {

    var authorizationStatus: LocationAuthorizationStatus { get }

    func requestWhenInUseAuthorization() async -> LocationAuthorizationStatus

    func requestAlwaysAuthorization() async -> LocationAuthorizationStatus

    func requestCurrentLocation() async throws -> LocationPoint

    func locationUpdates() -> AsyncThrowingStream<LocationPoint, Error>

    func stopLocationUpdates()
}

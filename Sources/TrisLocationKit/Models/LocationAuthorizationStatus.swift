//
//  LocationAuthorizationStatus.swift
//  TrisLocationKit
//
//  Created by COMATOKI on 2026-09-21.
//

public enum LocationAuthorizationStatus: Sendable, Equatable {
    case notDetermined
    case restricted
    case denied
    case authorizedWhenInUse
    case authorizedAlways
    case unknown
}

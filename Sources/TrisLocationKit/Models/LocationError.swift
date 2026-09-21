//
//  LocationError.swift
//  TrisLocationKit
//
//  Created by COMATOKI on 2026-09-21.
//

public enum LocationError: Error, Sendable, Equatable {
    case authorizationDenied
    case authorizationRestricted
    case locationUnavailable
    case requestFailed
}

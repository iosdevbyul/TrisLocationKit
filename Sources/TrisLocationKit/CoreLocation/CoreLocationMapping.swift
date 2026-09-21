//
//  CoreLocationMapping.swift
//  TrisLocationKit
//
//  Created by COMATOKI on 2026-09-21.
//

import CoreLocation

extension CLAuthorizationStatus {

    var locationAuthorizationStatus: LocationAuthorizationStatus {
        switch self {
        case .notDetermined:
            return .notDetermined

        case .restricted:
            return .restricted

        case .denied:
            return .denied

        case .authorizedWhenInUse:
            return .authorizedWhenInUse

        case .authorizedAlways:
            return .authorizedAlways

        @unknown default:
            return .unknown
        }
    }
}

extension CLLocation {

    var locationPoint: LocationPoint {
        LocationPoint(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            altitude: altitude,
            horizontalAccuracy: horizontalAccuracy,
            verticalAccuracy: verticalAccuracy,
            speed: speed,
            course: course,
            timestamp: timestamp
        )
    }
}

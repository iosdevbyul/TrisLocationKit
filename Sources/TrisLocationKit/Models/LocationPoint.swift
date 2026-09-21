//
//  LocationPoint.swift
//  TrisLocationKit
//
//  Created by COMATOKI on 2026-09-21.
//

import Foundation

public struct LocationPoint: Sendable, Equatable {

    public let latitude: Double
    public let longitude: Double

    public let altitude: Double

    public let horizontalAccuracy: Double
    public let verticalAccuracy: Double

    public let speed: Double
    public let course: Double

    public let timestamp: Date

    public init(
        latitude: Double,
        longitude: Double,
        altitude: Double,
        horizontalAccuracy: Double,
        verticalAccuracy: Double,
        speed: Double,
        course: Double,
        timestamp: Date
    ) {
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        self.horizontalAccuracy = horizontalAccuracy
        self.verticalAccuracy = verticalAccuracy
        self.speed = speed
        self.course = course
        self.timestamp = timestamp
    }
}

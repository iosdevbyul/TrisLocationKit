//
//  CoreLocationMappingTests.swift
//  TrisLocationKit
//
//  Created by COMATOKI on 2026-09-21.
//

import CoreLocation
import Foundation
import Testing

@testable import TrisLocationKit

struct CoreLocationMappingTests {

    @Test
    func mapsAuthorizationStatus() {
        #expect(
            CLAuthorizationStatus.notDetermined.locationAuthorizationStatus
                == .notDetermined
        )

        #expect(
            CLAuthorizationStatus.restricted.locationAuthorizationStatus
                == .restricted
        )

        #expect(
            CLAuthorizationStatus.denied.locationAuthorizationStatus
                == .denied
        )

        #expect(
            CLAuthorizationStatus.authorizedWhenInUse.locationAuthorizationStatus
                == .authorizedWhenInUse
        )

        #expect(
            CLAuthorizationStatus.authorizedAlways.locationAuthorizationStatus
                == .authorizedAlways
        )
    }

    @Test
    func mapsCLLocationToLocationPoint() {
        let timestamp = Date(timeIntervalSince1970: 1_000)

        let location = CLLocation(
            coordinate: CLLocationCoordinate2D(
                latitude: 37.123,
                longitude: 127.123
            ),
            altitude: 100,
            horizontalAccuracy: 5,
            verticalAccuracy: 8,
            course: 180,
            speed: 3.5,
            timestamp: timestamp
        )

        let point = location.locationPoint

        #expect(point.latitude == 37.123)
        #expect(point.longitude == 127.123)
        #expect(point.altitude == 100)
        #expect(point.horizontalAccuracy == 5)
        #expect(point.verticalAccuracy == 8)
        #expect(point.course == 180)
        #expect(point.speed == 3.5)
        #expect(point.timestamp == timestamp)
    }
}

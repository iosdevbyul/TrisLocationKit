//
//  CoreLocationProviderTests.swift
//  TrisLocationKit
//
//  Created by COMATOKI on 2026-09-22.
//

import CoreLocation
import Foundation
import Testing

@testable import TrisLocationKit

@MainActor
struct CoreLocationProviderTests {

    @Test
    func returnsCurrentAuthorizationStatus() {
        let manager = MockCoreLocationManagerClient(
            authorizationStatus: .authorizedWhenInUse
        )

        let provider = CoreLocationProvider(
            locationManager: manager
        )

        #expect(
            provider.authorizationStatus == .authorizedWhenInUse
        )
    }

    @Test
    func requestWhenInUseAuthorizationReturnsExistingStatus() async {
        let manager = MockCoreLocationManagerClient(
            authorizationStatus: .authorizedWhenInUse
        )

        let provider = CoreLocationProvider(
            locationManager: manager
        )

        let status = await provider.requestWhenInUseAuthorization()

        #expect(status == .authorizedWhenInUse)

        #expect(
            manager.requestWhenInUseAuthorizationCallCount == 0
        )
    }

    @Test
    func requestWhenInUseAuthorizationWaitsForAuthorizationChange() async {
        let manager = MockCoreLocationManagerClient(
            authorizationStatus: .notDetermined
        )

        let provider = CoreLocationProvider(
            locationManager: manager
        )

        let task = Task { @MainActor in
            await provider.requestWhenInUseAuthorization()
        }

        await Task.yield()

        #expect(
            manager.requestWhenInUseAuthorizationCallCount == 1
        )

        manager.sendAuthorizationStatus(
            .authorizedWhenInUse
        )

        let status = await task.value

        #expect(status == .authorizedWhenInUse)
    }

    @Test
    func requestCurrentLocationThrowsWhenAuthorizationNotDetermined() async {
        let manager = MockCoreLocationManagerClient(
            authorizationStatus: .notDetermined
        )

        let provider = CoreLocationProvider(
            locationManager: manager
        )

        do {
            _ = try await provider.requestCurrentLocation()

            Issue.record(
                "Expected authorizationNotDetermined error"
            )
        } catch let error as LocationError {
            #expect(
                error == .authorizationNotDetermined
            )
        } catch {
            Issue.record(
                "Unexpected error: \(error)"
            )
        }
    }

    @Test
    func requestCurrentLocationThrowsWhenAuthorizationDenied() async {
        let manager = MockCoreLocationManagerClient(
            authorizationStatus: .denied
        )

        let provider = CoreLocationProvider(
            locationManager: manager
        )

        do {
            _ = try await provider.requestCurrentLocation()

            Issue.record(
                "Expected authorizationDenied error"
            )
        } catch let error as LocationError {
            #expect(
                error == .authorizationDenied
            )
        } catch {
            Issue.record(
                "Unexpected error: \(error)"
            )
        }
    }

    @Test
    func requestCurrentLocationReturnsReceivedLocation() async throws {
        let manager = MockCoreLocationManagerClient(
            authorizationStatus: .authorizedWhenInUse
        )

        let provider = CoreLocationProvider(
            locationManager: manager
        )

        let timestamp = Date(
            timeIntervalSince1970: 1_000
        )

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

        let task = Task { @MainActor in
            try await provider.requestCurrentLocation()
        }

        await Task.yield()

        #expect(
            manager.requestLocationCallCount == 1
        )

        manager.sendLocations([location])

        let result = try await task.value

        #expect(result.latitude == 37.123)
        #expect(result.longitude == 127.123)
        #expect(result.altitude == 100)
        #expect(result.horizontalAccuracy == 5)
        #expect(result.verticalAccuracy == 8)
        #expect(result.course == 180)
        #expect(result.speed == 3.5)
        #expect(result.timestamp == timestamp)
    }

    @Test
    func requestCurrentLocationReturnsDeniedErrorFromManager() async {
        let manager = MockCoreLocationManagerClient(
            authorizationStatus: .authorizedWhenInUse
        )

        let provider = CoreLocationProvider(
            locationManager: manager
        )

        let task = Task { @MainActor in
            try await provider.requestCurrentLocation()
        }

        await Task.yield()

        manager.sendFailure(
            CLError(.denied)
        )

        do {
            _ = try await task.value

            Issue.record(
                "Expected authorizationDenied error"
            )
        } catch let error as LocationError {
            #expect(
                error == .authorizationDenied
            )
        } catch {
            Issue.record(
                "Unexpected error: \(error)"
            )
        }
    }
    
    @Test
    func locationUpdatesStartsLocationUpdates() {
        let manager = MockCoreLocationManagerClient(
            authorizationStatus: .authorizedWhenInUse
        )

        let provider = CoreLocationProvider(
            locationManager: manager
        )

        _ = provider.locationUpdates()

        #expect(
            manager.startUpdatingLocationCallCount == 1
        )
    }

    @Test
    func locationUpdatesDoesNotStartMoreThanOnceForMultipleStreams() {
        let manager = MockCoreLocationManagerClient(
            authorizationStatus: .authorizedWhenInUse
        )

        let provider = CoreLocationProvider(
            locationManager: manager
        )

        _ = provider.locationUpdates()
        _ = provider.locationUpdates()

        #expect(
            manager.startUpdatingLocationCallCount == 1
        )
    }

    @Test
    func locationUpdatesYieldsReceivedLocation() async throws {
        let manager = MockCoreLocationManagerClient(
            authorizationStatus: .authorizedWhenInUse
        )

        let provider = CoreLocationProvider(
            locationManager: manager
        )

        let timestamp = Date(
            timeIntervalSince1970: 2_000
        )

        let location = CLLocation(
            coordinate: CLLocationCoordinate2D(
                latitude: 37.5,
                longitude: 127.5
            ),
            altitude: 50,
            horizontalAccuracy: 3,
            verticalAccuracy: 4,
            course: 90,
            speed: 2.5,
            timestamp: timestamp
        )

        let stream = provider.locationUpdates()
        var iterator = stream.makeAsyncIterator()

        manager.sendLocations([location])

        let point = try await iterator.next()

        #expect(point?.latitude == 37.5)
        #expect(point?.longitude == 127.5)
        #expect(point?.altitude == 50)
        #expect(point?.horizontalAccuracy == 3)
        #expect(point?.verticalAccuracy == 4)
        #expect(point?.course == 90)
        #expect(point?.speed == 2.5)
        #expect(point?.timestamp == timestamp)

        provider.stopLocationUpdates()
    }

    @Test
    func stopLocationUpdatesStopsUnderlyingLocationManager() async throws {
        let manager = MockCoreLocationManagerClient(
            authorizationStatus: .authorizedWhenInUse
        )

        let provider = CoreLocationProvider(
            locationManager: manager
        )

        let stream = provider.locationUpdates()
        var iterator = stream.makeAsyncIterator()

        provider.stopLocationUpdates()

        #expect(
            manager.stopUpdatingLocationCallCount == 1
        )

        let nextValue = try await iterator.next()

        #expect(nextValue == nil)
    }

    @Test
    func locationUpdatesThrowsWhenAuthorizationDenied() async {
        let manager = MockCoreLocationManagerClient(
            authorizationStatus: .denied
        )

        let provider = CoreLocationProvider(
            locationManager: manager
        )

        let stream = provider.locationUpdates()
        var iterator = stream.makeAsyncIterator()

        do {
            _ = try await iterator.next()

            Issue.record(
                "Expected authorizationDenied error"
            )
        } catch let error as LocationError {
            #expect(
                error == .authorizationDenied
            )
        } catch {
            Issue.record(
                "Unexpected error: \(error)"
            )
        }

        #expect(
            manager.startUpdatingLocationCallCount == 0
        )
    }

    @Test
    func locationUpdatesFinishesWithDeniedErrorFromManager() async {
        let manager = MockCoreLocationManagerClient(
            authorizationStatus: .authorizedWhenInUse
        )

        let provider = CoreLocationProvider(
            locationManager: manager
        )

        let stream = provider.locationUpdates()
        var iterator = stream.makeAsyncIterator()

        manager.sendFailure(
            CLError(.denied)
        )

        do {
            _ = try await iterator.next()

            Issue.record(
                "Expected authorizationDenied error"
            )
        } catch let error as LocationError {
            #expect(
                error == .authorizationDenied
            )
        } catch {
            Issue.record(
                "Unexpected error: \(error)"
            )
        }

        #expect(
            manager.stopUpdatingLocationCallCount == 1
        )
    }
}

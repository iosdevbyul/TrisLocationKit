import Foundation
import Testing

@testable import TrisLocationKit

struct LocationPointTests {

    @Test
    func initializesLocationPoint() {
        let timestamp = Date(timeIntervalSince1970: 1_000)

        let location = LocationPoint(
            latitude: 37.123,
            longitude: 127.123,
            altitude: 100,
            horizontalAccuracy: 5,
            verticalAccuracy: 8,
            speed: 3.5,
            course: 180,
            timestamp: timestamp
        )

        #expect(location.latitude == 37.123)
        #expect(location.longitude == 127.123)
        #expect(location.altitude == 100)
        #expect(location.horizontalAccuracy == 5)
        #expect(location.verticalAccuracy == 8)
        #expect(location.speed == 3.5)
        #expect(location.course == 180)
        #expect(location.timestamp == timestamp)
    }
}

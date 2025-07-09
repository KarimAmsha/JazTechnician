import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    @Published var coordinate: CLLocationCoordinate2D?
    @Published var address: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var completion: ((CLLocationCoordinate2D?, String?) -> Void)?

    // Singleton (لو تريد استخدامه من أي مكان)
    static let shared = LocationManager()

    override private init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
    }

    /// احصل على الموقع الحالي مرة واحدة (بـCompletion)
    func getUserLocation(completion: @escaping (CLLocationCoordinate2D?, String?) -> Void) {
        isLoading = true
        errorMessage = nil
        self.completion = completion
        manager.requestLocation()
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.requestLocation()
        } else if status == .denied {
            isLoading = false
            errorMessage = "تم رفض إذن الموقع"
            completion?(nil, nil)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        isLoading = false
        guard let location = locations.first else {
            errorMessage = "لم يتم العثور على موقع"
            completion?(nil, nil)
            return
        }
        self.coordinate = location.coordinate

        // Reverse Geocode
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            var addressText = ""
            if let placemark = placemarks?.first {
                addressText = [
                    placemark.name,
                    placemark.subLocality,
                    placemark.locality,
                    placemark.administrativeArea,
                    placemark.country
                ]
                .compactMap { $0 }
                .joined(separator: " - ")
            }
            DispatchQueue.main.async {
                self.address = addressText
                self.completion?(location.coordinate, addressText)
                self.completion = nil
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isLoading = false
        errorMessage = "تعذر تحديد الموقع: \(error.localizedDescription)"
        completion?(nil, nil)
        completion = nil
    }
}

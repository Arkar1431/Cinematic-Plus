import UIKit
import MapKit
import CoreLocation

class NearbyLocationViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!

    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var currentRoute: MKRoute?
    var isInitialLocationSet = false

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLocationManager()
        setupMapView()
    }

    // MARK: - Setup Location Manager
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // Update location every 10 meters
        checkLocationAuthorization()
    }

    // MARK: - Setup MapView
    func setupMapView() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }

    // MARK: - Check Location Authorization
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            showLocationDeniedAlert()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            fatalError("Unknown location authorization status")
        }
    }

    // MARK: - Alert if Location Permission Denied
    func showLocationDeniedAlert() {
        let alert = UIAlertController(title: "Location Access Denied",
                                      message: "Please enable location services in Settings to see your current location and nearby cinemas.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    // MARK: - CLLocationManagerDelegate Functions
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        print("Received location update: \(location.coordinate.latitude), \(location.coordinate.longitude)")

        currentLocation = location

        if !isInitialLocationSet {
            centerMapOnLocation(location)
            isInitialLocationSet = true
        }

        searchForNearbyCinemas(location: location)
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }

    // MARK: - Map Functions
    func centerMapOnLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 10000) {
        let region = MKCoordinateRegion(center: location.coordinate,
                                        latitudinalMeters: regionRadius,
                                        longitudinalMeters: regionRadius)
        mapView.setRegion(region, animated: true)
        print("Map centered on: \(location.coordinate.latitude), \(location.coordinate.longitude) with radius: \(regionRadius)")
    }

    func searchForNearbyCinemas(location: CLLocation) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "cinema"
        request.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000) // Search within a 5 km radius

        let search = MKLocalSearch(request: request)
        search.start { [weak self] (response, error) in
            guard let self = self else { return }

            if let error = error {
                print("Search error: \(error.localizedDescription)")
                return
            }

            guard let response = response else {
                print("No results found")
                return
            }

            // Remove existing annotations except user location
            self.mapView.removeAnnotations(self.mapView.annotations.filter { !($0 is MKUserLocation) })

            // Add all cinema annotations
            for item in response.mapItems {
                let annotation = CinemaAnnotation(
                    title: item.name ?? "Cinema",
                    coordinate: item.placemark.coordinate
                )
                self.mapView.addAnnotation(annotation)
            }
        }
    }


    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let cinemaAnnotation = annotation as? CinemaAnnotation {
            let identifier = "CinemaAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: cinemaAnnotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true

                // Add a button to the callout
                let directionsButton = UIButton(type: .detailDisclosure)
                annotationView?.rightCalloutAccessoryView = directionsButton
            } else {
                annotationView?.annotation = annotation
            }

            return annotationView
        }
        return nil
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation as? CinemaAnnotation,
              let currentLocation = currentLocation else { return }

        showDirections(to: annotation.coordinate, from: currentLocation.coordinate)
    }

    // Show directions to the selected cinema
    func showDirections(to destination: CLLocationCoordinate2D, from source: CLLocationCoordinate2D) {
        if let currentRoute = currentRoute {
            mapView.removeOverlay(currentRoute.polyline)  // Remove existing route
            self.currentRoute = nil
        }

        let destinationPlacemark = MKPlacemark(coordinate: destination)
        let sourcePlacemark = MKPlacemark(coordinate: source)

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: sourcePlacemark)
        request.destination = MKMapItem(placemark: destinationPlacemark)
        request.transportType = .automobile  // Set transport type to driving

        let directions = MKDirections(request: request)
        directions.calculate { [weak self] (response, error) in
            guard let self = self else { return }

            if let error = error {
                print("Directions error: \(error.localizedDescription)")
                return
            }

            guard let response = response else {
                print("No directions found")
                return
            }

            self.currentRoute = response.routes.first
            if let route = self.currentRoute {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 5
            return renderer
        }
        return MKOverlayRenderer()
    }
}

class CinemaAnnotation: NSObject, MKAnnotation {
    let title: String?
    let coordinate: CLLocationCoordinate2D
    var openTime: String?
    var closeTime: String?

    init(title: String, coordinate: CLLocationCoordinate2D, openTime: String? = nil, closeTime: String? = nil) {
        self.title = title
        self.coordinate = coordinate
        self.openTime = openTime
        self.closeTime = closeTime
        super.init()
    }
}


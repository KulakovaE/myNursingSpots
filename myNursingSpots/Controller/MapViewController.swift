//
//  MapViewController.swift
//  myNursingSpots
//
//  Created by Elena Kulakova on 2019-06-27.
//  Copyright © 2019 Elena Kulakova. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

protocol HandleMapSearch {
    func didSelectResult(placemark: MKPlacemark)
}

class MapViewController: UIViewController {
    @IBOutlet var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 1000
    var longPressGestureRecognizer: UILongPressGestureRecognizer?
    var spots: [Spot] = []
    var resultSearchController: UISearchController? = nil
    var spotCandidate: MKPlacemark? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkLocationServices()
        self.spots = fetchData()
        setupResultSearchController()
        setupSearchBar()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        displayData(spots: self.spots)
    }
    
    func setupResultSearchController() {
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
        self.resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        self.resultSearchController?.searchResultsUpdater = locationSearchTable
        self.resultSearchController?.hidesNavigationBarDuringPresentation = false
        self.resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
    }
    
    func setupSearchBar() {
        guard let resultSearchController = resultSearchController else { return }
        navigationItem.searchController = resultSearchController
        navigationItem.hidesSearchBarWhenScrolling = false
        let searchBar = resultSearchController.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        
    }
    
    func fetchData() -> [Spot] {
        let fetchRequest: NSFetchRequest<Spot> = Spot.fetchRequest()
        if let result = try? DataController.shared.viewContext.fetch(fetchRequest) {
            return result
        } else {
            return []
        }
    }
    
    func displayData(spots: [Spot]) {
        let annotations = spots.map { spot -> SpotAnnotation in
            let coordinate = CLLocationCoordinate2D(latitude: spot.latitude, longitude: spot.longitude)
            let annotation = SpotAnnotation(coordinate: coordinate, spot: spot)
            return annotation
        }
        
        let currentAnnotations = mapView.annotations
        mapView.removeAnnotations(currentAnnotations)
        mapView.addAnnotations(annotations)
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            showAlert(title: "Warning", message: "Location services are not enabled for this application.")
        }
    }
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location,
                                                 latitudinalMeters: regionInMeters,
                                                 longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            centerViewOnUserLocation()
            locationManager.startUpdatingLocation()
        case .denied:
            showAlert(title: "Info", message: "Location services are not enabled for this application, go to Settings and enable them.")
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            showAlert(title: "Info", message: "You have restricted location services for this application. Enable them if you want to use all the features this application provides.")
        case .authorizedAlways:
            break
        @unknown default:
            fatalError()
        }
    }
    
   func addAnnotation(for coordinate: CLLocationCoordinate2D) {

        let newSpot = Spot(context: DataController.shared.viewContext)
        newSpot.latitude = coordinate.latitude
        newSpot.longitude = coordinate.longitude

       if let _ = try? DataController.shared.viewContext.save() {
            self.spots.append(newSpot)
            let annotation = SpotAnnotation(coordinate: CLLocationCoordinate2D(latitude: newSpot.latitude, longitude: newSpot.longitude), spot: newSpot)
            mapView.addAnnotation(annotation)
        } else {
         showAlert(title: "Warning", message: "Could not create new spot, please try again.")
        }
    }
    
    func showAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.last else {return}
//        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
//        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
       checkLocationAuthorization()
    }
    
}

extension MapViewController: HandleMapSearch {
    func didSelectResult(placemark: MKPlacemark) {
        if let composerViewController = storyboard?.instantiateViewController(withIdentifier: "ComposerViewController") as? ComposerViewController {
            composerViewController.placemark = placemark
            navigationController?.pushViewController(composerViewController, animated: true)
        }
    }
}

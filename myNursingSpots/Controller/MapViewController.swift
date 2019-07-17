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
    var longPressGestureRecognizer: UILongPressGestureRecognizer?//waithing to be used.
    var spots: [Spot] = []
    var resultSearchController: UISearchController? = nil
    private var detailsTransitioningDelegate: InteractiveModalTransitioningDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkLocationServices()
        
        setupResultSearchController()
        setupSearchBar()
        setupLogo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.spots = fetchData()
        displayData(spots: self.spots)
    }
    
    private func setupLogo() {
        guard let navigationController = navigationController else { return }
        let image = UIImage(named: "logo")
        let imageView = UIImageView(image: image)
        let bannerWidth = navigationController.navigationBar.frame.size.width
        let bannerHeight = navigationController.navigationBar.frame.size.height
        let bannerX = bannerWidth / 2 - (image?.size.width)! / 2
        let bannerY = bannerHeight / 2 - (image?.size.height)! / 2
        imageView.frame = CGRect(x: bannerX, y: bannerY, width: bannerWidth, height: bannerHeight)
        imageView.contentMode = .scaleAspectFit
        navigationItem.titleView = imageView
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
        searchBar.barTintColor = UIColor.black
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
            annotation.title = spot.review?.name ?? nil
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
    
    func showAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        let myLocation = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.myLocation = myLocation
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

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is SpotAnnotation else { return nil }
        
        let identifier = "SpotAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.image = UIImage(named: "pin")
            annotationView?.canShowCallout = false

        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if let annotation = view.annotation as? SpotAnnotation {
            mapView.deselectAnnotation(annotation, animated: true)
            let spot = annotation.spot
            if let spotDetailVC = storyboard?.instantiateViewController(withIdentifier: "SpotDetailsViewController") as? SpotDetailsViewController {
                spotDetailVC.spot = spot
                detailsTransitioningDelegate = InteractiveModalTransitioningDelegate(from: self, to: spotDetailVC)
                spotDetailVC.modalPresentationStyle = .custom
                spotDetailVC.transitioningDelegate = detailsTransitioningDelegate
                present(spotDetailVC, animated: true)
            }
        }
    }
}

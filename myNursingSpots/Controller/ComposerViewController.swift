//
//  ComposerViewController.swift
//  myNursingSpots
//
//  Created by Darko Kulakov on 2019-07-03.
//  Copyright © 2019 Elena Kulakova. All rights reserved.
//

import UIKit
import MapKit

class ComposerViewController: UIViewController {

    var placemark: MKPlacemark?
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let placemark = placemark else {return}
        nameLabel.text = placemark.name
        addressLabel.text = placemark.parseAddress()
        configureMapView(placemark: placemark)
        
    }
    
    func configureMapView(placemark: MKPlacemark) {
        let region = MKCoordinateRegion.init(center: placemark.coordinate,
                                             latitudinalMeters: 250,
                                             longitudinalMeters: 250)
        mapView.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        mapView.addAnnotation(annotation)
    }
}

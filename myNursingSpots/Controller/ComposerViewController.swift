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
    @IBOutlet var addImagesButton: UIButton!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var notesAndRemarksTextField: UITextField!
    @IBOutlet var babyFacilitiesRating: CosmosView!
    @IBOutlet var hygieneRating: CosmosView!
    @IBOutlet var comfortAndPrivacyRating: CosmosView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var stackView: UIStackView!
    
    
    
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var widthConstraint: NSLayoutConstraint!
    
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
    
    @IBAction func addImages(_ sender: Any) {
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //scrollView.contentSize = CGSize(width: stackView.frame.width, height: stackView.frame.height)
    }
}



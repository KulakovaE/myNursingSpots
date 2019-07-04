//
//  SpotAnnotation.swift
//  myNursingSpots
//
//  Created by Darko Kulakov on 2019-07-03.
//  Copyright © 2019 Elena Kulakova. All rights reserved.
//

import Foundation
import MapKit

class SpotAnnotation: NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    var spot: Spot
    
    init(coordinate: CLLocationCoordinate2D, spot: Spot) {
        self.coordinate = coordinate
        self.spot = spot
    }
}

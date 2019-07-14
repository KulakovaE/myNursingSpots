//
//  MKPlacemarkExtension.swift
//  myNursingSpots
//
//  Created by Elena Kulakova on 2019-07-04.
//  Copyright © 2019 Elena Kulakova. All rights reserved.
//

import Foundation
import MapKit

extension MKPlacemark {
    
    func parseAddress() -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (self.subThoroughfare != nil && self.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (self.subThoroughfare != nil || self.thoroughfare != nil) && (self.subAdministrativeArea != nil || self.administrativeArea != nil) ? ", " : ""
        // put a space between
        //let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@",
            // street number
            self.subThoroughfare ?? "",
            firstSpace,
            // street name
            self.thoroughfare ?? "",
            comma,
            // city
            self.locality ?? ""
        )
        return addressLine
    }
}

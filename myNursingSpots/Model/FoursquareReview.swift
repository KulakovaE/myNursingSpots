//
//  FoursquareReview.swift
//  myNursingSpots
//
//  Created by Elena Kulakov on 2019-07-23.
//  Copyright © 2019 Elena Kulakova. All rights reserved.
//

import Foundation

struct FoursquareReview {
    var createdAt: Date
    var text: String
    var user: String
    
    var dateValue: String {
        get {
            let date = Date()
            let calendar = Calendar.current
            
            return "\(calendar.component(.year, from: date))-\(String(format: "%02d", calendar.component(.month, from: date)))-\(String(format: "%02d", calendar.component(.day, from: date)))"
        }
    }
}

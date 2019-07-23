//
//  FoursquareClient.swift
//  myNursingSpots
//
//  Created by Elena Kulakova on 2019-07-21.
//  Copyright © 2019 Elena Kulakova. All rights reserved.
//
// https://developer.foursquare.com/docs/announcements#start-up-tier-launch
// Udacity reviewer please read this!

import Foundation
import CoreLocation

class FoursquareClient {
    
    static let clientId = "1QEI4UIOF2352NOCN43S0KBFKFNS1MOLSUT3DDCEAA3CHG5N"
    static let clientSecret = "GEQQ1GM3EAGYG21YP14VZFJT1D1AADAY1RAQFIWUI1WSL1MO"
    
    enum Endpoints {
        case searchForVenueId(location: CLLocationCoordinate2D, name: String)
        case getVenueTips(id: String)
        case getVenuePhotos(id: String)
        
        var dateValue: String {
            get {
                let date = Date()
                let calendar = Calendar.current
                
                return "\(calendar.component(.year, from: date))\(String(format: "%02d", calendar.component(.month, from: date)))\(String(format: "%02d", calendar.component(.day, from: date)))"
            }
        }
        
        var stringValue: String {
            switch  self {
            case .searchForVenueId(let location, let name):
                return "https://api.foursquare.com/v2/venues/search?ll=\(location.latitude),\(location.longitude)&intent=match&name=\(name)&client_id=\(clientId)&client_secret=\(clientSecret)&v=\(dateValue)"
            case .getVenueTips(let id):
                return "https://api.foursquare.com/v2/venues/\(id)/tips?client_id=\(clientId)&client_secret=\(clientSecret)&v=\(dateValue)&limit=50&sort=popular"
            case .getVenuePhotos(let id):
                return "https://api.foursquare.com/v2/venues/\(id)/photos?limit=20&client_id=\(clientId)&client_secret=\(clientSecret)&v=\(dateValue)"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func getVenuePhotos(venueId: String, completion: @escaping ([URL], Error?) -> Void) {
        let url = Endpoints.getVenuePhotos(id: venueId).url
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                completion([], error)
                return
            }
            
            guard let data = data else {
                completion([], error)
                return
            }
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                if let meta = json["meta"] as? [String:Any] {
                    if let errorCode = meta["code"] as? Int {
                        if errorCode == 200 {
                            if let response = json["response"] as? [String:Any] {
                                if let photos = response["photos"] as? [String:Any] {
                                    if let items = photos["items"] as? [[String:Any]] {
                                        var photos: [URL] = []
                                        for item in items {
                                            if let prefix = item["prefix"] as? String,
                                                let suffix = item["suffix"] as? String {
                                                let photoPath = "\(prefix)300x300\(suffix)"
                                                if let photoUrl = URL(string: photoPath) {
                                                    photos.append(photoUrl)
                                                }
                                            }
                                        }
                                        completion(photos, nil)
                                        return
                                    }
                                }
                            }
                        }
                    }
                }
            }
            completion([], nil)
        }
        task.resume()
    }
    
    class func getVenueTips(venueId: String, completion: @escaping ([FoursquareReview], Error?) -> Void) {
        let url = Endpoints.getVenueTips(id: venueId).url
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                completion([], error)
                return
            }
            
            guard let data = data else {
                completion([], error)
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                if let meta = json["meta"] as? [String:Any] {
                    if let errorCode = meta["code"] as? Int {
                        if errorCode == 200 {
                            if let response = json["response"] as? [String:Any] {
                                if let tips = response["tips"] as? [String:Any] {
                                    if let items = tips["items"] as? [[String:Any]] {
                                        var foursquareReviews: [FoursquareReview] = []
                                        for item in items {
                                            if let createdAtValue = item["createdAt"] as? Int {
                                                let createdAt = Date(timeIntervalSince1970: TimeInterval(createdAtValue))
                                                if let text = item["text"] as? String {
                                                    if let user = item["user"] as? [String:Any] {
                                                        if let firstName = user["firstName"] as? String {
                                                            let review = FoursquareReview(createdAt: createdAt, text: text, user: firstName)
                                                            foursquareReviews.append(review)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        completion(foursquareReviews, nil)
                                        return
                                    }
                                }
                            }
                        }
                    }
                }
            }
            completion([], nil)
        }
        task.resume()
    }
    
    class func searchForVenueId(location: CLLocationCoordinate2D, name: String, completion: @escaping (String?, Error?) -> Void) {
        let url = Endpoints.searchForVenueId(location: location, name: name).url
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if error != nil {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, error)
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                if let metajson = json["meta"] as? [String:Any] {
                    if let errorCode = metajson["code"] as? Int {
                        if errorCode == 200 {
                            if let responsejson = json["response"] as? [String:Any] {
                                if let venues = responsejson["venues"] as? [[String:Any]] {
                                    for venue in venues {
                                        if let name = venue["name"] as? String {
                                            if name == name {
                                                if let venueId = venue["id"] as? String {
                                                    completion(venueId, nil)
                                                }
                                            }
                                        }
                                    }
                                }
                                return
                            }
                        }
                    }
                }
                completion(nil,error)
            }
        }
        task.resume()
    }
}

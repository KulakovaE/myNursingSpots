//
//  FoursquareViewController.swift
//  myNursingSpots
//
//  Created by Elena Kulakova on 2019-07-22.
//  Copyright © 2019 Elena Kulakova. All rights reserved.
//

import UIKit

class FoursquareViewController: UIViewController {

    var venueId: String?
    var reviews: [FoursquareReview] = []
    var photos:[URL] = []
    @IBOutlet var tableView: UITableView!
    @IBOutlet var collectionView: UICollectionView!
    var venueName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let venueId = venueId, let venueName = venueName else {return}
        navigationItem.title = venueName
        FoursquareClient.getVenueTips(venueId: venueId) { (reviews, error) in
            self.reviews = reviews
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        FoursquareClient.getVenuePhotos(venueId: venueId) { (photos, error) in
            self.photos = photos
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
}

extension FoursquareViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count == 0 ? 1 : reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TipsAndReviewsTableViewCell", for: indexPath)
        if let cell = cell as? TipsAndReviewsTableViewCell {
            if reviews.count == 0 {
                cell.userLabel.text = ""
                cell.review.text = "There is no review added for this spot."
                cell.createdAtLabel.text = ""
            } else {
                let review = reviews[indexPath.row]
                cell.userLabel.text = review.user
                cell.createdAtLabel.text = review.dateValue
                cell.review.text = review.text
            }
        }
        return cell
    }
}

extension FoursquareViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count == 0 ? 1 : photos.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if photos.count == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoPlaceholderCollectionViewCell", for: indexPath)
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath)
        if let cell = cell as? PhotoCollectionViewCell {
            cell.imageView.image = nil
            
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: self.photos[indexPath.row])
                
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        cell.imageView.image = image
                    }
                }
            }
        }
        return cell
    }
}


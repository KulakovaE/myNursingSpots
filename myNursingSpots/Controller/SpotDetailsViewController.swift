//
//  SpotDetailsViewController.swift
//  myNursingSpots
//
//  Created by Elena Kulakova on 2019-07-13.
//  Copyright © 2019 Elena Kulakova. All rights reserved.
//

import UIKit
import MapKit

class SpotDetailsViewController: UIViewController {

    var spot: Spot?
    @IBOutlet var name: UILabel!
    @IBOutlet var address: UILabel!
    @IBOutlet var averageRating: CosmosView!
    @IBOutlet var imagesCollectionView: UICollectionView!
    @IBOutlet var notesAndRemarks: UITextView!
    @IBOutlet var grayLine: UIView!
    @IBOutlet var directionButton: UIButton!
    @IBOutlet var editButton: UIButton!
    var images: [UIImage] = []
    var editDelegate: HandleEditReview? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.grayLine.clipsToBounds = false
        self.grayLine.layer.borderWidth = 2
        self.grayLine.layer.borderColor = UIColor.lightGray.cgColor
        
        guard let spot = spot, let review = spot.review else { return }
        
        self.name.text = review.name
        self.address.text = review.address
        let calculatedAvgRating = (review.babyFacilitiesRating + review.hygieneRating + review.comfortAndPrivacyRating) / 3
        self.averageRating.rating = Double(calculatedAvgRating)
        self.averageRating.isUserInteractionEnabled = false
        self.averageRating.text = "\(calculatedAvgRating)"
        self.notesAndRemarks.text = review.notes
        setupNotesAndRemarksTextView()
        directionButton.layer.cornerRadius = directionButton.frame.size.height/2
        directionButton.clipsToBounds = true
        
        self.notesAndRemarks.isEditable = false
        
        if let imageData = review.images {
            if let imageDataArray: [Data] = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(imageData) as? [Data] {
                for imageData in imageDataArray {
                    if let image = UIImage(data: imageData) {
                        self.images.append(image)
                    }
                }
            }
        }
        self.imagesCollectionView.delegate = self
    }
    
    private func setupNotesAndRemarksTextView() {
        self.notesAndRemarks.layer.borderWidth = 1
        self.notesAndRemarks.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    @IBAction func showDirections(_ sender: Any) {
        guard let spot = spot else {return}
        dismiss(animated: true) {
           
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: spot.latitude, longitude: spot.longitude), addressDictionary:nil))
            mapItem.name = "Target location"
            DispatchQueue.main.async {
                mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking])
            }
        }
    }
    
    override open var shouldAutorotate: Bool {
        return false
    }
    
    @IBAction func editReview(_ sender: Any) {
        guard let spot = spot else { return }
        self.editDelegate?.editReview(for: spot)
        dismiss(animated: false)
    }
}

extension SpotDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count == 0 ? 1 : images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if images.count == 0 {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlaceholderCollectionViewCell", for: indexPath) as? PlaceholderCollectionViewCell {
                return cell
            }
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageViewCollectionViewCell", for: indexPath)
        if let cell = cell as? ImageViewCollectionViewCell {
            cell.imageView.image = self.images[indexPath.row]
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.images.count == 0 {
            return
        }
        if let detailViewController = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
            detailViewController.imageToDisplay = self.images[indexPath.row]
            self.definesPresentationContext = true
            let navVC = UINavigationController(rootViewController: detailViewController)
            navVC.isNavigationBarHidden = true
            navVC.modalPresentationStyle = .overFullScreen
            self.present(navVC, animated: true, completion: nil)
        }
    }
}

extension SpotDetailsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSize = UIDevice.current.iPad ? 240 : 120
        
        if self.images.count == 0 {
            return CGSize(width: Int(UIScreen.main.bounds.width), height: cellSize)
        } else {
            return UIDevice.current.iPad ? CGSize(width: cellSize, height: cellSize) : CGSize(width: cellSize, height: cellSize)
        }
    }
}

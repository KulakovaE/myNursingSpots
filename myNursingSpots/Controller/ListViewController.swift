//
//  ListViewController.swift
//  myNursingSpots
//
//  Created by Elena Kulakova on 2019-06-27.
//  Copyright © 2019 Elena Kulakova. All rights reserved.
//

import UIKit
import MapKit
import CoreData


class ListViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    var spots: [Spot] = []
    private var detailsTransitioningDelegate: InteractiveModalTransitioningDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.rowHeight = UITableView.automaticDimension
        setupLogo()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.spots = fetchData()
        self.tableView.reloadData()
    }
    
    
    func fetchData() -> [Spot] {
        let fetchRequest: NSFetchRequest<Spot> = Spot.fetchRequest()
        if let result = try? DataController.shared.viewContext.fetch(fetchRequest) {
            return result
        } else {
            return []
        }
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
    
}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return spots.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCell", for: indexPath)
        if let cell = cell as? ListTableViewCell, let review = self.spots[indexPath.row].review {
            cell.name.text = review.name
            cell.address.text = review.address
            let calculatedAvgRating = (review.babyFacilitiesRating + review.hygieneRating + review.comfortAndPrivacyRating) / 3
            cell.rating.rating = Double(calculatedAvgRating)
            cell.rating.isUserInteractionEnabled = false
            cell.rating.text = "\(calculatedAvgRating)"
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let spotLocation = CLLocation(latitude: self.spots[indexPath.row].latitude, longitude: self.spots[indexPath.row].longitude)
            let myLocation = CLLocation(latitude: appDelegate.myLocation?.latitude ?? 0, longitude: appDelegate.myLocation?.longitude ?? 0)
            
            let fullString = NSMutableAttributedString(string:"Distance: \(String(format: "%.1f",spotLocation.distance(from: myLocation)/1000)) km  ")
            let image1Attachment = NSTextAttachment()
            image1Attachment.image = UIImage(named: "walkingMan.png")
            let image1String = NSAttributedString(attachment: image1Attachment)
            fullString.append(image1String)
            fullString.addAttribute(.foregroundColor, value: UIColor.lightGray, range: NSRange(location: 0, length: fullString.length))
            
            cell.distance.attributedText = fullString
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false)
        
        if UIApplication.shared.statusBarOrientation.isLandscape && UIDevice.current.iPhone {
            return
        }
        
        let spot = self.spots[indexPath.row]
        if let spotDetailVC = storyboard?.instantiateViewController(withIdentifier: "SpotDetailsViewController") as? SpotDetailsViewController {
            spotDetailVC.spot = spot
            spotDetailVC.editDelegate = self
            detailsTransitioningDelegate = InteractiveModalTransitioningDelegate(from: self, to: spotDetailVC)
            spotDetailVC.modalPresentationStyle = .custom
            spotDetailVC.transitioningDelegate = detailsTransitioningDelegate
            present(spotDetailVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let spotToDelete = spots[indexPath.row]
            DataController.shared.viewContext.delete(spotToDelete)
            try? DataController.shared.viewContext.save()
            spots.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

extension ListViewController: HandleEditReview {
    func editReview(for spot: Spot) {
        if let composerVC = storyboard?.instantiateViewController(withIdentifier: "ComposerViewController") as? ComposerViewController {
            composerVC.spot = spot
            navigationController?.pushViewController(composerVC, animated: true)
        }
    }
}

//
//  SpotDetailsViewController.swift
//  myNursingSpots
//
//  Created by Darko Kulakov on 2019-07-13.
//  Copyright © 2019 Elena Kulakova. All rights reserved.
//

import UIKit

class SpotDetailsViewController: UIViewController {

    var spot: Spot?
    @IBOutlet var name: UILabel!
    @IBOutlet var address: UILabel!
    @IBOutlet var averageRating: CosmosView!
    @IBOutlet var imagesCollectionView: UICollectionView!
    @IBOutlet var notesAndRemarks: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
    }
}

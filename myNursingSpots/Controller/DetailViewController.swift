//
//  DetailViewController.swift
//  myNursingSpots
//
//  Created by Darko Kulakov on 2019-07-17.
//  Copyright © 2019 Elena Kulakova. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var scroll: UIScrollView!
    var imageToDisplay: UIImage?
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let imageToDisplay = imageToDisplay else {return}
        imageView.image = imageToDisplay
        scroll.delegate = self
    }
    
    @IBAction func dismissImage(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

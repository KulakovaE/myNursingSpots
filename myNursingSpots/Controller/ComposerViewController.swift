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
    var selectedImages: [UIImage] = []
    
    
    
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
        presentImagePickingOptions()
    }

    func presentImagePickingOptions() {
        let alertVC = UIAlertController(title: "", message: "Choose an image source", preferredStyle: .actionSheet)
        
        if let popoverController = alertVC.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        alertVC.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in
            DispatchQueue.main.async {
                self.presentPickerViewController(source: .photoLibrary)
            }
        }))
        alertVC.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            DispatchQueue.main.async {
                self.presentPickerViewController(source: .camera)
            }
        }))
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    func presentPickerViewController(source: UIImagePickerController.SourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = source
        present(imagePickerController, animated: true, completion: nil)
    }
}

extension ComposerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImages.insert(image, at: 0)
            collectionView.reloadData()
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ComposerViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImages.count == 0 ? 1 : selectedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if selectedImages.count == 0 {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlaceholderCollectionViewCell", for: indexPath) as? PlaceholderCollectionViewCell {
                return cell
            }
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageViewCollectionViewCell", for: indexPath)
        if let cell = cell as? ImageViewCollectionViewCell {
            cell.imageView.image = self.selectedImages[indexPath.row]
        }
        return cell
    }
    
}

extension ComposerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSize = UIDevice.current.iPad ? 240 : 120
        
        if self.selectedImages.count == 0 {
            return CGSize(width: Int(UIScreen.main.bounds.width), height: cellSize)
        } else {
            return UIDevice.current.iPad ? CGSize(width: cellSize, height: cellSize) : CGSize(width: cellSize, height: cellSize)
        }
    }
}

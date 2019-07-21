//
//  ComposerViewController.swift
//  myNursingSpots
//
//  Created by Elena Kulakova on 2019-07-03.
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
    @IBOutlet var babyFacilitiesRating: CosmosView!
    @IBOutlet var hygieneRating: CosmosView!
    @IBOutlet var comfortAndPrivacyRating: CosmosView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var stackView: UIStackView!
    var selectedImages: [UIImage] = []
    var selectedImagesData: Data? {
        get {
            var array: [Data] = []
            for image in selectedImages {
            
                if let data = image.jpegData(compressionQuality: 0.7) {
                    array.append(data)
                }
            }
            return try? NSKeyedArchiver.archivedData(withRootObject: array, requiringSecureCoding: false)
        }
    }
    
    var spot: Spot?
    @IBOutlet var noteAndRemarksTextView: UITextView!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        if let placemark = placemark {
            nameLabel.text = placemark.name
            addressLabel.text = placemark.parseAddress()
            configureMapView(placemark: placemark)
        }
        
        setupNotesAndRemarksTextView()
        hideKeyboardWhenTappedOnView()
        setupKeyboardNotifications()
        setupRatingControls()
        
        if let spot = spot, let review = spot.review {
            let placemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: spot.latitude, longitude: spot.longitude))
            nameLabel.text = review.name
            addressLabel.text = review.address
            configureMapView(placemark: placemark)
            noteAndRemarksTextView.text = review.notes
            babyFacilitiesRating.rating = Double(review.babyFacilitiesRating)
            hygieneRating.rating = Double(review.hygieneRating)
            comfortAndPrivacyRating.rating = Double(review.comfortAndPrivacyRating)
            
            if let imageData = review.images {
                if let imageDataArray: [Data] = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(imageData) as? [Data] {
                    for imageData in imageDataArray {
                        if let image = UIImage(data: imageData) {
                            self.selectedImages.append(image)
                        }
                    }
                }
            }
            
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.collectionView.reloadData()
    }
    
    private func setupRatingControls() {
        self.babyFacilitiesRating.rating = 5
        self.hygieneRating.rating = 5
        self.comfortAndPrivacyRating.rating = 5
    }
    
    private func setupNotesAndRemarksTextView() {
        self.noteAndRemarksTextView.layer.borderWidth = 1
        self.noteAndRemarksTextView.layer.borderColor = UIColor.lightGray.cgColor
        self.noteAndRemarksTextView.delegate = self
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
    
    @IBAction func saveReview() {
        if let spot = spot, let review = spot.review {
            review.notes = noteAndRemarksTextView.text
            review.babyFacilitiesRating = Int16(babyFacilitiesRating.rating)
            review.hygieneRating = Int16(hygieneRating.rating)
            review.comfortAndPrivacyRating = Int16(comfortAndPrivacyRating.rating)
            if let selectedImagesData = selectedImagesData {
                review.images = selectedImagesData
            }
            
            try? DataController.shared.viewContext.save()
           navigationController?.popViewController(animated: true)
            return
        }
        
        guard let placemark = placemark else {return}
        let newSpot = Spot(context: DataController.shared.viewContext)
        newSpot.latitude = placemark.coordinate.latitude
        newSpot.longitude = placemark.coordinate.longitude
        
        let review = Review(context: DataController.shared.viewContext)
        
        review.address = addressLabel.text
        review.name = nameLabel.text
        review.notes = noteAndRemarksTextView.text
        review.babyFacilitiesRating = Int16(babyFacilitiesRating.rating)
        review.hygieneRating = Int16(hygieneRating.rating)
        review.comfortAndPrivacyRating = Int16(comfortAndPrivacyRating.rating)
        if let selectedImagesData = selectedImagesData {
             review.images = selectedImagesData
        }
       
        newSpot.review = review
        do {
            try DataController.shared.viewContext.save()
            navigationController?.popViewController(animated: true)
        } catch {
            print(error)
        }
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if selectedImages.count == 0 {
            return
        }
        
        self.selectedImages.remove(at: indexPath.row)
        self.collectionView.reloadData()
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

extension ComposerViewController: UITextViewDelegate {
    // MARK: Keyboard Functions
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
        }
        return true
    }
    
}

extension ComposerViewController {
    
    func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    func hideKeyboardWhenTappedOnView() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ComposerViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension ComposerViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        
        let identifier = "SpotAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        let image = UIImage(named: "pin")
        if let image = image {
            annotationView?.image = image
            annotationView?.centerOffset = CGPoint(x: 0, y: -image.size.height/2)
        }
        annotationView?.canShowCallout = false
        
        return annotationView
    }
}


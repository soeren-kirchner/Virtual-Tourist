//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Sören Kirchner on 01.01.18.
//  Copyright © 2018 Sören Kirchner. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import MapKit

private let reuseIdentifier = "PhotoAlbumCollectionViewCell"

class PhotoAlbumViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var bottomButton: UIButton!

    struct BottomButtonText{
        static let removePictures = NSLocalizedString("Remove Selected Pictures", comment: "Label for Button at bottom of Photo Album Collection View")
        static let newCollection = NSLocalizedString("New Collection", comment: "Label for Button at bottom of Photo Album Collection")
    }
    
    let space:CGFloat = 3.0
    var portraitCellDimension:CGFloat = 0.0;
    var landscapeCellDimension:CGFloat = 0.0;
   
    var pin: Pin?
    
    let stack = CoreDataStack.shared
    let flickrClient = FlickrClient.shared

    lazy var fetchedResultsController: NSFetchedResultsController<Impression> = fetchResults()
    var operationsQueue = [BlockOperation]()

    private func fetchResults() -> NSFetchedResultsController<Impression> {
        print("fetchedResultsController: initializing my lazy self")
        
        let fetchRequest: NSFetchRequest<Impression> = Impression.fetchRequest()
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "pin = %@", argumentArray: [pin!])
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
        
        return fetchedResultsController
    }
    
    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        initCollectionView()
        initMapView()
        setSelfDarkMode()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setSelfDarkMode()
    }
    
    // MARK: Helper
    
    private func setSelfDarkMode() {
        setDarkMode()
        if isDarkMode() {
            visualEffectView.effect = UIBlurEffect(style: .dark)
            bottomButton.setTitleColor(.darkBarTint, for: .normal)
            print("dark")
        }
        else {
            visualEffectView.effect = UIBlurEffect(style: .light)
            bottomButton.setTitleColor(.lightBarTint, for: .normal)
            print("light")
        }
    }
    
    private func initCollectionView() {
        collectionView.allowsMultipleSelection = true
        updateBottomButton()
        portraitCellDimension = (min(view.frame.size.width, view.frame.size.height) - (2 * space)) / 3.0
        landscapeCellDimension = (max(view.frame.size.width, view.frame.size.height) - (2 * space)) / 3.0
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        setItemSize(for: view.frame.size)
        collectionView.backgroundColor = isDarkMode() ? .darkGray : .white
    }
    
    private func initMapView() {
        mapView.addAnnotation(VirtualTouristAnnotation(pin: pin!))
        let defaultDistance = 10000.0
        let region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: pin!.latitude, longitude: pin!.longitude) , defaultDistance, defaultDistance)
        mapView.setRegion(region, animated: true)
    }
    
    // MARK: - actions
    
    @IBAction func bottomButtonPressed(_ sender: Any) {
        if (collectionView.indexPathsForSelectedItems!.count>0) {
            for indexPath in collectionView.indexPathsForSelectedItems! {
                stack.context.delete(fetchedResultsController.object(at: indexPath) as Impression)
            }
            saveContext()
        } else {
            for result in fetchedResultsController.fetchedObjects! {
                self.stack.context.delete(result)
            }
            
            saveContext()
            
            flickrClient.getImpressions(forPin: pin!) { (result, error) in
                
                guard error == nil else {
                    print("some error")
                    return
                }
                self.saveContext()
                try? self.fetchedResultsController.performFetch()
            }
        }
    }
}

extension PhotoAlbumViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        let reusableMarkerIdentifier = "VirtualLocation"
        var markerView = mapView.dequeueReusableAnnotationView(withIdentifier: reusableMarkerIdentifier) as? VirtualTouristAnnotationView
        if markerView == nil {
            markerView = VirtualTouristAnnotationView(annotation: nil, reuseIdentifier: reusableMarkerIdentifier)
        }
        
        markerView?.annotation = annotation
        return markerView
    }
    
}

extension PhotoAlbumViewController: UICollectionViewDelegate {
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        setItemSize(for: size)
    }
    
    func setItemSize(for size: CGSize) {
        let dimension = (size.width < size.height) ? portraitCellDimension : landscapeCellDimension
        if let layout = flowLayout { // flowlayout can be nil at the beginn
            layout.itemSize = CGSize(width: dimension, height: dimension)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        updateBottomButton()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        updateBottomButton()
    }
    
    // Mark: - Helper
 
    private func updateBottomButton() {
        bottomButton.setTitle((collectionView.indexPathsForSelectedItems!.count > 0) ? BottomButtonText.removePictures : BottomButtonText.newCollection, for: .normal)
    }
}

extension PhotoAlbumViewController: UICollectionViewDataSource {
    
    private func download(impression: Impression, forCell cell: PhotoAlbumCollectionViewCell) {
        cell.activityIndicator.startAnimating()
        
        flickrClient.downloadImage(fromUrl: impression.url! ) { (data, error) in
            
            guard error == nil else {
                return
            }
            
            if let data = data as? Data,
                let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    impression.imageData = data as NSData
                    self.saveContext()
                    cell.imageView.image = image
                    cell.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoAlbumCollectionViewCell
        let impression = fetchedResultsController.object(at: indexPath) as Impression
        
        cell.imageView.image = UIImage(named: "placeholder")
        
        if impression.imageData == nil {
            download(impression: impression, forCell: cell)
        } else {
            let image = UIImage(data: impression.imageData! as Data)
            cell.imageView.image = image
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let numberOfItems = fetchedResultsController.sections?[0].numberOfObjects {
            return numberOfItems
        }
        return 0
    }
}

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate{

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            addOperation {
                self.collectionView.deleteItems(at: [indexPath!])
            }
        case .insert:
            addOperation {
                self.collectionView.insertItems(at: [newIndexPath!])
            }
        default:
            break
        }
    }
    
    func addOperation(operation: @escaping () -> Void) {
        operationsQueue.append(BlockOperation(block: operation))
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.performBatchUpdates({
            for operation in self.operationsQueue {
                operation.start()
            }
        }, completion: { (finished) in
            self.operationsQueue.removeAll()
            self.updateBottomButton()
        })
    }
    
}






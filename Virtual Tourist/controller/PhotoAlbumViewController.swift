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
    
    let space:CGFloat = 3.0
    var portraitCellDimension:CGFloat = 0.0;
    var landscapeCellDimension:CGFloat = 0.0;
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var pin: Pin?
    
    let stack = CoreDataStack.shared
    let flickrClient = FlickrClient.shared
    
    //var fetchedResultsController: NSFetchedResultsController<Impression>!
    
    
    lazy var fetchedResultsController: NSFetchedResultsController<Impression> = {
        
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
    }()
    


    override func viewDidLoad() {
        super.viewDidLoad()
        
        //fetchResults()
        
        mapView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        initCollectionView()
        
        mapView.addAnnotation(VirtualTouristAnnotation(pin: pin!))
        
        let defaultDistance = 10000.0
        
        let region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: pin!.latitude, longitude: pin!.longitude) , defaultDistance, defaultDistance)
        mapView.setRegion(region, animated: true)
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        fetchResults()
//    }

//    private func fetchResults() {
//        let fetchRequest: NSFetchRequest<Impression> = Impression.fetchRequest()
//        fetchRequest.sortDescriptors = []
//        print(pin!)
//        fetchRequest.predicate = NSPredicate(format: "pin = %@", argumentArray: [pin!])
//
//        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
//        fetchedResultsController.delegate = self
//        do {
//            try fetchedResultsController.performFetch()
//        } catch let error as NSError {
//            print("Fetching error: \(error), \(error.userInfo)")
//        }
//        print(fetchedResultsController)
//    }
    
    private func initCollectionView() {
        portraitCellDimension = (min(view.frame.size.width, view.frame.size.height) - (2 * space)) / 3.0
        landscapeCellDimension = (max(view.frame.size.width, view.frame.size.height) - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        
        setItemSize(for: view.frame.size)
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
    
}

extension PhotoAlbumViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoAlbumCollectionViewCell
        let impression = fetchedResultsController.object(at: indexPath) as Impression

        print(impression)
        print(impression.url!)
        
        if impression.imageData == nil {
            
            cell.activityIndicator.startAnimating()
            
            flickrClient.downloadImage(fromUrl: impression.url! ) { (data, error) in
                
                guard error == nil else {
                    return
                }
                
                if let data = data as? Data,
                    let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        impression.imageData = data as NSData
                        try? self.stack.saveContext()
                        cell.imageView.image = image
                        cell.activityIndicator.stopAnimating()
                    }
                }
            }
        } else {
            let image = UIImage(data: impression.imageData! as Data)
            cell.imageView.image = image
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        print("collectionView")
//        print(collectionView)
//        print(fetchedResultsController)
//        //print(fetchedResultsController.sections)
        if let numberOfItems = fetchedResultsController.sections?[0].numberOfObjects {
            return numberOfItems
        }
        return 0
    }
}

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate{
    
}

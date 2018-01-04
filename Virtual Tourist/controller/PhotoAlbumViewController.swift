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
    
    let stack = CoreDataStack.shared
    let flickrClient = FlickrClient.shared
    
    lazy var fetchedResultsController: NSFetchedResultsController<Impression> = {

        let fetchRequest: NSFetchRequest<Impression> = Impression.fetchRequest()
        fetchRequest.sortDescriptors = []
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
        
        portraitCellDimension = (min(view.frame.size.width, view.frame.size.height) - (2 * space)) / 3.0
        landscapeCellDimension = (max(view.frame.size.width, view.frame.size.height) - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        
        setItemSize(for: view.frame.size)
        
        
        
        print(fetchedResultsController)

        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
        
        print(fetchedResultsController)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension PhotoAlbumViewController: MKMapViewDelegate {
    
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
        if let numberOfItems = fetchedResultsController.sections?[0].numberOfObjects {
            return numberOfItems
        }
        return 0
    }
}

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate{
    
}

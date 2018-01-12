//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Sören Kirchner on 09.12.17.
//  Copyright © 2017 Sören Kirchner. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class TravelLocationsMapViewController: UIViewController {

    let photoAlbumSegueIdentifier = "PhotoAlbumSegue"
    
    let stack = CoreDataStack.shared
    let flickrClient = FlickrClient.shared
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var hintViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    var selectedPin: Pin?
    
    var editMode: Bool = false
    
    lazy var fetchedResultsController: NSFetchedResultsController<Pin> = fetchResults()
    
    private func fetchResults() -> NSFetchedResultsController<Pin> {
        print("fetchedResultsController: initializing my lazy self")
        
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        fetchRequest.sortDescriptors = []
        //fetchRequest.predicate = NSPredicate(format: "pin = %@", argumentArray: [pin!])
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        //fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
        
        return fetchedResultsController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.navigationItem.title = NSLocalizedString("Virtual Tourist", comment: "Navbar Title - Virtual Tourist")
        navigationController?.navigationBar.prefersLargeTitles = true
        editButton.title = NSLocalizedString("edit", comment: "done - edit - button in navigation bar")
  
        mapView.delegate = self
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(press:)))
        longPressGestureRecognizer.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPressGestureRecognizer)
        mapView.showsUserLocation = true
        
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            print("location service is enabled")
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        fetchStoredAnnotations()
 
//        let userLocation = mapView.userLocation
//        print(userLocation.location?.coordinate)
//        let region = MKCoordinateRegionMakeWithDistance(userLocation.location!.coordinate, 100, 100)
//        mapView.setRegion(region, animated: true)
        
    }
    
    private func fetchStoredAnnotations() {
        print("fetchStoredAnnotations:")
        for pin in fetchedResultsController.fetchedObjects! {
            print(pin)
            let annontation = VirtualTouristAnnotation(pin: pin)
            mapView.addAnnotation(annontation)
            
        }
    }

    @IBAction func editMode(_ sender: Any) {
        print("edit pressed");
        print(hintViewBottomConstraint!)
        editMode = !editMode
        if editMode {
            hintViewBottomConstraint.constant = 0
            editButton.title = NSLocalizedString("done", comment: "done - button in navigation bar")
        }
        else {
            hintViewBottomConstraint.constant = -45
            editButton.title = NSLocalizedString("edit", comment: "edit - button in navigation bar")
        }
    }
    
    @objc func addAnnotation(press:UILongPressGestureRecognizer) {
        if press.state == .began {
            
            let pin = Pin(coordinates: mapView.convert(press.location(in: mapView), toCoordinateFrom: mapView), context: stack.context)
            let annotation = VirtualTouristAnnotation(pin: pin)
            
            flickrClient.getImpressions(forPin: pin) { (result, error) in

                guard error == nil else {
                    print("some error")
                    return
                }

                // TODO: to completion handler
                do {
                    print("save context")
                    try self.stack.saveContext()
                }
                catch {
                    print("error")
                }

            }
//            print("adding annontation")
//            print(annotation)
//            print(annotation.coordinate.longitude)
//            print(annotation.coordinate.latitude)
            mapView.addAnnotation(annotation)
        }
    }
}

extension TravelLocationsMapViewController: MKMapViewDelegate {
    
//    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
//        print("map finished loading")
//    }
    
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if let annotation = view.annotation as? VirtualTouristAnnotation {
            if (editMode) {
                mapView.removeAnnotation(annotation)
            }
            else {
                print("show details")
                selectedPin = annotation.pin
                performSegue(withIdentifier: photoAlbumSegueIdentifier, sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case photoAlbumSegueIdentifier:
                let photoAlbumViewController = segue.destination as! PhotoAlbumViewController
                photoAlbumViewController.pin = selectedPin
            default:
                break
            }
        }
    }
    
}

extension TravelLocationsMapViewController: CLLocationManagerDelegate {
        
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("didUpdateLocations")
        
        manager.stopUpdatingLocation()
        let userLocation: CLLocation = locations[0] as CLLocation
        
        let region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 500, 500)
        mapView.setRegion(region, animated: true)
        
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
    }
    
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        print("\(error)")
//    }

}



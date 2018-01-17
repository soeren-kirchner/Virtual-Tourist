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
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    @IBOutlet weak var hintLabel: UILabel!
    
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
        navigationController?.navigationBar.prefersLargeTitles = true

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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setSelfDarkMode()
        updateUI()
        mapView.showsUserLocation = true
        mapView.removeAnnotations(mapView.annotations)
        fetchStoredAnnotations()
    }
    
    private func fetchStoredAnnotations() {
        print("fetchStoredAnnotations:")
        for pin in fetchedResultsController.fetchedObjects! {
            print(pin)
            let annontation = VirtualTouristAnnotation(pin: pin)
            mapView.addAnnotation(annontation)
        }
    }
    
    private func setSelfDarkMode() {
        setDarkMode()
        if isDarkMode() {
            visualEffectView.effect = UIBlurEffect(style: .dark)
            print("dark")
        }
        else {
            visualEffectView.effect = UIBlurEffect(style: .light)
            print("light")
        }
    }

    private func updateUI() {
        if editMode {
            hintViewBottomConstraint.constant = 0
            editButton.title = NSLocalizedString("Done", comment: "done - button in navigation bar")
        }
        else {
            hintViewBottomConstraint.constant = -50
            editButton.title = NSLocalizedString("Edit", comment: "edit - button in navigation bar")
        }
    }
    
    @IBAction func editMode(_ sender: Any) {
//        print("edit pressed");
//        print(hintViewBottomConstraint!)
        editMode = !editMode
        updateUI()
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

                self.saveContext()
            }
            mapView.addAnnotation(annotation)
        }
    }
}

extension TravelLocationsMapViewController: MKMapViewDelegate {
    
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
                stack.context.delete(annotation.pin)
                mapView.removeAnnotation(annotation)
                saveContext()
            }
            else {
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
        manager.stopUpdatingLocation()
        let userLocation: CLLocation = locations[0] as CLLocation
        let region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 500, 500)
        mapView.setRegion(region, animated: true)
    }
}



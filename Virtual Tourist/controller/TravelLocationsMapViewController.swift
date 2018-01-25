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
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    var selectedPin: Pin?
    
    var editMode: Bool = false
    
    lazy var fetchedResultsController: NSFetchedResultsController<Pin> = initFetchedResultsController()
    
    private func initFetchedResultsController() -> NSFetchedResultsController<Pin> {

        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        fetchRequest.sortDescriptors = []
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)

        return fetchedResultsController
    }
    
    fileprivate func fetchResults() {
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
            showAlert(title: NSLocalizedString("ERROR", comment: "ERROR"), alert: NSLocalizedString("An Error occured while loading data", comment: "Error Message for the user when the App cannot fetch data"))
        }
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
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateDarkMode()
        updateUI()
        fetchStoredAnnotations()
    }
    
    private func fetchStoredAnnotations() {
        fetchResults()
        let diff = (CLLocationManager.authorizationStatus().rawValue > CLAuthorizationStatus.authorizedAlways.rawValue) ? 1 : 0
        if mapView.annotations.count==0 || mapView.annotations.count != fetchedResultsController.fetchedObjects!.count+diff {
            mapView.removeAnnotations(mapView.annotations)
            for pin in fetchedResultsController.fetchedObjects! {
                mapView.addAnnotation(VirtualTouristAnnotation(pin: pin))
            }
        }
    }
    
    // TODO: Merge setSelfDarkMode and update UI
    private func updateDarkMode() {
        setDarkMode()
        visualEffectView.effect = UIBlurEffect(style: isDarkMode() ? .dark : .light)
    }

    private func updateUI() {
        visualEffectView.isHidden = !editMode
        if editMode {
            editButton.title = NSLocalizedString("Done", comment: "done - button in navigation bar")
        }
        else {
            editButton.title = NSLocalizedString("Edit", comment: "edit - button in navigation bar")
        }
    }
    
    @IBAction func editMode(_ sender: Any) {
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
        
        if annotation is MKUserLocation { return nil }

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



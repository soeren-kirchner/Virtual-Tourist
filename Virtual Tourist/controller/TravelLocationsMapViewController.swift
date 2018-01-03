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

class TravelLocationsMapViewController: UIViewController {

    //private var pins = [Pin] ()
    
    let stack = CoreDataStack.shared
    let flickrClient = FlickrClient.shared
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    @IBOutlet weak var hintViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    var editMode: Bool = false
    
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
 
//        let userLocation = mapView.userLocation
//        print(userLocation.location?.coordinate)
//        let region = MKCoordinateRegionMakeWithDistance(userLocation.location!.coordinate, 100, 100)
//        mapView.setRegion(region, animated: true)
        
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
            //let location = press.location(in: mapView)
            //let coordinates = mapView.convert(press.location(in: mapView), toCoordinateFrom: mapView)
            
            let pin = Pin(coordinates: mapView.convert(press.location(in: mapView), toCoordinateFrom: mapView), context: stack.context)
            let annotation = VirtualTouristAnnotation(pin: pin)
            
            //let annotation = MKPointAnnotation()
            //annotation.coordinate = mapView.convert(press.location(in: mapView), toCoordinateFrom: mapView)
            //annotation.title = "Title"
            
            
            //let pin = Pin(longitude: annotation.coordinate.longitude, latitude: annotation.coordinate.latitude, context: stack.context)
            annotation.subtitle = String(pin.longitude) + " " + String(pin.latitude)
            
            
            flickrClient.getImpressions(forPin: pin) { (result, error) in

                guard error == nil else {
                    print("some error")
                    return
                }

                do {
                    print("save context")
                    try self.stack.saveContext()
                }
                catch {
                    print("error")
                }

            }
            
            //pins.append(pin)
            print("adding annontation")
            print(annotation)
            print(annotation.coordinate.longitude)
            print(annotation.coordinate.latitude)
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
        
        var markerView = mapView.dequeueReusableAnnotationView(withIdentifier: reusableMarkerIdentifier) as? MKMarkerAnnotationView
        if markerView == nil {
            markerView = MKMarkerAnnotationView(annotation: nil, reuseIdentifier: reusableMarkerIdentifier)
        }
        
        //markerView?.canShowCallout = true
        markerView?.markerTintColor = .green
        markerView?.glyphImage = UIImage(named: "binoculars")
        markerView?.animatesWhenAdded = true
        markerView?.isDraggable = true
        markerView?.annotation = annotation

        return markerView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let annotation = view.annotation
        if (editMode) {
            mapView.removeAnnotation(annotation!)
        }
        else {
            print("show details")
            //performSegue(withIdentifier: "PhotoAlbumSegue", sender: self)
            performSegue(withIdentifier: "test4", sender: self)
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
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("\(error)")
    }

}



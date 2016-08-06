//
//  MapViewController.swift
//  OTM
//
//  Created by Ronald Morgan on 8/4/16.
//  Copyright © 2016 Ronald Morgan. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapViewController: UIViewController {
    
    // MARK: Properties
    
    let studentData = StudentData.sharedInstance
    
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: Navigation Bar Config.
        parentViewController!.navigationItem.title = "On The Map"
        
        let logoutBarButtonItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: #selector(self.logout))
        parentViewController!.navigationItem.setLeftBarButtonItem(logoutBarButtonItem, animated: true)
        
        let pinImage = UIImage(imageLiteral: "pin")
        let pinBarButtonItem = UIBarButtonItem(image: pinImage , style: .Done, target: self, action: #selector(self.addPin))
        let redoBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: #selector(self.reload))
        
        parentViewController!.navigationItem.setRightBarButtonItems([redoBarButtonItem, pinBarButtonItem], animated: true)
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.mapView.delegate = self
        performUIUpdatesOnMain{
            if self.mapView.annotations.count > 0{
                self.mapView.removeAnnotations(self.mapView.annotations)
            }
        }
        // MARK: Load Student Information Data (max 100)
        loadStudentLocations()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // MARK: set region for Map (Default: Columbus, OH)
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 39.961176, longitude: -82.998794)
        
        if let longitude = studentData.students.first?.longitude,
            let latitude = studentData.students.first?.latitude {
            center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        
        let span = MKCoordinateSpan(latitudeDelta: 6.0, longitudeDelta: 6.0)
        let currentRegion = MKCoordinateRegion(center: center , span: span)
        mapView.setRegion(currentRegion, animated: true)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    private func loadStudentLocations() {
        OTMClient.sharedInstance().getStudentLocations() { (students, errorString ) in
            performUIUpdatesOnMain{
                if let students = students{
                    self.studentData.students = students
                    self.setStudentPins()
                }else{
                    let alert = UIAlertController(title: "Loading Student Information", message: errorString, preferredStyle: .Alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    
                    alert.addAction(defaultAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    private func setStudentPins() {
        
        for student in studentData.students{
            let pin = MKPointAnnotation()
            pin.coordinate = CLLocationCoordinate2D(latitude: Double(student.latitude), longitude: Double(student.longitude))
            pin.title = "\(student.firstName) \(student.lastName)"
            pin.subtitle = "\(student.mediaURL)"
            
            mapView.addAnnotation(pin)
            mapView.viewForAnnotation(pin)
        }
        
        mapView.reloadInputViews()
    }
    
    func logout(){
        OTMClient.sharedInstance().logoutOfSession()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addPin(){
        let controller = storyboard!.instantiateViewControllerWithIdentifier("AddLocationViewController")
        controller.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        presentViewController(controller, animated: true, completion: nil)
    }
    
    func reload(){
        mapView.removeAnnotations(self.mapView.annotations)
        loadStudentLocations()
    }
}

extension MapViewController: MKMapViewDelegate{
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let customPinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "studentPinView")
        
        customPinView.pinTintColor = MKPinAnnotationView.redPinColor()
        customPinView.animatesDrop = true
        customPinView.canShowCallout = true
        
        let rightButton = UIButton(type: .DetailDisclosure)
        rightButton.addTarget(nil, action: nil, forControlEvents: .TouchUpInside)
        customPinView.rightCalloutAccessoryView = rightButton
        
        return customPinView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        func alert(error: String){
            let alert = UIAlertController(title: "Open Safari has failed", message: error, preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(defaultAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        guard let annotation : MKAnnotation = view.annotation else{
            return
        }
        
        if let urlString : String = annotation.subtitle!  {
            let url = NSURL(string: urlString)
            
            let app = UIApplication.sharedApplication()
            if !app.openURL(url!){
                alert("Student-URL invalid: \(url!.absoluteString)")
            }
        }else{
            alert("No Student-URLfound")
        }
    }

}

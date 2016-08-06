//
//  AddURLViewController.swift
//  OTM
//
//  Created by Ronald Morgan on 8/4/16.
//  Copyright © 2016 Ronald Morgan. All rights reserved.
//

import UIKit
import MapKit

class AddURLViewController: UIViewController {

    // MARK: Properties
    @IBOutlet weak var studentLocationMapView: MKMapView!
    @IBOutlet weak var urlTextField: UITextField!
    var mediaURL = String()
    var studentLocation = CLLocation()
    var geocodeLocationSeachString = String()
    
    let studentData = StudentData.sharedInstance
    let userData = UserData.sharedInstance
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        subscribeToKeyboardNotifications()
        
        // MARK: set region for Map
        
        let span = MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)
        let currentRegion = MKCoordinateRegion(center: studentLocation.coordinate , span: span)
        studentLocationMapView.setRegion(currentRegion, animated: true)
        
        let pin = MKPointAnnotation()
        pin.coordinate = studentLocation.coordinate
        pin.title = "\(userData.user.firstName) \(userData.user.lastName)"
        pin.subtitle = "\(userData.user.mediaURL)"
        
        studentLocationMapView.addAnnotation(pin)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    @IBAction func cancelBarButtonPressed(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func submitButtonPressed(sender: UIButton) {
        if let text = urlTextField.text {
            userData.user.mediaURL = text
        }
        userData.user.latitude = studentLocation.coordinate.latitude
        userData.user.longitude = studentLocation.coordinate.longitude
        userData.user.mapString = geocodeLocationSeachString
        
        OTMClient.sharedInstance().setStudentLocationAndUrl() { (success, error) in
            if success {
                performUIUpdatesOnMain{
                    // Add dismissViewController based on review suggestion
                    let alert = UIAlertController(title: "Successful update !", message: error, preferredStyle: .Alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .Default) {(_) in
                        self.dismissView()
                    }
                    
                    alert.addAction(defaultAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }else{
                performUIUpdatesOnMain{
                    let alert = UIAlertController(title: "Update of Student Information has failed", message: error, preferredStyle: .Alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    
                    alert.addAction(defaultAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func dismissView(){
        performUIUpdatesOnMain{
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}

extension AddURLViewController {
    
    // MARK: Keyboard
    
    func subscribeToKeyboardNotifications(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddURLViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddURLViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications(){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification){
        if urlTextField.editing {
            view.frame.origin.y = getKeyboardHeight(notification) * -1
        }
    }
    
    func keyboardWillHide(notification: NSNotification){
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat{
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    
}

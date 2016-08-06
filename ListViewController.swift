//
//  ListViewController.swift
//  OTM
//
//  Created by Ronald Morgan on 8/4/16.
//  Copyright © 2016 Ronald Morgan. All rights reserved.
//

import UIKit
import Foundation

class ListViewController: UIViewController {
    
    // MARK: Properties
    
    let studentData = StudentData.sharedInstance
    
    @IBOutlet weak var studentsTableView: UITableView!
    
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
        loadStudentLocations()
    }
    
    private func loadStudentLocations() {
        OTMClient.sharedInstance().getStudentLocations() { (students, errorString ) in
            if let students = students{
                self.studentData.students = students
                performUIUpdatesOnMain{
                    self.studentsTableView.reloadData()
                }
            }else{
                let alert = UIAlertController(title: "Loading Student Information", message: errorString, preferredStyle: .Alert)
                let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alert.addAction(defaultAction)
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
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
        loadStudentLocations()
    }
}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        /* Get cell type */
        let cellReuseIdentifier = "StudentInformationCell"
        let student = studentData.students[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as UITableViewCell!
        
        /* Set cell defaults */
        cell.textLabel!.text = "\(student.firstName) \(student.lastName)"
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentData.students.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let student = studentData.students[indexPath.row]
        
        func alert(error: String){
            let alert = UIAlertController(title: "Open Safari has failed", message: error, preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(defaultAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        if let url = NSURL(string: student.mediaURL){
            let app = UIApplication.sharedApplication()
            print(url.absoluteString)
            if !app.openURL(url){
                alert("Student-URL invalid: \(url.absoluteString)")
            }
            
        }else{
            alert("No Student-URLfound")
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }

}
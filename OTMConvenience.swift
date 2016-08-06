//
//  OTMConvenience.swift
//  OTM
//
//  Created by Ronald Morgan on 8/4/16.
//  Copyright © 2016 Ronald Morgan. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

extension OTMClient {
    
    // MARK: Udacity Interface Methods
    func authenticateWithCredentials(userName: String?, password: String?, completionHandlerForAuth: (success: Bool, errorString: String?) -> Void) {
        
        getSessionID(userName, password: password) { (success, sessionID, errorString) in
            
            if success {
                completionHandlerForAuth(success: success, errorString: errorString)
            } else {
                completionHandlerForAuth(success: success, errorString: errorString)
            }
        }
    }
    
    func logoutOfSession(){
        taskForDELETEMethod(){ (result, error) in
            if error != nil{
                print("logout session not successful")
            } else{
                print(result)
            }
        }
    }
    
    
    private func getSessionID(userName: String?, password: String?, completionHandlerForSession: (success: Bool, sessionID: String?, errorString: String?) -> Void) {
        
        guard let userName = userName else {
            completionHandlerForSession(success: false, sessionID: nil, errorString: "Login Failed (User Name).")
            return
        }
        guard let password = password else {
            completionHandlerForSession(success: false, sessionID: nil, errorString: "Login Failed (password).")
            return
        }
        
        let jsonBody = "{\"udacity\": {\"\(JSONBodyKeys.UserName)\": \"\(userName)\", \"\(JSONBodyKeys.Password)\": \"\(password)\"}}"
        
        taskForUdacityPOSTMethod(jsonBody) { (results, error) in
            if let error = error {
                
                //Indicate the general Network related Error or credential realated issues
                if error.description.containsString("network") {
                    completionHandlerForSession(success: false, sessionID: nil, errorString: "Login Failed  - Connection Issue.")
                }else {
                    completionHandlerForSession(success: false, sessionID: nil, errorString: "Login Failed  - wrong credentials.")
                }
                
            } else {
                if let session = results[JSONResponseKeys.Session] as? [String:AnyObject],
                    let account = results[JSONResponseKeys.Account] as? [String:AnyObject]
                {
                    if let sessionID = session[JSONResponseKeys.SessionID] as? String,
                        let uniqueKeyString = account[JSONResponseKeys.AccountKey] as? String
                    {
                        self.userData.user.uniquekey = uniqueKeyString
                        self.sessionID = sessionID
                        completionHandlerForSession(success: true, sessionID: sessionID, errorString: nil)
                    }else{
                        print("Could not find \(JSONResponseKeys.SessionID) in \(session) or \(JSONResponseKeys.AccountKey) in \(account)")
                        completionHandlerForSession(success: false, sessionID: nil, errorString: "Login Failed (Session ID).")
                    }
                } else {
                    print("Could not find \(JSONResponseKeys.Session) in \(results)")
                    completionHandlerForSession(success: false, sessionID: nil, errorString: "Login Failed (Session ID).")
                }
            }
        }
    }
    
    func getUserInformation(userKey: String, completionHandlerForUserInfo: (success: Bool, user: StudentInformation?, errorString: String?) -> Void) {
        
        taskForUdacityGETMethod(userKey) { (results, error) in
            if error != nil {
                completionHandlerForUserInfo(success: false, user: nil, errorString: "UserData retrieval failed")
            } else {
                if let user = results["user"] as? [String:AnyObject]
                {
                    if let firstName = user["first_name"] as? String,
                        let lastName = user["last_name"] as? String{
                        
                        self.userData.user.firstName = firstName
                        self.userData.user.lastName = lastName
                        
                        if let mediaURL = user["website_url"] as? String{
                            self.userData.user.mediaURL = mediaURL
                        }else{
                            self.userData.user.mediaURL = "http://www.google.com"
                        }
                        
                        completionHandlerForUserInfo(success: true, user: self.userData.user, errorString: nil)
                    }else {
                        print("Could not find \("first_name"), \("last_name") or \("website_url") in \(user)")
                        completionHandlerForUserInfo(success: false, user: nil, errorString: "UserData retrieval failed")
                    }
                } else {
                    print("Could not find \("user") in \(results)")
                    completionHandlerForUserInfo(success: false, user: nil, errorString: "UserData retrieval failed")
                }
            }
        }
    }
    
    // MARK: PARSE Interface Methods
    func getStudentLocations(completionHandlerForStudentLocations: ( students: [StudentInformation]?, errorString: String?) -> Void ) -> Void {
        
        taskForParseGETMethod() { (results, error) in
            if let error = error {
                print(error)
                completionHandlerForStudentLocations( students: nil, errorString: "Loading Student Information failed" )
            } else{
                if let studentInfoDictionairy = results["results"] as? [[String:AnyObject]] {
                    let studentInformation = StudentInformation.studentInformationFromResults(studentInfoDictionairy)
                    completionHandlerForStudentLocations(students: studentInformation, errorString: nil)
                } else{
                    completionHandlerForStudentLocations( students: nil, errorString: "Could not parse StudentInformation results")
                }
            }
        }
    }
    
    func setStudentLocationAndUrl(completionHandlerForStudentLocations: (success: Bool, errorString: String?) -> Void){
        
        let jsonBody = "{\"uniqueKey\": \"\(self.userData.user.uniquekey)\", \"firstName\": \"\(self.userData.user.firstName)\", \"lastName\": \"\(self.userData.user.lastName)\", \"mapString\": \"\(self.userData.user.mapString)\", \"mediaURL\": \"\(self.userData.user.mediaURL)\",\"latitude\": \(self.userData.user.latitude), \"longitude\": \(self.userData.user.longitude)}"
        
        taskForParsePOSTMethod(jsonBody) { (results, error) in
            if error == nil {
                completionHandlerForStudentLocations(success: true, errorString: nil)
            } else{
                print(error)
                completionHandlerForStudentLocations( success: false, errorString: "Could not update StudentLocation")
            }
        }
        
    }
    
}
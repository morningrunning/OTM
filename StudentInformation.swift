//
//  StudentInformation.swift
//  OTM
//
//  Created by Ronald Morgan on 8/4/16.
//  Copyright © 2016 Ronald Morgan. All rights reserved.
//


struct StudentInformation   {
    
    // MARK: Properties
    var uniquekey: String
    var lastName: String
    var firstName: String
    var mediaURL: String
    var mapString: String
    var longitude: Double
    var latitude: Double
    
    // MARK: Initializers
    
    // construct StudentInformation dictionary
    init(dictionary: [String:AnyObject]) {
        uniquekey = dictionary[OTMClient.JSONResponseKeys.UniqueKey] as! String
        firstName = dictionary[OTMClient.JSONResponseKeys.FirstName] as! String
        lastName = dictionary[OTMClient.JSONResponseKeys.LastName] as! String
        mediaURL = dictionary[OTMClient.JSONResponseKeys.MediaURL] as! String
        mapString = dictionary[OTMClient.JSONResponseKeys.MapString] as! String
        longitude = dictionary[OTMClient.JSONResponseKeys.Longitude] as! Double
        latitude = dictionary[OTMClient.JSONResponseKeys.Latitude] as! Double
    }
    
    init(key: String){
        uniquekey = key
        firstName = String()
        lastName = String()
        mediaURL = String()
        mapString = String()
        longitude = Double()
        latitude = Double()
    }
    
    init(){
        uniquekey = String()
        firstName = String()
        lastName = String()
        mediaURL = String()
        mapString = String()
        longitude = Double()
        latitude = Double()
    }
    
    static func studentInformationFromResults(results: [[String:AnyObject]]) -> [StudentInformation] {
        
        var studInf = [StudentInformation]()
        
        for result in results {
            studInf.append(StudentInformation(dictionary: result))
        }
        
        return studInf
    }
}
//
//  UserData.swift
//  OTM
//
//  Created by Ronald Morgan on 8/4/16.
//  Copyright © 2016 Ronald Morgan. All rights reserved.
//

import Foundation

class UserData {
    
    static let sharedInstance = UserData()
    
    var user : StudentInformation
    
    private init(){
        user = StudentInformation()
    }
}
//
//  StudentData.swift
//  OTM
//
//  Created by Ronald Morgan on 8/4/16.
//  Copyright © 2016 Ronald Morgan. All rights reserved.
//

import Foundation

class StudentData {
    
    static let sharedInstance = StudentData()
    
    var students : [StudentInformation]
    
    private init(){
        students = [StudentInformation]()
    }
}
//
//  Location.swift
//  RainyShinyCloudyyy
//
//  Created by Cookie on 9/15/17.
//  Copyright © 2017 Cookie. All rights reserved.
//

import CoreLocation

class Location {

    static var sharedInstance = Location()
    private init() {}
    
    var latitude: Double!
    var longitude: Double!

}

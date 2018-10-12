//
//  SimpleLocation.swift
//  Balance
//
//  Created by Michael on 3/15/18.
//  Copyright © 2018 poshbaboon. All rights reserved.
//

import Foundation

class SimpleLocation: Codable {
    
    var UniqueId: String
    var Latitude: Double
    var Longitude: Double
    var Timestamp: Date
    var Placemark: SimplePlacemark
    var Activity: ActivityType
    
    required init(id: String, latitude: Double, longitude: Double, timestamp: Date, placemark: SimplePlacemark, type: ActivityType) {
        self.UniqueId = id
        self.Latitude = latitude
        self.Longitude = longitude
        self.Timestamp = timestamp
        self.Placemark = placemark
        self.Activity = type
    }
    
}

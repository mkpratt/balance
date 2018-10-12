//
//  BalanceAnnotation.swift
//  Balance
//
//  Created by Michael on 4/5/18.
//  Copyright © 2018 poshbaboon. All rights reserved.
//

import Foundation
import MapKit

class BalanceAnnotation: NSObject, MKAnnotation {
    var location: SimpleLocation
    var coordinate: CLLocationCoordinate2D
    var image: UIImage
    var identifier: String = "balanceAnnotation"
    
    init(location: SimpleLocation, image: UIImage) {
        self.location = location
        self.coordinate = CLLocationCoordinate2D(latitude: location.Latitude, longitude: location.Longitude)
        self.image = image
        super.init()
    }
    
    var type: ActivityType {
        return location.Activity
    }
    
    func updateImage(image: UIImage) {
        self.image = image
    }
}

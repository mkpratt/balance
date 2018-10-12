//
//  Location.swift
//  Balance
//
//  Created by Michael on 3/8/18.
//  Copyright © 2018 poshbaboon. All rights reserved.
//

import Foundation
import CoreLocation

class CustomLocation {
    
    var Coordinate: CLLocationCoordinate2D
    var Altitude: CLLocationDistance
    var Floor: CLFloor?
    var HorizontalAccuracy: CLLocationAccuracy
    var VerticalAccuracy: CLLocationAccuracy
    var Timestamp: Date

    init(coordinate: CLLocationCoordinate2D, altitude: CLLocationDistance, floor: CLFloor?, horizontalAccuracy: CLLocationAccuracy, verticalAccuracy: CLLocationAccuracy, timestamp: Date) {
        self.Coordinate = coordinate
        self.Altitude = altitude
        self.Floor = floor
        self.HorizontalAccuracy = horizontalAccuracy
        self.VerticalAccuracy = verticalAccuracy
        self.Timestamp = timestamp
    }
    
    init(coder decoder: NSCoder!) {
        self.Coordinate = decoder.decodeObject(forKey: "Coordinate") as! CLLocationCoordinate2D
        self.Altitude = decoder.decodeObject(forKey: "Altitude") as! CLLocationDistance
        self.Floor = decoder.decodeObject(forKey: "Floor") as! CLFloor?
        self.HorizontalAccuracy = decoder.decodeObject(forKey: "HorizontalAccuracy") as! CLLocationAccuracy
        self.VerticalAccuracy = decoder.decodeObject(forKey: "VerticalAccuracy") as! CLLocationAccuracy
        self.Timestamp = decoder.decodeObject(forKey: "Timestamp") as! Date
    }
    
    func initWithCoder(decoder: NSCoder) -> CustomLocation {
        self.Coordinate = decoder.decodeObject(forKey: "Coordinate") as! CLLocationCoordinate2D
        self.Altitude = decoder.decodeObject(forKey: "Altitude") as! CLLocationDistance
        self.Floor = decoder.decodeObject(forKey: "Floor") as! CLFloor?
        self.HorizontalAccuracy = decoder.decodeObject(forKey: "HorizontalAccuracy") as! CLLocationAccuracy
        self.VerticalAccuracy = decoder.decodeObject(forKey: "VerticalAccuracy") as! CLLocationAccuracy
        self.Timestamp = decoder.decodeObject(forKey: "Timestamp") as! Date
        return self
    }
    
    func encodeWithCoder(coder: NSCoder!) {
        coder.encode(Coordinate, forKey: "Coordinate")
        coder.encode(Altitude, forKey: "Altitude")
        coder.encode(Floor, forKey: "Floor")
        coder.encode(HorizontalAccuracy, forKey: "HorizontalAccuracy")
        coder.encode(VerticalAccuracy, forKey: "VerticalAccuracy")
        coder.encode(Timestamp, forKey: "Timestamp")
    }
}

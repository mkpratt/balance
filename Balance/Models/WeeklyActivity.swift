//
//  WeeklyActivity.swift
//  Balance
//
//  Created by Michael on 3/30/18.
//  Copyright © 2018 poshbaboon. All rights reserved.
//

import Foundation

class WeeklyActivity: Codable {
    var StartDate: Date
    var EndDate: Date
    var Locations: Locations?
    
    // empty init
    init() {
        self.StartDate = Date()
        self.EndDate = Date()
    }
    
    required init(start: Date, end: Date, locations: Locations) {
        self.StartDate = start
        self.EndDate = end
        self.Locations = locations
    }
}

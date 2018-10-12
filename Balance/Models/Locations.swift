//
//  Locations.swift
//  Balance
//
//  Created by Michael on 4/2/18.
//  Copyright © 2018 poshbaboon. All rights reserved.
//

import Foundation

class Locations: Codable {
    var Work: [SimpleLocation]
    var Home: [SimpleLocation]
    var Recreational: [SimpleLocation]
    var Sleep: [SimpleLocation]
    var Unknown: [SimpleLocation]
    
    // empty init
    init() {
        self.Work = []
        self.Home = []
        self.Recreational = []
        self.Sleep = []
        self.Unknown = []
    }

    required init(work: [SimpleLocation], home: [SimpleLocation], recreational: [SimpleLocation], sleep: [SimpleLocation], unknown: [SimpleLocation]) {
        self.Work = work
        self.Home = home
        self.Recreational = recreational
        self.Sleep = sleep
        self.Unknown = unknown
    }
    
    func addToWork(location: SimpleLocation) {
        self.Work.append(location)
    }
    
    func addToHome(location: SimpleLocation) {
        self.Home.append(location)
    }
    
    func addToRecreational(location: SimpleLocation) {
        self.Recreational.append(location)
    }
    
    func addToSleep(location: SimpleLocation) {
        self.Sleep.append(location)
    }
    
    func addToUnknown(location: SimpleLocation) {
        self.Unknown.append(location)
    }
}

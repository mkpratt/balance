//
//  ViewController.swift
//  Balance
//
//  Created by Michael on 2/27/18.
//  Copyright © 2018 poshbaboon. All rights reserved.
//

import UIKit
import CoreLocation
import CoreMotion
import Foundation

class LocationListViewController: UITableViewController, CLLocationManagerDelegate  {
    
    private static let UserLocationsKey = "UserLocations"
    private static let KnownUserLocationsKey = "KnownUserLocations"
    private static let WeeklyActivityKey = "WeeklyActivityKey"
    
    let locationManager = CLLocationManager()
    let motionActivityManager = CMMotionActivityManager()
    let geocoder = CLGeocoder()
    
    let defaults = UserDefaults.standard
    var savedLocations: [SimpleLocation] = [] // Need to get rid of this, replace with savedWeeklyActivities
    var savedWeeklyActivities: [WeeklyActivity] = []
    var currentWeeklyActivity: WeeklyActivity = WeeklyActivity()
    var knownUserLocations: Locations = Locations()
    
    var didFindLocation: Bool = false
    
    var currentMotionActivity: String = "Unknown"
    var stationaryMotionActivityStart: Date = Date()
    var temporaryStationaryLocations: [SimpleLocation] = []
    var currentMotionActivityUpdated: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        //locationManager.pausesLocationUpdatesAutomaticAll = true
        
        // Load data
        do {
            try loadWeeklyActivities()
            try loadKnownLocations()
        } catch {
            print(error)
        }
        
        // get location on startup
        if savedWeeklyActivities.count == 0 {
            saveNewWeeklyActivity()
            didFindLocation = false
            getLocation()
        }
        
//        if savedLocations.count == 0 {
//            print("viewDidLoad: get location")
//            didFindLocation = false
//            getLocation()
//            //locationManager.allowDeferredLocationUpdates(untilTraveled: 1, timeout: 5)
//        }
        
        // Timed location grab every 20 minutes
        Timer.scheduledTimer(timeInterval: 20.0, target: self, selector: #selector(LocationListViewController.getLocation), userInfo: nil, repeats: true)
        
        // Only update location once they move outside a 500m radius
        //startReceivingSignificantLocationChanges()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.savedWeeklyActivities.count
        //return self.savedLocations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create a new cell if needed or reuse an old one
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationItemCell", for: indexPath) as! LocationTableCell
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        
        //let date = self.savedLocations[indexPath.row].Timestamp
        
        // set the location text from the data model
        //cell.LocationLabel.text = String(describing: "\(self.savedLocations[indexPath.row].Placemark.Name ?? "Unknown Address"), \(self.savedLocations[indexPath.row].Placemark.SubLocality ?? "Unknown Area"), \(self.savedLocations[indexPath.row].Placemark.Locality ?? "Unknown City"), \(self.savedLocations[indexPath.row].Placemark.AdministrativeArea ?? "Unknown State")")
        
        cell.LocationLabel.text = "Week \(indexPath.row + 1)"
        
        // set the time text from the data model
        cell.TimeLabel.text = "\(dateFormatter.string(from: self.savedWeeklyActivities[indexPath.row].StartDate)) - \(dateFormatter.string(from: self.savedWeeklyActivities[indexPath.row].EndDate))"
        
        return cell
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        // notify user that location isn't working?
    }
    
    // Location Received
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        
        // valid location value (only do once)
        if location.horizontalAccuracy > 0 && !didFindLocation {
            didFindLocation = true
            locationManager.stopUpdatingLocation()
            
            // Look up the location and pass it to the completion handler
            geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                if error == nil {
                    let firstLocation = placemarks?[0]
                    
                    //let simplePlacemark = SimplePlacemark(Name: firstLocation?.name, SubLocality: firstLocation?.subLocality, Locality: firstLocation?.locality, AdministrativeArea: firstLocation?.administrativeArea)
                    //let newLocation = SimpleLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, timestamp: location.timestamp, placemark: simplePlacemark, type: .Unknown)
                    
                    //self.savedLocations.append(newLocation)
                    //self.savedWeeklyActivities.last?.Locations?.addToUnknown(location: newLocation)
                    
                    // determine the location category and activity type
                    //self.organizeLocation(location: newLocation)
                    
                    self.tableView.reloadData()
                    
                    do {
                        try self.saveWeeklyActivities(weeklyActivity: self.savedWeeklyActivities)
                    } catch {
                        print(error)
                    }
                    
                }
                else {
                    // An error occurred during geocoding.
                    print(error!)
                    // Still save location without geocoded placemark?
                }
            })
        }
        
    }
    
    func loadKnownLocations() throws {
        if defaults.object(forKey: LocationListViewController.KnownUserLocationsKey) != nil {
            let jsonDecoder = JSONDecoder()
            if let data = try jsonDecoder.decode(Locations?.self, from: (defaults.object(forKey: LocationListViewController.KnownUserLocationsKey) as? Data)!) {
                knownUserLocations = data
                print("known locations loaded")
            }
        } else {
            knownUserLocations = Locations()
        }
    }
    
    func saveKnownLocations(knownLocations: Locations) throws {
        let jsonEncoder = JSONEncoder()
        let jsonKnownLocations = try jsonEncoder.encode(knownLocations)
        defaults.set(jsonKnownLocations, forKey: LocationListViewController.KnownUserLocationsKey)
        defaults.synchronize()
        print("known locations saved")
    }

    // Rename to loadWeeklyActivities and refactor
//    func loadLocations() throws {
//        if defaults.object(forKey: LocationListViewController.UserLocationsKey) != nil {
//            let jsonDecoder = JSONDecoder()
//            if let data = try jsonDecoder.decode([SimpleLocation]?.self, from: (defaults.object(forKey: LocationListViewController.UserLocationsKey) as? Data)!) {
//                savedLocations = data
//                print("data loaded")
//                print("savedLocations count: ", savedLocations.count)
//                tableView.reloadData()
//            }
//        } else {
//            savedLocations = []
//        }
//    }
    
    // Rename to loadWeeklyActivities and refactor
    func loadWeeklyActivities() throws {
        if defaults.object(forKey: LocationListViewController.WeeklyActivityKey) != nil {
            let jsonDecoder = JSONDecoder()
            if let data = try jsonDecoder.decode([WeeklyActivity]?.self, from: (defaults.object(forKey: LocationListViewController.WeeklyActivityKey) as? Data)!) {
                savedWeeklyActivities = data
                print("data loaded")
                print("savedLocations count: ", savedWeeklyActivities.count)
                tableView.reloadData()
            }
        } else {
            savedLocations = []
        }
    }

    // Rename to saveWeeklyActivities and refactor
//    func saveLocations(locations: [SimpleLocation]) throws {
//        let jsonEncoder = JSONEncoder()
//        let jsonLocations = try jsonEncoder.encode(locations)
//        defaults.set(jsonLocations, forKey: LocationListViewController.UserLocationsKey)
//        defaults.synchronize()
//        print("location saved")
//    }
    
    // Rename to saveWeeklyActivities and refactor
    func saveWeeklyActivities(weeklyActivity: [WeeklyActivity]) throws {
        let jsonEncoder = JSONEncoder()
        let jsonLocations = try jsonEncoder.encode(weeklyActivity)
        defaults.set(jsonLocations, forKey: LocationListViewController.WeeklyActivityKey)
        defaults.synchronize()
        print("location saved")
    }
    
    @IBAction func recordLocation(_ sender: UIBarButtonItem) {
        didFindLocation = false
        getLocation()
        print("record location clicked: recording location")
    }
    
    @IBAction func deleteAllLocations(_ sender: UIBarButtonItem) {
        //savedLocations = []
        savedWeeklyActivities = []
        print("delete all clicked")
        do {
            try saveWeeklyActivities(weeklyActivity: savedWeeklyActivities)
        } catch {
            print(error)
        }
        tableView.reloadData()
    }
    
    @objc func getLocation() {
        didFindLocation = false
        locationManager.startUpdatingLocation()
    }
    
    func getLocationDistance(location1: CLLocation, location2: CLLocation) -> CLLocationDistance {
        return location1.distance(from: location2)
    }
    
    func getSimpleLocationDistance(location1: SimpleLocation, location2: SimpleLocation) -> CLLocationDistance {
        let location1CL = CLLocation(latitude: location1.Latitude, longitude: location1.Longitude)
        let location2CL = CLLocation(latitude: location2.Latitude, longitude: location2.Longitude)
        
        return location1CL.distance(from: location2CL)
    }
    
    
    // HELPER FUNCTIONS
    func saveNewWeeklyActivity() {
        let newWeeklyActivity: WeeklyActivity = WeeklyActivity()
        
        var start = Date.today()
        if start.day() != "Sunday" {
            start = start.previous(.sunday)
        }
        var end = Date.today()
        if end.day() != "Saturday" {
            end = end.next(.saturday)
        }
        
        newWeeklyActivity.StartDate = start
        newWeeklyActivity.EndDate = end
        
        newWeeklyActivity.Locations = Locations()
        
        self.savedWeeklyActivities.append(newWeeklyActivity)
    }
    
    
    func organizeLocation(location: SimpleLocation) -> Void {
        // Check known work locations
        if knownUserLocations.Work.count > 0 {
            for workLocation in knownUserLocations.Work {
                // if the new location is within 20 meters of a known location, add to the known locations
                if getSimpleLocationDistance(location1: location, location2: workLocation) <= 20 {
                    location.Activity = .Work
                    
                    savedWeeklyActivities.last?.Locations?.addToWork(location: location)
                    //knownUserLocations.Work.append(location)
                    
                    return
                }
            }
        }
        
        if knownUserLocations.Home.count > 0 {
            for homeLocation in knownUserLocations.Home {
                // if the new location is within 20 meters of a known location, add to the known locations
                
                if getSimpleLocationDistance(location1: location, location2: homeLocation) <= 20 {
                    if self.currentMotionActivityUpdated && self.currentMotionActivity == "Stationary" {
                        
                        // if 60 minutes has passed with the phone being stationary (probably sleeping)
                        if self.stationaryMotionActivityStart.timeIntervalSinceNow >= 3600 {
                            
                            // Add all temporary unknown stationary locations to sleep, as well as the new location
                            
                            location.Activity = .Sleep
                            
                            savedWeeklyActivities.last?.Locations?.addToSleep(location: location)
                            //knownUserLocations.Sleep.append(location)
                            
                            return
                        } else {
                            location.Activity = .Unknown
                            self.temporaryStationaryLocations.append(location)
                            return
                        }
                    } else {
                        
                        // Add all temporary known stationary locations to home, as well as the new location
                        
                        //location.Activity = .Home
                        
                        savedWeeklyActivities.last?.Locations?.addToHome(location: location)
                        //knownUserLocations.Home.append(location)
                        
                        return
                    }
                }
            }
        }
        
        if knownUserLocations.Recreational.count > 0 {
            for recreationalLocation in knownUserLocations.Recreational {
                // if the new location is within 20 meters of a known location, add to the known locations
                if getSimpleLocationDistance(location1: location, location2: recreationalLocation) <= 20 {
                    //location.Activity = .Recreational
                    
                    savedWeeklyActivities.last?.Locations?.addToRecreational(location: location)
                    //knownUserLocations.Recreational.append(location)
                    
                    return
                }
            }
        }
        
        if knownUserLocations.Unknown.count > 0 {
            for unknownLocation in knownUserLocations.Unknown {
                if getSimpleLocationDistance(location1: location, location2: unknownLocation) <= 20 {
                    location.Activity = .Unknown
                    
                    savedWeeklyActivities.last?.Locations?.addToUnknown(location: location)
                    //knownUserLocations.Unknown.append(location)
                    
                    return
                }
            }
        }
        
        knownUserLocations.Unknown.append(location)
    }
    
    func getUserMotionActivity() -> Void {
        if CMMotionActivityManager.isActivityAvailable() {
            motionActivityManager.startActivityUpdates(to: OperationQueue.main) {
                (activity: CMMotionActivity?) in
                
                guard let activity = activity else { return }
                
                DispatchQueue.main.async {
                    // relatively high confidence of activity accuracy
                    if activity.confidence == .medium || activity.confidence == .high {
                        if activity.stationary {
                            if self.currentMotionActivity != "Stationary" {
                                self.stationaryMotionActivityStart = Date()
                            }
                            self.currentMotionActivity = "Stationary"
                        } else if activity.walking {
                            self.currentMotionActivity = "Walking"
                        } else if activity.running {
                            self.currentMotionActivity = "Running"
                        } else if activity.automotive {
                            self.currentMotionActivity = "Automotive"
                        } else if activity.cycling {
                            self.currentMotionActivity = "Cycling"
                        } else if activity.unknown {
                            self.currentMotionActivity = "Unknown"
                        }
                        
                        self.currentMotionActivityUpdated = true
                        self.motionActivityManager.stopActivityUpdates()
                    }
                }
            }
        } else {
            self.currentMotionActivityUpdated = false
            print("user motion activity not available")
        }
    }
    
}

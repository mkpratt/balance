//
//  LocationsViewController.swift
//  Balance
//
//  Created by Michael on 4/4/18.
//  Copyright © 2018 poshbaboon. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreMotion

class LocationsViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    // TEMPORARY BUTTONS
    @IBOutlet weak var setCenterButton: UIButton!
    @IBAction func setCenter(_ sender: Any) {
        // set center to unknown location coordinates
        let unknownLocation = CLLocationCoordinate2D(latitude: 40.248413, longitude: -111.647581)
        
        //mapView.setCenter(unknownLocation, animated: true)
        
        
        
        let locationSpan: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let userLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(unknownLocation.latitude, unknownLocation.longitude)
        let locationRegion: MKCoordinateRegion = MKCoordinateRegionMake(userLocation, locationSpan)
        
        mapView.setRegion(locationRegion, animated: true)
    }
    
    @IBOutlet weak var showAlertButton: UIButton!
    @IBAction func showAlert(_ sender: Any) {
        // show alert with options
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        for i in [ActivityType.Work, ActivityType.Leisure, ActivityType.Sleep] {
            alert.addAction(UIAlertAction(title: String(describing: "\(i.rawValue)"), style: .default, handler: {(action: UIAlertAction!) in self.printMsg(msg: i.rawValue)}))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // Map view
    @IBOutlet weak var mapView: MKMapView!
    
    // Managers
    let locationManager = CLLocationManager()
    let motionActivityManager = CMMotionActivityManager()
    let geocoder = CLGeocoder()
    
    // Button outlets
    @IBOutlet weak var sleepButton: UIButton!
    @IBOutlet weak var workButton: UIButton!
    @IBOutlet weak var leisureButton: UIButton!
    
    // UserDefaults (storage)
    let defaults = UserDefaults.standard
    
    // UserDefaults Keys
    private static let KnownUserLocationsKey = "KnownUserLocations"
    private static let WeeklyActivityKey = "WeeklyActivityKey"
    
    // Data structures
//    var knownUserLocations: Locations = Locations()
    var knownUserLocations: NSDictionary = [:]
//    var savedWeeklyActivities: [WeeklyActivity] = []
    var savedWeeklyActivities: NSDictionary = [:]
    var currentWeeklyActivity: WeeklyActivity = WeeklyActivity()
    
    // Helper variables
    var didFindLocation: Bool = false
    var firstLocationLoad: Bool = true
    
    var currentMotionActivity: String = "Unknown"
    var stationaryMotionActivityStart: Date = Date()
    var temporaryStationaryLocations: [SimpleLocation] = []
    var currentMotionActivityUpdated: Bool = false
    
    //---- Init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add MKUserTrackingButton
        setupUserTrackingButtonAndScaleView()
        
        // Location manager delegate
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        mapView.delegate = self
        
        // For testing, remove this when done
//        do {
//            //savedWeeklyActivities = []
//            //knownUserLocations = Locations()
//            try saveWeeklyActivities(weeklyActivity: savedWeeklyActivities)
//            try saveKnownLocations(knownLocations: knownUserLocations)
//        } catch {
//            print(error)
//        }
        
        // Load data
        do {
            try loadWeeklyActivities()
            try loadKnownLocations()
        } catch {
            print(error)
        }
        
        // Get location on startup
        if savedWeeklyActivities.count == 0 {
            
            // Add new weekly activity object
            saveNewWeeklyActivity()
            
            // Get current location
            didFindLocation = false
            //getLocation()
        }
        
        getLocation()
        
        // Timed location grab every 20 minutes (currently set to seconds)
        //Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(LocationsViewController.getLocation), userInfo: nil, repeats: true)
    }
    //----
    
    
    //---- Location manager functions
    // Location not working
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        // notify user that location isn't working?
    }
    
    var count: Int = 0
    // Location Received
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
//        let location = locations.last
        
        if firstLocationLoad {
            showUserCurrentLocation(location: location)
            firstLocationLoad = false
        }
        
        // Valid location value (only do once)
        if location.horizontalAccuracy > 0 && !didFindLocation {
            count += 1
            didFindLocation = true
            locationManager.stopUpdatingLocation()
            
            showUserCurrentLocation(location: location)
            
            // Look up the location and pass it to the completion handler
            geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                if error == nil {
                    let firstLocation = placemarks?[0]
                    
                    let uuid = UUID().uuidString
                    
                    let simplePlacemark = SimplePlacemark(Name: firstLocation?.name, SubLocality: firstLocation?.subLocality, Locality: firstLocation?.locality, AdministrativeArea: firstLocation?.administrativeArea)
                    let newLocation = SimpleLocation(id: uuid, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, timestamp: location.timestamp, placemark: simplePlacemark, type: .Unknown)
                    
                    print(newLocation)
                    
                    //print("Location \(self.count): \(uuid)")
                    
                    // Determine the location category and activity type
                    //self.organizeLocation(location: newLocation)

                    // Save latest weekly activity to user defaults
//                    do {
//                        try self.saveWeeklyActivities(weeklyActivity: self.savedWeeklyActivities)
//                    } catch {
//                        print(error)
//                    }
                    
                }
                else {
                    // An error occurred during geocoding.
                    print(error!)
                    // Still save location without geocoded placemark?
                }
            })
        }
        
    }
    //----
    
    
    //---- Loading data
    func loadKnownLocations() throws {
//        if defaults.object(forKey: LocationsViewController.KnownUserLocationsKey) != nil {
//            let jsonDecoder = JSONDecoder()
//            if let data = try jsonDecoder.decode(Locations?.self, from: (defaults.object(forKey: LocationsViewController.KnownUserLocationsKey) as? Data)!) {
//                knownUserLocations = data
//                //print("known locations loaded")
//            }
//        }
//        addKnownLocationAnnotations()
        
        if let data = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "KnownUserLocations", ofType: "plist")!) {
            self.knownUserLocations = data
        }
        addKnownLocationAnnotations()
    }
    
    func loadWeeklyActivities() throws {
//        if defaults.object(forKey: LocationsViewController.WeeklyActivityKey) != nil {
//            let jsonDecoder = JSONDecoder()
//            if let data = try jsonDecoder.decode([WeeklyActivity]?.self, from: (defaults.object(forKey: LocationsViewController.WeeklyActivityKey) as? Data)!) {
//                savedWeeklyActivities = data
////                print("data loaded")
////                print("savedLocations count: ", savedWeeklyActivities.count)
//            }
//        }
//
//        addUnknownLocationAnnotations()
        
        if let data = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "SavedWeeklyActivities", ofType: "plist")!) {
            self.savedWeeklyActivities = data
        }
        addUnknownLocationAnnotations()
    }
    //----
    
    
    //---- Saving data
    func saveKnownLocations(knownLocations: Locations) throws {
        let jsonEncoder = JSONEncoder()
        let jsonKnownLocations = try jsonEncoder.encode(knownLocations)
        defaults.set(jsonKnownLocations, forKey: LocationsViewController.KnownUserLocationsKey)
        defaults.synchronize()
        //print("known locations saved")
    }
    
    func saveWeeklyActivities(weeklyActivity: [WeeklyActivity]) throws {
        let jsonEncoder = JSONEncoder()
        let jsonLocations = try jsonEncoder.encode(weeklyActivity)
        defaults.set(jsonLocations, forKey: LocationsViewController.WeeklyActivityKey)
        defaults.synchronize()
        //print("weekly activities saved")
    }
    //----
    
    
    //---- Data structure helpers
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
        
        //self.savedWeeklyActivities.append(newWeeklyActivity)
    }
    //----
    
    
    //---- Map view helpers
//    func addAnnotation(location: SimpleLocation, image: UIImage) {
//        let newAnnotation = BalanceAnnotation(location: location, image: image)
//        self.mapView.addAnnotation(newAnnotation)
//    }
    
    func addAnnotation(location: SimpleLocation, image: UIImage) {
        let newAnnotation = BalanceAnnotation(location: location, image: image)
        self.mapView.addAnnotation(newAnnotation)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? BalanceAnnotation {
            if let view = mapView.dequeueReusableAnnotationView(withIdentifier: annotation.identifier) {
                return view
            } else {
                let view = MKAnnotationView(annotation: annotation, reuseIdentifier: annotation.identifier)
                view.image = annotation.image
                return view
            }
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if let annotation = view.annotation as? BalanceAnnotation {
            print("Selected \(annotation.location.UniqueId)")
            if annotation.type == .Unknown {
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
                for i in [ActivityType.Work, ActivityType.Leisure, ActivityType.Sleep] {
                    alert.addAction(UIAlertAction(title: String(describing: "\(i.rawValue)"), style: .default, handler: {(action: UIAlertAction!) in self.assignLocation(location: annotation.location, type: i, annotation: annotation)}))
                }
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    // MKUserTrackingButton
    func setupUserTrackingButtonAndScaleView() {
        mapView.showsUserLocation = true
        
        let button = MKUserTrackingButton(mapView: mapView)
        button.layer.backgroundColor = UIColor(white: 1, alpha: 0.8).cgColor
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        
        let scale = MKScaleView(mapView: mapView)
        scale.legendAlignment = .trailing
        scale.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scale)
        
        NSLayoutConstraint.activate([button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
                                     button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
                                     scale.trailingAnchor.constraint(equalTo: button.leadingAnchor, constant: -10),
                                     scale.centerYAnchor.constraint(equalTo: button.centerYAnchor)])
    }
    //---
    
    
    //---- Location helpers
    @objc func getLocation() {
        didFindLocation = false
        locationManager.startUpdatingLocation()
    }
    
    // Organize locations into their categories
    func organizeLocation(location: SimpleLocation) -> Void {
        
        // Check known work locations
        if let workArray = knownUserLocations["Work"] as? [[String:Any]] {
            for workObject in workArray {
                let latitude = workObject["Latitude"] as? Double
                let longitude = workObject["Longitude"] as? Double
                let location1 = CLLocation(latitude: latitude!, longitude: longitude!)
                let location2 = CLLocation(latitude: location.Latitude, longitude: location.Longitude)
                
                if getLocationDistance(location1: location1, location2: location2) >= 25 {
                    location.Activity = .Work
//                    savedWeeklyActivities.last?.Locations?.addToWork(location: location)
//                    do {
//                        try saveWeeklyActivities(weeklyActivity: savedWeeklyActivities)
//                    } catch {
//                        print(error)
//                    }
                }
                
//                if getSimpleLocationDistance(location1: location, location2: workLocation) >= 25 {
//                    location.Activity = .Work
//                    savedWeeklyActivities.last?.Locations?.addToWork(location: location)
//                    //addAnnotation(location: location, image: UIImage(named: "work-annotation")!)
//
//                    do {
//                        try saveWeeklyActivities(weeklyActivity: savedWeeklyActivities)
//                    } catch {
//                        print(error)
//                    }
//                }
            }
        }
        
        
        
//        if knownUserLocations.Work.count > 0 {
//            for workLocation in knownUserLocations.Work {
//
//                // If the new location is within 20 meters of a known location, add to the known locations
//                if getSimpleLocationDistance(location1: location, location2: workLocation) >= 25 {
//                    location.Activity = .Work
//                    savedWeeklyActivities.last?.Locations?.addToWork(location: location)
//                    //addAnnotation(location: location, image: UIImage(named: "work-annotation")!)
//
//                    do {
//                        try saveWeeklyActivities(weeklyActivity: savedWeeklyActivities)
//                    } catch {
//                        print(error)
//                    }
//                }
//            }
//        }

//        if knownUserLocations.Home.count > 0 {
//            for homeLocation in knownUserLocations.Home {
//                // if the new location is within 20 meters of a known location, add to the known locations
//
//                if getSimpleLocationDistance(location1: location, location2: homeLocation) >= 25 {
//                    if self.currentMotionActivityUpdated && self.currentMotionActivity == "Stationary" {
//
//                        // if 60 minutes has passed with the phone being stationary (probably sleeping)
//                        if self.stationaryMotionActivityStart.timeIntervalSinceNow >= 3600 {
//
//                            // Add all temporary unknown stationary locations to sleep, as well as the new location
//
//                            location.Activity = .Sleep
//                            savedWeeklyActivities.last?.Locations?.addToSleep(location: location)
//                            //addAnnotation(location: location, image: UIImage(named: "sleep-annotation")!)
//
//                            do {
//                                try saveWeeklyActivities(weeklyActivity: savedWeeklyActivities)
//                            } catch {
//                                print(error)
//                            }
//                        } else {
//                            location.Activity = .Unknown
//                            self.temporaryStationaryLocations.append(location)
//                            return
//                        }
//                    } else {
//                        // Add all temporary known stationary locations to home, as well as the new location
//
//                        location.Activity = .Home
//                        savedWeeklyActivities.last?.Locations?.addToHome(location: location)
//                        //addAnnotation(location: location, image: UIImage(named: "home-up-annotation")!)
//
//                        do {
//                            try saveWeeklyActivities(weeklyActivity: savedWeeklyActivities)
//                        } catch {
//                            print(error)
//                        }
//                    }
//                }
//            }
//        }
//
//        if knownUserLocations.Recreational.count > 0 {
//            for recreationalLocation in knownUserLocations.Recreational {
//                // if the new location is within 20 meters of a known location, add to the known locations
//                if getSimpleLocationDistance(location1: location, location2: recreationalLocation) >= 25 {
//                    location.Activity = .Recreational
//                    savedWeeklyActivities.last?.Locations?.addToRecreational(location: location)
//                    //addAnnotation(location: location, image: UIImage(named: "rec-annotation")!)
//
//                    do {
//                        try saveWeeklyActivities(weeklyActivity: savedWeeklyActivities)
//                    } catch {
//                        print(error)
//                    }
//                }
//            }
//        }
//
//        if (savedWeeklyActivities.last?.Locations?.Unknown.count)! > 0 {
//            for unknownLocation in (savedWeeklyActivities.last?.Locations?.Unknown)! {
//                //print(getSimpleLocationDistance(location1: location, location2: unknownLocation))
//                if getSimpleLocationDistance(location1: location, location2: unknownLocation) >= 25 {
//                    location.Activity = .Unknown
//                    savedWeeklyActivities.last?.Locations?.addToUnknown(location: location)
//                    addAnnotation(location: location, image: UIImage(named: "unknown-annotation")!)
//
//                    do {
//                        try saveWeeklyActivities(weeklyActivity: savedWeeklyActivities)
//                    } catch {
//                        print(error)
//                    }
//
//                    return
//                }
//            }
//        } else {
//            savedWeeklyActivities.last?.Locations?.addToUnknown(location: location)
//            addAnnotation(location: location, image: UIImage(named: "unknown-annotation")!)
//
//            do {
//                try saveWeeklyActivities(weeklyActivity: savedWeeklyActivities)
//            } catch {
//                print(error)
//            }
//
//            return
//        }
    }
    
    // TEMPORARY
    func printMsg(msg: String) {
        print(msg)
    }
    
    func assignLocation(location: SimpleLocation, type: ActivityType, annotation: BalanceAnnotation) {
        
        location.Activity = type
        
//        switch type {
//            case .Work:
//                savedWeeklyActivities.last?.Locations?.addToWork(location: location)
//                knownUserLocations.addToWork(location: location)
//                //annotation.updateImage(image: UIImage(named: "work-annotation")!)
//            case .Home:
//                savedWeeklyActivities.last?.Locations?.addToHome(location: location)
//                knownUserLocations.addToHome(location: location)
//                //annotation.updateImage(image: UIImage(named: "home-up-annotation")!)
//            case .Recreational:
//                savedWeeklyActivities.last?.Locations?.addToRecreational(location: location)
//                knownUserLocations.addToRecreational(location: location)
//                //annotation.updateImage(image: UIImage(named: "rec-annotation")!)
//            case .Sleep:
//                savedWeeklyActivities.last?.Locations?.addToSleep(location: location)
//                knownUserLocations.addToSleep(location: location)
//                //annotation.updateImage(image: UIImage(named: "sleep-annotation")!)
//            default:
//                // Shouldn't ever reach here
//                return
//        }
        
        //for (idx, activity) in (savedWeeklyActivities.last?.Locations?.Unknown)!.enumerated() {
        //    if activity.Activity != .Unknown {
        //        savedWeeklyActivities.last?.Locations?.Unknown.remove(at: idx)
        //    }
        //}
        print(type)
//        do {
//            try saveWeeklyActivities(weeklyActivity: savedWeeklyActivities)
//            try saveKnownLocations(knownLocations: knownUserLocations)
//
//        } catch {
//            print(error)
//        }
        
        //resetAnnotations()
        
//        do {
//            try loadWeeklyActivities()
//            try loadKnownLocations()
//        } catch {
//            print(error)
//        }
    }
    
    func resetAnnotations() {
        for a in mapView.annotations {
            mapView.removeAnnotation(a)
        }
        
        addKnownLocationAnnotations()
        addUnknownLocationAnnotations()
    }
    
    func addKnownLocationAnnotations() {
        // Show map annotations for each known user location
//        for work in knownUserLocations.Work {
//            addAnnotation(location: work, image: UIImage(named: "work-annotation")!)
//        }
//        for leisure in knownUserLocations.Home {
//            addAnnotation(location: leisure, image: UIImage(named: "rec-annotation")!)
//        }
//        for sleep in knownUserLocations.Sleep {
//            addAnnotation(location: sleep, image: UIImage(named: "sleep-annotation")!)
//        }
        
        let locationTypes = ["Work", "Leisure", "Sleep"]
        for type in locationTypes {
            for knownUserLocation in (knownUserLocations[type] as? [[String:Any]])! {
                let placemark = knownUserLocation["Placemark"] as? [String:String]
                let simplePlacemark = SimplePlacemark(Name: placemark?["Name"], SubLocality: placemark?["Sublocality"], Locality: placemark?["SubLocality"] ?? "Unknown", AdministrativeArea: placemark?["AdministrativeArea"])
                let activity = knownUserLocation["Activity"] as? String
                
                let simpleLocation = SimpleLocation(id: (knownUserLocation["UniqueId"] as? String)!, latitude: (knownUserLocation["Latitude"] as? Double)!, longitude: (knownUserLocation["Longitude"] as? Double)!, timestamp: (knownUserLocation["Timestamp"] as? Date)!, placemark: simplePlacemark, type: ActivityType(rawValue: activity!)!)
                
                addAnnotation(location: simpleLocation, image: UIImage(named: "\(type.lowercased())-annotation")!)
            }
        }
    }
    
    func addUnknownLocationAnnotations() {
        // Show map annotations for each unknown user location
//        if savedWeeklyActivities.count > 0 {
//            for unknown in (savedWeeklyActivities.last?.Locations?.Unknown)! {
//                addAnnotation(location: unknown, image: UIImage(named: "unknown-annotation")!)
//            }
//        }
        for unknownUserLocation in (savedWeeklyActivities["Unknown"] as? [[String:Any]])! {
            let placemark = savedWeeklyActivities["Placemark"] as? [String:String]
            let simplePlacemark = SimplePlacemark(Name: placemark?["Name"], SubLocality: placemark?["Sublocality"], Locality: placemark?["SubLocality"] ?? "Unknown", AdministrativeArea: placemark?["AdministrativeArea"])
            let activity = unknownUserLocation["Activity"] as? String
            
            let simpleLocation = SimpleLocation(id: (unknownUserLocation["UniqueId"] as? String)!, latitude: (unknownUserLocation["Latitude"] as? Double)!, longitude: (unknownUserLocation["Longitude"] as? Double)!, timestamp: (unknownUserLocation["Timestamp"] as? Date)!, placemark: simplePlacemark, type: ActivityType(rawValue: activity!)!)
            
            addAnnotation(location: simpleLocation, image: UIImage(named: "unknown-annotation")!)
        }
    }
    
    func showUserCurrentLocation(location: CLLocation) {
        // Show user's current location on the map
        let locationSpan: MKCoordinateSpan = MKCoordinateSpanMake(0.05, 0.05)
        let userLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let locationRegion: MKCoordinateRegion = MKCoordinateRegionMake(userLocation, locationSpan)
        // Set user location region and update map
        mapView.setRegion(locationRegion, animated: true)
        //self.mapView.showsUserLocation = true;
    }
    
    func getLocationDistance(location1: CLLocation, location2: CLLocation) -> CLLocationDistance {
        return location1.distance(from: location2)
    }
    
    func getSimpleLocationDistance(location1: SimpleLocation, location2: SimpleLocation) -> CLLocationDistance {
        let location1CL = CLLocation(latitude: location1.Latitude, longitude: location1.Longitude)
        let location2CL = CLLocation(latitude: location2.Latitude, longitude: location2.Longitude)
        
        return location1CL.distance(from: location2CL)
    }
    //----
    
    
    //---- Motion helpers
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
    //----
}

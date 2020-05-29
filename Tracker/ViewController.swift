//
//  ViewController.swift
//  Tracker
//
//  Created by Gronsky on 5/4/20.
//  Copyright © 2020 Gronsky. All rights reserved.
//

import UIKit
import CoreLocation
import HealthKit


class ViewController: UIViewController {
    
    let central = BLECentral()
    let locationManager = CLLocationManager()
    var routeBuilder = HKWorkoutRouteBuilder(healthStore: HKHealthStore(), device: nil)

    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var avgSpeedLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var heartRateLabel: UILabel!
    
    var initialTime:Int64 = 0
    var timePastInSeconds:Int64 = 0
    var currentTimeInSeconds:Int64 = 0
    var timer = Timer()
    var isPlaying = false
    
    var prevLocation: CLLocation = CLLocation(latitude: 0, longitude: 0)
    var currentLocation: CLLocation = CLLocation(latitude: 0, longitude: 0)
    var distance: CLLocationDistance = 0.0

    override func viewDidLoad()
    {
        super.viewDidLoad()
        startButton.setTitle("START", for: .normal)
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        central.onDataUpdated = onDataUpdated  // give me my subscriber 1-1
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "bluetoothSegue" {
            let controller = segue.destination as! PeripheralsViewController
            controller.central = central
        }
    }
    
    func onDataUpdated(value: Int) {
        heartRateLabel.text = String(value)
    }

    @IBAction func StartButtonPressed(_ sender: UIButton) {
        if(isPlaying == false)
        {
            isPlaying = true
            startButton.setTitle("STOP", for: .normal)
            initialTime = Int64(NSDate().timeIntervalSince1970)
            timer = Timer.scheduledTimer(
                timeInterval: 1,
                target: self,
                selector: #selector(UpdateTimer),
                userInfo: nil,
                repeats: true)
            
            guard let locValue: CLLocationCoordinate2D = locationManager.location?.coordinate else { return }
            prevLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
            
        }
        else
        {
            timePastInSeconds = currentTimeInSeconds
            isPlaying = false
            startButton.setTitle("RESUME", for: .normal)
            timer.invalidate()
        }
    }
    
    
// MARK: Private funcs
    
    @objc private func UpdateTimer() {
        getCurrentLocation()
        currentTimeInSeconds = Int64(NSDate().timeIntervalSince1970) + timePastInSeconds - initialTime;
        
        timeLabel.text = secondsToHoursMinutesSeconds(seconds: currentTimeInSeconds)
        distanceLabel.text = String(format: "%.1f", distance / 1000)
        avgSpeedLabel.text = String(format: "%.1f", distance * 5 / (Double(currentTimeInSeconds) * 18))
    }
    
    private func secondsToHoursMinutesSeconds (seconds : Int64) -> String {
        let _hours = seconds / 3600
        let _minutes = (seconds % 3600) / 60
        let _seconds = (seconds % 3600) % 60
        return String("\(_hours):\(_minutes):\(_seconds)")
    }
    
    private func getCurrentLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            
            
        }
    }
}


// MARK: Extensions

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // update distance
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate
            else { return }
        currentLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
        distance = distance + (currentLocation.distance(from: prevLocation))
        prevLocation = currentLocation
        
        // Filter the raw data.
        let filteredLocations = locations.filter { (location: CLLocation) -> Bool in
            location.horizontalAccuracy <= 50.0
        }
        
        guard !filteredLocations.isEmpty else { return }
        
        // Add the filtered data to the route.
        routeBuilder.insertRouteData(filteredLocations) { (success, error) in
            if !success {
                // Handle any errors here.
            }
        }
    }
}
    

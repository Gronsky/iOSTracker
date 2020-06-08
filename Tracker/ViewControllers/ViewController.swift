//
//  ViewController.swift
//  Tracker
//
//  Created by Anastasia on 5/4/20.
//  Copyright © 2020 Gronsky. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import HealthKit


class ViewController: UIViewController {
   
    let central = BLECentral()
    let locationManager = CLLocationManager()
    let metadata = [HKMetadataKeyIndoorWorkout:false]
    
    var distanceQuantity = HKQuantity(unit: HKUnit.meter(), doubleValue: 0.0)
    var energyBurned = HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: 0)
    var routeBuilder = HKWorkoutRouteBuilder(healthStore: HKHealthStore(), device: nil)
    var healthStore = HKHealthStore()
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var avgSpeedLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var heartRateLabel: UILabel!
    
    var initialTime: Int64 = 0
    var timePastInSeconds: Int64 = 0
    var durationInSeconds: Int64 = 0
    var timer = Timer()
    var isPlaying = false
    
    var prevLocation: CLLocation = CLLocation(latitude: 0, longitude: 0)
    var currentLocation: CLLocation = CLLocation(latitude: 0, longitude: 0)
    var locationList: [CLLocation] = []
    var distance: CLLocationDistance = 0.0

    override func viewDidLoad()
    {
        super.viewDidLoad()
        startButton.setTitle("START", for: .normal)
        finishButton.isHidden = true
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        central.onDataUpdated = onDataUpdated  // give me my subscriber 1-1
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "bluetoothSegue" {
            let controller = segue.destination as! PeripheralsViewController
            controller.central = central
        }
        else if segue.identifier == "resultSegue" {
            let controller = segue.destination as! ResultViewController
            controller.locationList = locationList
            controller.distance = distance
            controller.duration = durationInSeconds
        }
    }
    
    func onDataUpdated(value: Int) {
        heartRateLabel.text = String(value)
    }

    @IBAction func startButtonPressed(_ sender: UIButton) {
        if(isPlaying == false)
        {  // start or resume
            finishButton.isHidden = true
            startButton.setTitle("STOP", for: .normal)
            isPlaying = true
            initialTime = Int64(NSDate().timeIntervalSince1970)
            timer = Timer.scheduledTimer(
                timeInterval: 1,
                target: self,
                selector: #selector(updateTimer),
                userInfo: nil,
                repeats: true)
            
            guard let locValue: CLLocationCoordinate2D = locationManager.location?.coordinate else { return }
            prevLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
            
        }
        else
        {   // stop
            finishButton.isHidden = false
            timePastInSeconds = durationInSeconds
            startButton.setTitle("RESUME", for: .normal)
            isPlaying = false
            timer.invalidate()
        }
    }
    
    @IBAction func finishButtonPressed(_ sender: UIButton) {
        timer.invalidate()
    }
    
    
    
    // MARK: Private funcs
    
    @objc private func updateTimer() {
        getCurrentLocation()
        durationInSeconds = Int64(NSDate().timeIntervalSince1970) + timePastInSeconds - initialTime;
        
        updateLabels(seconds: durationInSeconds, distance: distance)
    }
    
    private func updateLabels(seconds: Int64, distance: Double) {
        timeLabel.text = secondsToHoursMinutesSeconds(seconds: seconds)
        distanceLabel.text = String(format: "%.1f", distance / 1000)
        
        if (seconds == 0) {
            avgSpeedLabel.text = "0.0"
        } else {
            avgSpeedLabel.text = String(format: "%.1f", distance * 5 / (Double(seconds) * 18))
        }
    }
    
    private func secondsToHoursMinutesSeconds (seconds: Int64) -> String {
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
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate
            else { return }
        
        currentLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
        locationList.append(currentLocation)
        distance = distance + (currentLocation.distance(from: prevLocation))
        prevLocation = currentLocation
    }
}
    

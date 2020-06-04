//
//  InterfaceController.swift
//  Watch Tracker Extension
//
//  Created by Anastasia on 5/22/20.
//  Copyright © 2020 Gronsky. All rights reserved.
//

import WatchKit
import Foundation
import CoreLocation
import MapKit
import HealthKit

class InterfaceController: WKInterfaceController {
    
    let locationManager = CLLocationManager()

    @IBOutlet weak var timeLabel: WKInterfaceLabel!
    @IBOutlet weak var avgSpeedLabel: WKInterfaceLabel!
    @IBOutlet weak var distanceLabel: WKInterfaceLabel!
    @IBOutlet weak var heartRateLabel: WKInterfaceLabel!
    @IBOutlet weak var startButton: WKInterfaceButton!
    @IBOutlet weak var finishButton: WKInterfaceButton!
    
    // healthKit properties
    var healthStore: HKHealthStore?
    var lastHeartRate = 0.0
    let beatCountPerMinute = HKUnit(from: "count/min")
    
    var initialTime:Int64 = 0
    var timePastInSeconds:Int64 = 0
    var currentTimeInSeconds:Int64 = 0
    var timer = Timer()
    var isPlaying = false
       
    var prevLocation: CLLocation = CLLocation(latitude: 0, longitude: 0)
    var currentLocation: CLLocation = CLLocation(latitude: 0, longitude: 0)
    var locationList: [CLLocation] = []
    var distance: CLLocationDistance = 0.0
       
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        finishButton.setHidden(true)
        
        let sampleType: Set<HKSampleType> = [HKSampleType.quantityType(forIdentifier: .heartRate)!]
        
        healthStore = HKHealthStore()
        
        healthStore?.requestAuthorization(toShare: sampleType, read: sampleType, completion: { (success, error) in
            if success {
                self.startHeartRateQuery(quantityTypeIdentifier: .heartRate)
            }
        })
    }

    override func willActivate() {
        super.willActivate()
        startButton.setTitle("START")
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
    }

    override func didDeactivate() {
        super.didDeactivate()
    }
    
    override func contextForSegue(withIdentifier segueIdentifier: String) -> Any? {
        if segueIdentifier == "finishSegue" {
            return self.locationList
        } else {
            return nil
        }
    }
    
    
    // HealthKit
    
    private func startHeartRateQuery(quantityTypeIdentifier: HKQuantityTypeIdentifier) {
        
        let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
        let updateHandler: (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void = {
            query, samples, deletedObjects, queryAnchor, error in

            guard let samples = samples as? [HKQuantitySample] else { return }
            self.process(samples, type: quantityTypeIdentifier)
        }
        
        let query = HKAnchoredObjectQuery(type: HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier)!, predicate: devicePredicate, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: updateHandler)
        
        query.updateHandler = updateHandler
        healthStore?.execute(query)
    }
       
    private func process(_ samples: [HKQuantitySample], type: HKQuantityTypeIdentifier) {
        for sample in samples {
            if type == .heartRate {
                lastHeartRate = sample.quantity.doubleValue(for: beatCountPerMinute)
                print("❤ Last heart rate was: \(lastHeartRate)")
            }
            
            updateHeartRateLabel()
        }
    }
       
    private func updateHeartRateLabel() {
        let heartRate = String(Int(lastHeartRate))
        heartRateLabel.setText(heartRate)
    }
       
    
    @IBAction func StartButtonPressed() {
            if(isPlaying == false)
            {
                finishButton.setHidden(true)
                isPlaying = true
                startButton.setTitle("STOP")
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
                finishButton.setHidden(false)
                timePastInSeconds = currentTimeInSeconds
                isPlaying = false
                startButton.setTitle("RESUME")
                timer.invalidate()
            }
        }
    
    
    @IBAction func finishButtonPressed() {
        startButton.setTitle("START")
        finishButton.setHidden(true)
        
        initialTime = 0
        timePastInSeconds = 0
        //durationInSeconds = 0
        isPlaying = false
        timer.invalidate()
        
        //distance = 0.0
        UpdateLabels(seconds: currentTimeInSeconds, distance: distance)
        
        // TODO: loc coord update
     
    }
    
    // MARK: Timer
    
    @objc private func UpdateTimer() {
        getCurrentLocation()
        currentTimeInSeconds = Int64(NSDate().timeIntervalSince1970) + timePastInSeconds - initialTime;
        
        UpdateLabels(seconds: currentTimeInSeconds, distance: distance)
    }
    
    private func UpdateLabels(seconds: Int64, distance: Double)
    {
        let time = secondsToHoursMinutesSeconds(seconds: currentTimeInSeconds)
        timeLabel.setText(time)
        distanceLabel.setText(String(format: "%.1f", distance / 1000))
        avgSpeedLabel.setText(String(format: "%.1f", distance * 5 / (Double(currentTimeInSeconds) * 18)))
    }
    
    private func secondsToHoursMinutesSeconds (seconds : Int64) -> String {
        let _hours = seconds / 3600
        let _minutes = (seconds % 3600) / 60
        let _seconds = (seconds % 3600) % 60
        return String("\(_hours):\(_minutes):\(_seconds)")
    }
    
    
    // MARK: Location
    
    private func getCurrentLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
}


// MARK: Extensions

extension InterfaceController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("latitude = \(locValue.latitude), longitude = \(locValue.longitude)")
        currentLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
         locationList.append(currentLocation)
        distance = distance + (currentLocation.distance(from: prevLocation))
        prevLocation = currentLocation
    }
}

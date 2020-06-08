//
//  ResultInterfaceController.swift
//  Watch Tracker Extension
//
//  Created by Anastasia on 6/1/20.
//  Copyright © 2020 Gronsky. All rights reserved.
//

import WatchKit
import CoreLocation
import MapKit

class ResultInterfaceController: WKInterfaceController {
    
    @IBOutlet weak var mapView: WKInterfaceMap!
    @IBOutlet weak var distanceLabel: WKInterfaceLabel!
    @IBOutlet weak var durationLabel: WKInterfaceLabel!
    
    @IBOutlet weak var dateLabel: WKInterfaceLabel!
    
    
    var locationList: [CLLocation] = []
    var distance: Double = 0.0
    var duration: String?
    let dateFormatter = DateFormatter()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        if let (locations, timeInSeconds, distance) = context as? ([CLLocation], Int64, CLLocationDistance)  {
            self.locationList = locations
            self.duration = secondsToHoursMinutesSeconds(seconds: timeInSeconds)
            self.distance = distance
        }
        
        loadMap()
        loadLabels()
    }
    
    private func mapRegion() -> MKCoordinateRegion? {dateFormatter.string(from: Date())
          guard
            locationList.count > 0
          else { return nil }
            
          let latitudes = locationList.map { location -> Double in
            return location.coordinate.latitude
          }
          let longitudes = locationList.map { location -> Double in
            return location.coordinate.longitude
          }
            
          let maxLat = latitudes.max()!
          let minLat = latitudes.min()!
          let maxLong = longitudes.max()!
          let minLong = longitudes.min()!
            
          let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2,
                                              longitude: (minLong + maxLong) / 2)
          let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.3,
                                      longitudeDelta: (maxLong - minLong) * 1.3)
            
          return MKCoordinateRegion(center: center, span: span)
        }
        
        private func loadMap() {
            guard locationList.count > 0,
            let region = mapRegion()
            else {
                let actionOK = WKAlertAction(title: "OK", style: .cancel) {}
                
                presentAlert(withTitle:"Oops!", message:"Sorry, this run has no locations saved",
                             preferredStyle:.actionSheet, actions: [actionOK])
                return
            }
            
            let finishCoordinate = CLLocationCoordinate2DMake((locationList.last?.coordinate.latitude)!, (locationList.last?.coordinate.longitude)!)
            mapView.setRegion(region)
            mapView.addAnnotation(finishCoordinate, with: .red)
        }
    
        private func loadLabels() {
            durationLabel.setText(duration)
            dateLabel.setText("Date: \(dateFormatter.string(from: Date()))")
            distanceLabel.setText("Distance: \(String(format: "%.1f", distance / 1000)) km")
        }
    
        private func secondsToHoursMinutesSeconds (seconds : Int64) -> String {
            let _hours = seconds / 3600
            let _minutes = (seconds % 3600) / 60
            let _seconds = (seconds % 3600) % 60
            return String("\(_hours):\(_minutes):\(_seconds)")
        }
    }

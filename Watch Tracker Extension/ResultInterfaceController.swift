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
    @IBOutlet weak var resultLabel: WKInterfaceLabel!
    
    var locationList: [CLLocation] = []
    var distance: Double = 0.0
    var duration: String?
    let dateFormatter = DateFormatter()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if let val: [CLLocation] = context as? [CLLocation]  {
            locationList = val
        }
        
        loadMap()
    }
    
    private func mapRegion() -> MKCoordinateRegion? {
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
    }

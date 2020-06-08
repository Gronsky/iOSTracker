//
//  ResultViewController.swift
//  Tracker
//
//  Created by Anastasia on 5/29/20.
//  Copyright © 2020 Gronsky. All rights reserved.
//

import UIKit
import MapKit
import Alamofire

class ResultViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    let url = URL(string: "http://localhost:5000/track")!
    
    var locationList: [CLLocation] = []
    var distance: Double = 0.0
    var duration: String?
    let dateFormatter = DateFormatter()
    var date: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        distanceLabel.text = "\(String(format: "%.1f", distance / 1000)) km"
        timeLabel.text = duration
        dateFormatter.dateFormat = "dd.MM.yyyy"
        date = dateFormatter.string(from: Date())
        dateLabel.text = date
        
        loadMap()
    }
    
    private func mapRegion() -> MKCoordinateRegion? {
      guard
        locationList.count > 0
      else {
        return nil
      }
        
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
    
    private func polyLine() -> MKPolyline {
        guard  locationList.count > 0
        else {
          return MKPolyline()
        }
        
        let coords: [CLLocationCoordinate2D] = locationList.map { location in
        return CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
        let polyline = MKPolyline(coordinates: coords, count: coords.count)
        return polyline
    }
    
    private func loadMap() {
        guard locationList.count > 0,
        let region = mapRegion()
        else {
            let alert = UIAlertController(title: "Error",
                                          message: "Sorry, this run has no locations saved",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(alert, animated: true)
            return
        }
        
        mapView.delegate = self
        mapView.setRegion(region, animated: true)
        mapView.addOverlay(polyLine())
    }
    
    
    private func SaveActivity() {
        do {
            var track = try Track(from: decoder as! Decoder)
            track.Name = "TrackName"
            track.Date = date
            track.Duration = 123
            track.Distance = 23
            track.Description = "TrackDescription"
            track.Sport = "Ride"
            
//            for location in locationList {
//                var coordinate = try Coordinate(from: decoder as! Decoder)
//                coordinate.Latitude = location.coordinate.latitude
//                coordinate.Longitude = location.coordinate.longitude
//                track.Coordinates?.append(coordinate)
//            }
            
            AF.request(url, method: .post, parameters: track)
        }
        catch {
            print(error)
        }
    }
}


// MARK: - Map View Delegate

extension ResultViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
          return MKOverlayRenderer(overlay: overlay)
        }
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 3      
        return renderer
      }
}

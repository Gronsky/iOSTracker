//
//  TableViewController.swift
//  Tracker
//
//  Created by Gronsky on 5/7/20.
//  Copyright © 2020 Gronsky. All rights reserved.
//

import UIKit
import PromiseKit
import Alamofire


class TableViewController: UITableViewController
{
    var tracks = [Track]()
    let url = URL(string: "http://localhost:5000/track")! // "https://jsonplaceholder.typicode.com/posts")!
    
    override func viewDidLoad(){
        super.viewDidLoad()

        getTrackInfo()
            .done { trks -> Void in
                self.tracks += trks
                self.tableView.reloadData()
            }
            .catch { error in
                print(error.localizedDescription)
            }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tracks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCellTableViewCell", for: indexPath) as? TrackCellTableViewCell  else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        
        let model = tracks[indexPath.row]
        cell.title.text = String("\(model.name) - \(model.sport)")
        cell.body.text = String("Distance: \(model.distance) \nDescription: \(model.description) \nTime: \(model.time)")
        
        return cell
    }
    
    func getTrackInfo() -> Promise<[Track]> {
        return Promise { seal in
            AF.request(url)
            .validate()
            .responseDecodable(of: [Track].self) { (response) in
                switch response.result {
                case .success(let data):
                    guard let data = data as [Track]? else {
                        return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
                    }
                    seal.fulfill(data)
                    
                case .failure(let error):
                    seal.reject(error)
                }
                
            }
        }
    }
    
    // MARK: For notifications
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let notificationType = "Local Notification"
        
        let alert = UIAlertController(title: "", message: "After 5 sec will appear notification", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            self.appDelegate?.scheduleNotification(notificationType: notificationType)
            }
        
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
}

enum TodoError: LocalizedError {
    case missing
}

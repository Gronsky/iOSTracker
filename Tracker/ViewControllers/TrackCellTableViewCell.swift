//
//  TrackCellTableViewCell.swift
//  Tracker
//
//  Created by Anastasia on 5/8/20.
//  Copyright © 2020 Gronsky. All rights reserved.
//

import UIKit

class TrackCellTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var body: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}

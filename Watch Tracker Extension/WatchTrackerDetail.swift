//
//  WatchTrackerDetail.swift
//  Watch Tracker Extension
//
//  Created by Gronsky on 5/15/20.
//  Copyright © 2020 Gronsky. All rights reserved.
//

import SwiftUI

struct WatchTrackerDetail: View {
    var body: some View {
        
        ScrollView {
            Text("GronskyTrack")
                .font(.headline)
                .lineLimit(0)
            
            Divider()
            
        }
    }

}
struct WatchTrackerDetail_Previews: PreviewProvider {
    static var previews: some View {
        WatchTrackerDetail()
    }
}


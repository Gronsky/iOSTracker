//
//  ContentView.swift
//  Watch Tracker Extension
//
//  Created by Gronsky on 5/15/20.
//  Copyright © 2020 Gronsky. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ScrollView {
            
            Text("GronskyTracker")
                .font(.headline)
                .colorMultiply(.green)
                .lineLimit(0)
            
            Divider()
            
            Text("Time")
                .font(.headline)
                .colorMultiply(.blue)
            
            Text("0:00:00")
                .font(.title)
            
            Text("AVG Speed")
                .font(.headline)
                .colorMultiply(.yellow)
              
            Text("0.0")
                .font(.title)
          
            Text("Distance")
                .colorMultiply(.purple)
                .font(.headline)
          
            Text("0.0")
                .font(.title)
          
            Text("Heart Rate")
                .colorMultiply(.red)
                .font(.headline)
            
            Text("0")
                .font(.title)

        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

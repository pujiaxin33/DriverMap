//
//  Location.swift
//  Location
//
//  Created by Jiaxin Pu on 2024/11/14.
//

import Foundation
import CoreLocation

struct Location: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let title: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String? = nil) {
        self.coordinate = coordinate
        self.title = title
    }
} 

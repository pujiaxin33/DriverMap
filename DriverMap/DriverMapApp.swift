//
//  DriverMapApp.swift
//  DriverMap
//
//  Created by Jiaxin Pu on 2024/11/13.
//

import SwiftUI
import GoogleMaps

@main
struct DriverMapApp: App {
    
    init() {
        GMSServices.provideAPIKey(AppConfigurations.shared.googleServicesAPI)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

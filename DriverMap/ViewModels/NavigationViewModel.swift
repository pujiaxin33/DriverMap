//
//  NavigationViewModel.swift
//  NavigationViewModel
//
//  Created by Jiaxin Pu on 2024/11/14.
//

import Foundation
import Combine
import CoreLocation
import GoogleMaps

class NavigationViewModel: NSObject, ObservableObject {
    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var destination: Location?
    @Published var isNavigating = false
    @Published var isPlanningRoute: Bool = false
    @Published var isAlertPresented: Bool = false
    @Published var tripDuration: String = ""
    @Published var routePath: GMSPath?
    @Published var startMarker: GMSMarker?
    @Published var destinationMarker: GMSMarker?
    
    private let service: NavigationNetworkService
    private var locationManager: CLLocationManager?
    private var timer: Timer?
    private var startTime: Date?
    private var cancelBags: Set<AnyCancellable> = .init()
    
    init(service: NavigationNetworkService = DefaultNavigationNetworkService()) {
        self.service = service
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.startUpdatingLocation()
    }
    
    func startNavigation() {
        guard destination != nil else {
            isAlertPresented = true
            return
        }
        if let currentLocation {
            // 创建起始地标记
            let marker = GMSMarker(position: currentLocation)
            marker.title = "Original location"
            marker.icon = GMSMarker.markerImage(with: .red)
            startMarker = marker
        }
        isNavigating = true
        startTime = Date()
        locationManager?.startUpdatingLocation()
        startTimer()
    }
    
    func stopNavigation() {
        isNavigating = false
        clearAllMapOverlays()
        routePath = nil
        startMarker = nil
        destinationMarker = nil
        destination = nil
        locationManager?.stopUpdatingLocation()
        stopTimer()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.startTime else { return }
            let duration = Date().timeIntervalSince(startTime)
            let hours = Int(duration) / 3600
            let minutes = Int(duration) / 60 % 60
            let seconds = Int(duration) % 60
            self.tripDuration = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func setDestination(_ location: Location) {
        destination = location
        clearAllMapOverlays()
        
        // 创建目的地标记
        let marker = GMSMarker(position: location.coordinate)
        marker.title = "Destination location"
        marker.icon = GMSMarker.markerImage(with: .red)
        destinationMarker = marker
        
        if let currentLocation = currentLocation {
            planRoute(from: currentLocation, to: location.coordinate)
        }
    }
    
    private func clearAllMapOverlays() {
        destinationMarker?.map?.clear()
    }
    
    private func planRoute(from origin: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
        isPlanningRoute = true
        service.planRoute(from: origin, to: destination)
            .sink { _ in
                self.isPlanningRoute = false
            } receiveValue: { path in
                self.routePath = path
            }
            .store(in: &cancelBags)
    }
}

extension NavigationViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.currentLocation = location.coordinate
        }
    }
} 

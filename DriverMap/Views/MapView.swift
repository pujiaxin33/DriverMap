//
//  MapView.swift
//  MapView
//
//  Created by Jiaxin Pu on 2024/11/14.
//

import SwiftUI
import GoogleMaps

struct MapView: UIViewRepresentable {
    @ObservedObject var viewModel: NavigationViewModel
    
    func makeUIView(context: Context) -> GMSMapView {
        let options = GMSMapViewOptions()
        let mapView = GMSMapView(options: options)
        
        mapView.isMyLocationEnabled = true
        mapView.delegate = context.coordinator
        context.coordinator.mapView = mapView
        
        return mapView
    }
    
    func updateUIView(_ mapView: GMSMapView, context: Context) {
        if let currentLocation = viewModel.currentLocation {
            mapView.animate(toLocation: currentLocation)
        }
        
        if let startMarker = viewModel.startMarker {
            startMarker.map = mapView
        }
        
        if let destinationMarker = viewModel.destinationMarker {
            destinationMarker.map = mapView
        }
        
        context.coordinator.polyline?.map = nil
        if let path = viewModel.routePath {
            let polyline = GMSPolyline(path: path)
            context.coordinator.polyline = polyline
            polyline.strokeWidth = 3
            polyline.strokeColor = .blue
            polyline.map = mapView
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, GMSMapViewDelegate {
        var parent: MapView
        var mapView: GMSMapView?
        var polyline: GMSPolyline?
        
        init(parent: MapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
            guard !parent.viewModel.isNavigating else { return }
            parent.viewModel.setDestination(Location(coordinate: coordinate))
        }
    }
} 

//
//  NavigationNetworkService.swift
//  DriverMap
//
//  Created by Jiaxin Pu on 2024/11/15.
//

import Foundation
import CoreLocation
import Combine
import GoogleMaps

enum NavigationNetworkError: Error {
    case inputParamsError
    case decodeDataError
}

protocol NavigationNetworkService {
    func planRoute(from origin: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) -> AnyPublisher<GMSPath, Error>
}

class DefaultNavigationNetworkService: NavigationNetworkService {
    func planRoute(from origin: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) -> AnyPublisher<GMSPath, Error> {
        let session = URLSession.shared
        let originStr = "\(origin.latitude),\(origin.longitude)"
        let destStr = "\(destination.latitude),\(destination.longitude)"
        
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(originStr)&destination=\(destStr)&mode=bicycling&key=\(AppConfigurations.shared.googleServicesAPI)"
        
        guard let url = URL(string: urlString) else { return Fail(error: NavigationNetworkError.inputParamsError).eraseToAnyPublisher() }
        
        return session.dataTaskPublisher(for: url).tryMap { (data, response) -> GMSPath in
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let routes = json["routes"] as? [[String: Any]],
                  let route = routes.first,
                  let polyline = route["overview_polyline"] as? [String: Any],
                  let points = polyline["points"] as? String,
                  let path = GMSPath(fromEncodedPath: points) else {
                throw NavigationNetworkError.decodeDataError
            }
            return path
        }.eraseToAnyPublisher()
    }
}

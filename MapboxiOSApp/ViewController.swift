//
//  ViewController.swift
//  MapboxiOSApp
//
//  Created by VINH NGUYEN on 10/9/19.
//  Copyright © 2019 example. All rights reserved.
//


import Mapbox
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections

class ViewController: UIViewController, MGLMapViewDelegate {
    var mapView: NavigationMapView!
    var directionsRoute: Route?
    var navigateButton:UIButton!
    let disneylandCoordinate = CLLocationCoordinate2D(latitude: 33.8121, longitude: -117.9190)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView = NavigationMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)
         
        // Set the map view's delegate
        mapView.delegate = self
        
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.follow, animated: true, completionHandler: nil)
         
        addButton()
    }

    func addButton(){
        navigateButton = UIButton(frame:CGRect(x: (view.frame.width/2)-100, y:view.frame.height - 75, width: 200, height: 50))
        navigateButton.backgroundColor = UIColor.white
        navigateButton.setTitle("*NAVIGATE*", for: .normal)
        navigateButton.setTitleColor(UIColor(red: 59/255, green: 178/255, blue: 208/255, alpha: 1), for: .normal)
        navigateButton.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
        navigateButton.layer.cornerRadius = 25
        navigateButton.layer.shadowOffset = CGSize(width: 0, height: 10)
        navigateButton.layer.shadowColor = #colorLiteral(red: 0.3176470697, green: 0.07450980693, blue: 0.02745098062, alpha: 1)
        navigateButton.layer.shadowRadius = 5
        navigateButton.layer.shadowOpacity = 0.3
        navigateButton.addTarget(self, action: #selector(navigateButtonWasPressed(_:)), for: .touchUpInside)
        view.addSubview(navigateButton)
        
    }
   
    @objc func navigateButtonWasPressed (_ sender: UIButton){
        mapView.setUserTrackingMode(.none, animated: true, completionHandler: nil)
        
        let annotation = MGLPointAnnotation()
        annotation.coordinate = disneylandCoordinate
        annotation.title = "Start Navigation"
        mapView.addAnnotation(annotation)
        
        calculateRoute(from: (mapView.userLocation!.coordinate), to: disneylandCoordinate){(route, error) in
            if error != nil {
                print ("Error getting route")
            }
        }
    }
    
    // Calculate route to be used for navigation
    func calculateRoute(from originCoor: CLLocationCoordinate2D,
    to destinationCoor: CLLocationCoordinate2D,
    completion: @escaping (Route?, Error?) -> Void) {
     
    // Coordinate accuracy is the maximum distance away from the waypoint that the route may still be considered viable, measured in meters. Negative values indicate that a indefinite number of meters away from the route and still be considered viable.
    let origin = Waypoint(coordinate: originCoor, coordinateAccuracy: -1, name: "Start")
    let destination = Waypoint(coordinate: destinationCoor, coordinateAccuracy: -1, name: "Finish")
     
    // Specify that the route is intended for automobiles avoiding traffic
    let options = NavigationRouteOptions(waypoints: [origin, destination], profileIdentifier: .automobileAvoidingTraffic)
     
    // Generate the route object and draw it on the map
    _ = Directions.shared.calculate(options, completionHandler:  { [unowned self] (waypoints, routes, error) in
    self.directionsRoute = routes?.first
    // Draw the route on the map after creating it
    self.drawRoute(route: self.directionsRoute!)
        
        let coordinateBounds = MGLCoordinateBounds(sw: destinationCoor, ne: originCoor)
        let insets = UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)
        let routeCam = self.mapView.cameraThatFitsCoordinateBounds(coordinateBounds, edgePadding: insets)
        self.mapView.setCamera(routeCam, animated: true)
        })
    }
    
    func drawRoute(route: Route) {
    guard route.coordinateCount > 0 else { return }
    // Convert the route’s coordinates into a polyline
    var routeCoordinates = route.coordinates!
    let polyline = MGLPolylineFeature(coordinates: &routeCoordinates, count: route.coordinateCount)
     
    // If there's already a route line on the map, reset its shape to the new route
    if let source = mapView.style?.source(withIdentifier: "route-source") as? MGLShapeSource {
    source.shape = polyline
    } else {
    let source = MGLShapeSource(identifier: "route-source", features: [polyline], options: nil)
     
    // Customize the route line color and width
    let lineStyle = MGLLineStyleLayer(identifier: "route-style", source: source)
    lineStyle.lineColor = NSExpression(forConstantValue: #colorLiteral(red: 0.1897518039, green: 0.3010634184, blue: 0.7994888425, alpha: 1))
    lineStyle.lineWidth = NSExpression(forConstantValue: 3)
     
    // Add the source and style layer of the route line to the map
    mapView.style?.addSource(source)
    mapView.style?.addLayer(lineStyle)
    }
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
    return true
    }
     
    // Present the navigation view controller when the callout is selected
    func mapView(_ mapView: MGLMapView, tapOnCalloutFor annotation: MGLAnnotation) {
    let navigationViewController = NavigationViewController(for: directionsRoute!)
    self.present(navigationViewController, animated: true, completion: nil)
    }
}


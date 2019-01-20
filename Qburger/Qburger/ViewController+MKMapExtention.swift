//
//  ViewControllerMKMapExtention.swift
//  Qburger
//
//  Created by Andrew on 20/01/2019.
//  Copyright © 2019 Andrew. All rights reserved.
//

import Foundation
import MapKit

//MARK: Annotation extention for circle, annotation details
extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard overlay is MKCircle else { return MKOverlayRenderer() }
        
        let circle = MKCircleRenderer(overlay: overlay)
        circle.strokeColor = UIColor.blue
        circle.fillColor = UIColor(red: 0, green: 0, blue: 255, alpha: 0.1)
        circle.lineWidth = 2.5
        return circle
    }
//MARK: Adding annotation details
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        
        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "") {
            annotationView.annotation = annotation
            return annotationView
        } else {
            let annotationView = MKPinAnnotationView(annotation:annotation, reuseIdentifier:"")
            annotationView.isEnabled = true
            annotationView.canShowCallout = true
            annotationView.pinTintColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
            
            let btn = UIButton(type: .detailDisclosure)
            annotationView.rightCalloutAccessoryView = btn
            return annotationView
        }
    }
}

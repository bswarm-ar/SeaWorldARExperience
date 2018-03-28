//
//  MarkerViewController.swift
//  SeaWorldAR
//
//  Created by ChristianBieniak on 27/3/18.
//  Copyright © 2018 Bswarm. All rights reserved.
//

import UIKit
import SeaworldARFramework
import MapKit

class MarkerViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var networkController: NetworkController!
    
    static let seaworldLocation = CLLocationCoordinate2D(latitude: -27.955902,longitude: 153.425217)
    
    /// When setting markers remove all annotations and
    /// display the new ones on the map
    var markers: [Marker] = [] {
        didSet {
            self.mapView.removeAnnotations(self.mapView.annotations)
            markers.forEach {
               self.mapView.addAnnotation(MarkerAnnotation(marker: $0))
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Fetch all markers
        self.networkController.allMarkers {
            self.markers = $0.value!
        }
        
        self.mapView.delegate = self
        
        //Focus map on Seaworld
        let viewRegion = MKCoordinateRegionMakeWithDistance(MarkerViewController.seaworldLocation, 1000, 1000)
        mapView.setRegion(viewRegion, animated: false)
    }
}

extension MarkerViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let markerAnnotation = view.annotation as? MarkerAnnotation {
            let vc = DisplayAnimationViewController.instance()
            vc.animationId = markerAnnotation.marker.animation?.animationFileName
            self.present(vc, animated: true, completion: nil)
        }
    }
}

/// Annotation that displays a marker
class MarkerAnnotation: NSObject, MKAnnotation  {
    
    var marker: Marker
    
    init(marker: Marker) {
        self.marker = marker
    }
    
    var coordinate: CLLocationCoordinate2D {
        return self.marker.coordinates!.coordinate
    }
    
    var title: String? {
        return self.marker.animation!.title!
    }
    
}

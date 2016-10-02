//
//  AnnotationsMapViewController.swift
//  HackerBooks 2
//
//  Created by Francisco Gómez Pino.
//  Copyright © 2016 Francisco Gómez Pino. All rights reserved.
//

import UIKit
import MapKit

class AnnotationsMapViewController: UIViewController, MKMapViewDelegate {
    
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    var models : [Annotation]
    
    //--------------------------------------
    // MARK: - IBOutlets
    //--------------------------------------
    
    @IBOutlet weak var mapView: MKMapView!
    
    //--------------------------------------
    // MARK: - Initialization
    //--------------------------------------
    
    init(models: [Annotation]){
        self.models = models
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //--------------------------------------
    // MARK: - UIViewController
    //--------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.title = "Annotations Map"
        
        self.mapView.delegate = self
        self.mapView.removeAnnotations(self.mapView.annotations)
        for annotation in self.models {
            if let localization = annotation.localization {
                let pointAnnotation = MKPointAnnotation()
                pointAnnotation.coordinate = localization.location.coordinate
                pointAnnotation.title = annotation.text
                localization.getAddress(block: { (address:String?) in
                    if let address = address {
                        pointAnnotation.subtitle = address
                    }
                })
                self.mapView.addAnnotation(pointAnnotation)
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

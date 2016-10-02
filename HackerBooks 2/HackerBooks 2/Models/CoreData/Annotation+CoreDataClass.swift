//
//  Annotation+CoreDataClass.swift
//  HackerBooks 2
//
//  Created by Francisco Gómez Pino.
//  Copyright © 2016 Francisco Gómez Pino. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

@objc(Annotation)
public class Annotation: NSManagedObject, CLLocationManagerDelegate {
    
    //--------------------------------------
    // MARK: - Entity name
    //--------------------------------------
    
    static let entityName:String = "Annotation"
    
    //--------------------------------------
    // MARK: - Variables
    //--------------------------------------
    
    var locationManager : CLLocationManager?
    
    //--------------------------------------
    // MARK: - Initialization
    //--------------------------------------
    
    convenience init(text:String, book:Book, in context: NSManagedObjectContext){
        let entity = NSEntityDescription.entity(forEntityName: Annotation.entityName, in: context)!
        self.init(entity:entity, insertInto:context)
        self.book = book
        self.text = text
        self.createdAt = NSDate()
        self.updatedAt = NSDate()
    }
    
}

//--------------------------------------
// MARK: - KVO
//--------------------------------------

extension Annotation{
    
    static func observableKeys() -> [String] {return ["text", "photo.photoData", "localization.latitude", "localization.longitude"]}
    
    func setupKVO(){
        for key in Annotation.observableKeys(){
            self.addObserver(self, forKeyPath: key, options: [], context: nil)
        }
    }
    
    func teardownKVO(){
        for key in Annotation.observableKeys(){
            self.removeObserver(self, forKeyPath: key)
        }
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        self.updatedAt = NSDate()
    }
    
}

//--------------------------------------
// MARK: - Lifecycle
//--------------------------------------

extension Annotation{
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        setupKVO()
        
        let status =  CLLocationManager.authorizationStatus()
        if ((status == .authorizedWhenInUse) || (status == .notDetermined)) && CLLocationManager.locationServicesEnabled(){
            self.locationManager = CLLocationManager()
            self.locationManager?.delegate = self
            self.locationManager?.requestWhenInUseAuthorization()
            self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager?.startUpdatingLocation()
        }
        
    }
    
    public override func awakeFromFetch() {
        super.awakeFromFetch()
        setupKVO()
    }
    
    public override func willTurnIntoFault() {
        super.willTurnIntoFault()
        teardownKVO()
    }
    
}

//--------------------------------------
// MARK: - CLLocationManagerDelegate
//--------------------------------------

extension Annotation{
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager?.stopUpdatingLocation()
        self.locationManager = nil
        if let lastLocation:CLLocation = locations.last {
            self.localization = Localization(location: lastLocation, annotation: self, in: self.managedObjectContext!)
        }
        
    }
    
}

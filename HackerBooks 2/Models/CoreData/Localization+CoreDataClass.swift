//
//  Localization+CoreDataClass.swift
//  HackerBooks 2
//
//  Created by Francisco Gómez Pino.
//  Copyright © 2016 Francisco Gómez Pino. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

@objc(Localization)
public class Localization: NSManagedObject {
    
    //--------------------------------------
    // MARK: - Entity name
    //--------------------------------------
    
    static let entityName:String = "Localization"
    
    //--------------------------------------
    // MARK: - Computed properties
    //--------------------------------------
    
    var location : CLLocation{
        get{
            return CLLocation(latitude: latitude, longitude: longitude)
        }
        set{
            latitude = newValue.coordinate.latitude
            longitude = newValue.coordinate.longitude
        }
    }
    
    //--------------------------------------
    // MARK: - Initialization
    //--------------------------------------
    
    convenience init(location:CLLocation, annotation:Annotation, in context: NSManagedObjectContext){
        let entity = NSEntityDescription.entity(forEntityName: Localization.entityName, in: context)!
        self.init(entity:entity, insertInto:context)
        self.annotations = annotation
        self.location = location
    }
    
    //--------------------------------------
    // MARK: - Additional getters
    //--------------------------------------
    
    func getAddress(block: @escaping (_ address:String?) ->()) {
        CLGeocoder().reverseGeocodeLocation(self.location) {
            (placemarks:[CLPlacemark]?, error:Error?) in
            if (error == nil) {
                if let lastPlacemark = placemarks?.last {
                    var address = ""
                    if let subThoroughfare = lastPlacemark.subThoroughfare {
                        address = "\(address) \(subThoroughfare)"
                    }
                    if let thoroughfare = lastPlacemark.thoroughfare {
                        address = "\(address) \(thoroughfare)"
                    }
                    if let postalCode = lastPlacemark.postalCode {
                        address = "\(address) \(postalCode)"
                    }
                    if let locality = lastPlacemark.locality {
                        address = "\(address) \(locality)"
                    }
                    if let administrativeArea = lastPlacemark.administrativeArea {
                        address = "\(address) \(administrativeArea)"
                    }
                    if let country = lastPlacemark.country {
                        address = "\(address) \(country)"
                    }
                    block(address)
                } else {
                    block(nil)
                }
            } else {
                block(error?.localizedDescription)
            }
        }
    }
    
}

//
//  Photo+CoreDataClass.swift
//  HackerBooks 2
//
//  Created by Francisco Gómez Pino.
//  Copyright © 2016 Francisco Gómez Pino. All rights reserved.
//

import Foundation
import CoreData
import UIKit

@objc(Photo)
public class Photo: NSManagedObject {
    
    //--------------------------------------
    // MARK: - Entity name
    //--------------------------------------
    
    static let entityName:String = "Photo"
    
    //--------------------------------------
    // MARK: - Computed properties
    //--------------------------------------
    
    var image : UIImage?{
        get{
            guard let data = photoData else{
                return nil
            }
            return UIImage(data: data as Data)!
        }
        set{
            guard let img = newValue else{
                photoData = nil
                return
            }
            photoData = UIImageJPEGRepresentation(img, 0.9) as NSData?
        }
    }
    
    //--------------------------------------
    // MARK: - Initialization
    //--------------------------------------
    
    convenience init(image:UIImage, book:Book, in context: NSManagedObjectContext){
        let entity = NSEntityDescription.entity(forEntityName: Photo.entityName, in: context)!
        self.init(entity:entity, insertInto:context)
        self.books = book
        self.image = image
    }
    
    convenience init(image:UIImage, annotation:Annotation, in context: NSManagedObjectContext){
        let entity = NSEntityDescription.entity(forEntityName: Photo.entityName, in: context)!
        self.init(entity:entity, insertInto:context)
        self.annotations = annotation
        self.image = image
    }
    
}

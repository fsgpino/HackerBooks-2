//
//  Tag+CoreDataClass.swift
//  HackerBooks 2
//
//  Created by Francisco Gómez Pino.
//  Copyright © 2016 Francisco Gómez Pino. All rights reserved.
//

import Foundation
import CoreData

@objc(Tag)
public class Tag: NSManagedObject {
    
    //--------------------------------------
    // MARK: - Entity name
    //--------------------------------------
    
    static let entityName:String = "Tag"
    
    //--------------------------------------
    // MARK: - Initialization
    //--------------------------------------
    
    convenience init(name:String, in context:NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: Tag.entityName, in: context)!
        if (Tag.getTag(byName: name, in: context) == nil) {
            self.init(entity:entity, insertInto:context)
            self.name = name
            self.books = nil
            if (name.lowercased()=="favorites"){
                self.proxyForSorting = " "
            } else {
                self.proxyForSorting = name
            }
        } else {
            self.init(entity:entity, insertInto:nil)
        }
    }
    
}

//--------------------------------------
// MARK: - Query methods
//--------------------------------------

extension Tag {
    
    // Get tag by name
    static func getTag(byName name: String, in context: NSManagedObjectContext?) -> Tag? {
        let fr = NSFetchRequest<Tag>(entityName: Tag.entityName)
        (fr.fetchLimit, fr.fetchBatchSize, fr.predicate) = (1,1,NSPredicate(format: "name == %@", name))
        do{
            if let response:Array = try context?.fetch(fr) {
                if response.count > 0 {
                    return response.first
                }
            }
            return nil
        } catch{
            return nil
        }
    }
    
}

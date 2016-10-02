//
//  Author+CoreDataClass.swift
//  HackerBooks 2
//
//  Created by Francisco Gómez Pino.
//  Copyright © 2016 Francisco Gómez Pino. All rights reserved.
//

import Foundation
import CoreData

@objc(Author)
public class Author: NSManagedObject {
    
    //--------------------------------------
    // MARK: - Entity name
    //--------------------------------------
    
    static let entityName:String = "Author"
    
    //--------------------------------------
    // MARK: - Initialization
    //--------------------------------------
    
    convenience init(name:String, in context: NSManagedObjectContext){
        let entity = NSEntityDescription.entity(forEntityName: Author.entityName, in: context)!
        self.init(entity:entity, insertInto:context)
        self.name = name
    }
    
}

//--------------------------------------
// MARK: - Query methods
//--------------------------------------

extension Author {
    
    // Get author by name
    static func getAuthor(byName name: String, in context: NSManagedObjectContext?) -> Author? {
        let fr = NSFetchRequest<Author>(entityName: Author.entityName)
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

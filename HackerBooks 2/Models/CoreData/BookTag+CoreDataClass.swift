//
//  BookTag+CoreDataClass.swift
//  HackerBooks 2
//
//  Created by Francisco Gómez Pino.
//  Copyright © 2016 Francisco Gómez Pino. All rights reserved.
//

import Foundation
import CoreData

@objc(BookTag)
public class BookTag: NSManagedObject {
    
    //--------------------------------------
    // MARK: - Entity name
    //--------------------------------------
    
    static let entityName:String = "BookTag"
    
    //--------------------------------------
    // MARK: - Initialization
    //--------------------------------------
    
    convenience init(book:Book, tag:Tag, in context: NSManagedObjectContext){
        let entity = NSEntityDescription.entity(forEntityName: BookTag.entityName, in: context)!
        self.init(entity:entity, insertInto:context)
        self.book = book
        self.tag = tag
    }
    
}

//--------------------------------------
// MARK: - Query methods
//--------------------------------------

extension BookTag {
    
    // Remove favorite tag
    static func getFavorite(FromBook book:Book, in context: NSManagedObjectContext?) -> BookTag? {
        let fr = NSFetchRequest<BookTag>(entityName: BookTag.entityName)
        (fr.fetchLimit, fr.fetchBatchSize, fr.predicate) = (1,1,NSCompoundPredicate(andPredicateWithSubpredicates: [NSPredicate(format: "tag.name == %@", "Favorites"),NSPredicate(format: "book == %@", book)]))
        do{
            if let response:Array = try context?.fetch(fr) {
                if response.count > 0 {
                    return response.first
                }
            }
            return nil
        } catch {
            return nil
        }
    }
    
    // Add favorite tag
    static func addFavorite(FromBook book:Book, in context: NSManagedObjectContext?) {
        let _ = BookTag(book: book, tag: Tag.getTag(byName: "Favorites", in: context!)!, in: context!)
    }
    
}

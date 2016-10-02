//
//  Tag+CoreDataProperties.swift
//  HackerBooks 2
//
//  Created by Francisco Gómez Pino.
//  Copyright © 2016 Francisco Gómez Pino. All rights reserved.
//

import Foundation
import CoreData

extension Tag {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tag> {
        return NSFetchRequest<Tag>(entityName: "Tag");
    }

    @NSManaged public var name: String?
    @NSManaged public var proxyForSorting: String?
    @NSManaged public var books: NSSet?

}

// MARK: Generated accessors for books
extension Tag {

    @objc(addBooksObject:)
    @NSManaged public func addToBooks(_ value: BookTag)

    @objc(removeBooksObject:)
    @NSManaged public func removeFromBooks(_ value: BookTag)

    @objc(addBooks:)
    @NSManaged public func addToBooks(_ values: NSSet)

    @objc(removeBooks:)
    @NSManaged public func removeFromBooks(_ values: NSSet)

}

//
//  Book+CoreDataProperties.swift
//  HackerBooks 2
//
//  Created by Francisco Gómez Pino.
//  Copyright © 2016 Francisco Gómez Pino. All rights reserved.
//

import Foundation
import CoreData 

extension Book {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Book> {
        return NSFetchRequest<Book>(entityName: "Book");
    }

    @NSManaged public var pdfPath: String?
    @NSManaged public var photoPath: String?
    @NSManaged public var title: String?
    @NSManaged public var lastViewing: NSDate?
    @NSManaged public var annotations: NSSet?
    @NSManaged public var authors: NSSet?
    @NSManaged public var pdf: Pdf?
    @NSManaged public var photo: Photo?
    @NSManaged public var tags: NSSet?

}

// MARK: Generated accessors for annotations
extension Book {

    @objc(addAnnotationsObject:)
    @NSManaged public func addToAnnotations(_ value: Annotation)

    @objc(removeAnnotationsObject:)
    @NSManaged public func removeFromAnnotations(_ value: Annotation)

    @objc(addAnnotations:)
    @NSManaged public func addToAnnotations(_ values: NSSet)

    @objc(removeAnnotations:)
    @NSManaged public func removeFromAnnotations(_ values: NSSet)

}

// MARK: Generated accessors for authors
extension Book {

    @objc(addAuthorsObject:)
    @NSManaged public func addToAuthors(_ value: Author)

    @objc(removeAuthorsObject:)
    @NSManaged public func removeFromAuthors(_ value: Author)

    @objc(addAuthors:)
    @NSManaged public func addToAuthors(_ values: NSSet)

    @objc(removeAuthors:)
    @NSManaged public func removeFromAuthors(_ values: NSSet)

}

// MARK: Generated accessors for tags
extension Book {

    @objc(addTagsObject:)
    @NSManaged public func addToTags(_ value: BookTag)

    @objc(removeTagsObject:)
    @NSManaged public func removeFromTags(_ value: BookTag)

    @objc(addTags:)
    @NSManaged public func addToTags(_ values: NSSet)

    @objc(removeTags:)
    @NSManaged public func removeFromTags(_ values: NSSet)

}

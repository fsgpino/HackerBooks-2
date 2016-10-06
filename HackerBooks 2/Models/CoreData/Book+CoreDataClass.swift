//
//  Book+CoreDataClass.swift
//  HackerBooks 2
//
//  Created by Francisco Gómez Pino.
//  Copyright © 2016 Francisco Gómez Pino. All rights reserved.
//

import Foundation
import CoreData
import UIKit

@objc(Book)
public class Book: NSManagedObject {
    
    //--------------------------------------
    // MARK: - Entity name
    //--------------------------------------
    
    static let entityName:String = "Book"
    
    //--------------------------------------
    // MARK: - Computed properties
    //--------------------------------------
    
    var pdfURL : URL?{
        get{
            guard let url = pdfPath else{
                return nil
            }
            return URL(string: url)
        }
    }
    
    var photoURL : URL?{
        get{
            guard let url = photoPath else{
                return nil
            }
            return URL(string: url)
        }
    }
    
    var authorsString : String?{
        get{
            if let authors:[Author] = self.authors?.allObjects as? [Author] {
                var authorsString = ""
                for (index,each) in authors.map({$0.name!}).enumerated() {
                    authorsString += "\(each)"
                    if index != (authors.count-1) {
                        if index == (authors.count-2) {
                            authorsString += " and "
                        } else {
                            authorsString += ", "
                        }
                    }
                }
                if authorsString == "" {
                    return nil
                } else {
                    return authorsString
                }
            }
            return nil
        }
    }
    
    var tagsString : String?{
        get{
            if let tags = self.tags?.allObjects as? [BookTag] {
                var tagsString = ""
                for (index,each) in tags.map({$0.tag!}).map({$0.name!}).sorted().enumerated() {
                    tagsString += "\(each)"
                    if index != (tags.count-1) {
                        if index == (tags.count-2) {
                            tagsString += " and "
                        } else {
                            tagsString += ", "
                        }
                    }
                }
                if tagsString == "" {
                    return nil
                } else {
                    return tagsString
                }
            }
            return nil
        }
    }
    
    var isFavorite : Bool{
        get{
            if let _ = BookTag.getFavorite(FromBook: self, in: self.managedObjectContext!) {
                return true
            }
            return false
        }
        set{
            if let actualFavoriteTag = BookTag.getFavorite(FromBook: self, in: self.managedObjectContext!) {
                if !newValue {
                    self.managedObjectContext?.delete(actualFavoriteTag)
                }
            }
            if newValue {
                BookTag.addFavorite(FromBook: self, in: self.managedObjectContext!)
            }
        }
    }
    
    //--------------------------------------
    // MARK: - Initialization
    //--------------------------------------
    
    convenience init(title:String, pdfPath:String, photoPath:String, in context:NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: Book.entityName, in: context)!
        self.init(entity:entity, insertInto:context)
        self.title = title
        self.pdfPath = pdfPath
        self.photoPath = photoPath
    }
    
    //--------------------------------------
    // MARK: - Additional getters
    //--------------------------------------
    
    func getPhoto(block: @escaping (_ photo:UIImage?) ->()) {
        if self.photo == nil {
            getResourceInBackground(fromURL: self.photoURL!, withBlock: {
                (photoData:Data?) in
                if  let photoData:Data = photoData,
                    let photo:UIImage = UIImage(data: photoData) {
                    let _ = Photo(image: photo, book: self, in: self.managedObjectContext!)
                    block(photo)
                }
            })
        } else {
            block(self.photo?.image)
        }
    }
    
    func getPDF(block: @escaping (_ pdf:Data?) ->()) {
        if self.pdf == nil {
            getResourceInBackground(fromURL: self.pdfURL!, withBlock: {
                (pdfData:Data?) in
                if  let pdfData:Data = pdfData {
                    let _ = Pdf(pdfData: pdfData, book: self, in: self.managedObjectContext!)
                    block(pdfData)
                }
            })
        } else {
            block(self.pdf?.pdfData as Data?)
        }
    }
    
}

//--------------------------------------
// MARK: - Query methods
//--------------------------------------

extension Book {
    
    // Get book last view
    static func getLastViewed(in context: NSManagedObjectContext?) -> Book? {
        let fr = NSFetchRequest<Book>(entityName: Book.entityName)
        (fr.fetchLimit, fr.fetchBatchSize, fr.sortDescriptors) = (1,1,[NSSortDescriptor(key: "lastViewing", ascending: false)])
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

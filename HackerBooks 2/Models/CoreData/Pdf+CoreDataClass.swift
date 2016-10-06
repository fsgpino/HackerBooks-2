//
//  Pdf+CoreDataClass.swift
//  HackerBooks 2
//
//  Created by Francisco Gómez Pino.
//  Copyright © 2016 Francisco Gómez Pino. All rights reserved.
//

import Foundation
import CoreData

@objc(Pdf)
public class Pdf: NSManagedObject {
    
    //--------------------------------------
    // MARK: - Entity name
    //--------------------------------------
    
    static let entityName:String = "Pdf"
    
    //--------------------------------------
    // MARK: - Initialization
    //--------------------------------------
    
    convenience init(pdfData:Data, book:Book, in context: NSManagedObjectContext){
        let entity = NSEntityDescription.entity(forEntityName: Pdf.entityName, in: context)!
        self.init(entity:entity, insertInto:context)
        self.book = book
        self.pdfData = pdfData as NSData?
    }
    
}


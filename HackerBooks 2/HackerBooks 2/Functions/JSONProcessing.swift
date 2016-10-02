//
//  Errors.swift
//  HackerBooks
//
//  Created by Francisco Gómez Pino.
//  Copyright © 2016 Francisco Gómez Pino. All rights reserved.
//

import Foundation
import CoreData

//--------------------------------------
// MARK: - Aliases
//--------------------------------------

typealias JSONObject        =   AnyObject
typealias JSONDictionary    =   [String : JSONObject]
typealias JSONArray         =   [JSONDictionary]

//--------------------------------------
// MARK: - JSON Errors
//--------------------------------------

enum JSONError : Error{
    case wrongURLFormatForJSONResource
    case resourcePointedByURLNotReachable
    case jsonParsingError
    case wrongJSONFormat
    case nilJSONObject
}

//--------------------------------------
// MARK: - Decodification
//--------------------------------------

func decode(book json: JSONDictionary, in context:NSManagedObjectContext) throws  -> Book {
    
    guard let title = json["title"] as? String else {
        throw JSONError.jsonParsingError
    }
    
    guard let authors = json["authors"] as? String,
        let authorsArray = stringToArray(string: authors) else {
            throw JSONError.jsonParsingError
    }
    
    guard let tags = json["tags"] as? String,
        let tagsArray = stringToArray(string: tags) else {
            throw JSONError.jsonParsingError
    }
    
    guard let imageURL = json["image_url"] as? String,
        let _ = URL(string: imageURL) else {
            throw JSONError.wrongURLFormatForJSONResource
    }
    
    guard let pdfURL = json["pdf_url"] as? String,
        let _ = URL(string: pdfURL) else{
            throw JSONError.wrongURLFormatForJSONResource
    }
    
    let book:Book = Book(title: title, pdfPath: pdfURL, photoPath: imageURL, in: context)
    
    for authorName in authorsArray{
        if let existingAuthor:Author = Author.getAuthor(byName: authorName, in: context) {
            book.addToAuthors(existingAuthor)
        } else {
            book.addToAuthors(Author(name: authorName, in: context))
        }
    }
    
    for tagName in tagsArray{
        if let existingTag:Tag = Tag.getTag(byName: tagName, in: context) {
            let _ = BookTag(book: book, tag: existingTag, in: context)
        } else {
            let _ = BookTag(book: book, tag: Tag(name: tagName, in: context), in: context)
        }
    }

    return book
    
}

func decode(book json: JSONDictionary?, in context:NSManagedObjectContext) throws -> Book{
    if case .some(let jsonDict) = json{
        return try decode(book: jsonDict, in:context)
    }else{
        throw JSONError.nilJSONObject
    }
}

//--------------------------------------
// MARK: - Loading
//--------------------------------------

func load(fromData data: Data) throws -> JSONArray {
    if let maybeArray = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? JSONArray, let array = maybeArray {
        return array
    }else{
        throw JSONError.jsonParsingError
    }
}

//--------------------------------------
// MARK: - Utils
//--------------------------------------

func stringToArray(string: String) -> [String]? {
    var array:[String] = []
    for each in string.components(separatedBy: ",") {
        array.append(each.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines))
    }
    return array
}

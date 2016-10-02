//
//  Resources.swift
//  HackerBooks
//
//  Created by Francisco Gómez Pino.
//  Copyright © 2016 Francisco Gómez Pino. All rights reserved.
//

import Foundation

//--------------------------------------
// MARK: - Get resource from URL
//--------------------------------------

func getResource(fromURL url:URL) -> Data? {
    do {
        return try Data(contentsOf: url)
    } catch {
        return nil
    }
}

func getResourceInBackground(fromURL url:URL, withBlock block: @escaping (_ resource:Data?) ->()) {
    
    let main = DispatchQueue.main
    let back = DispatchQueue.global(qos: .utility)
    
    back.async {
        
        let resource:Data? = getResource(fromURL: url)
        
        main.async {
            
            block(resource)
            
        }
        
    }
    
}

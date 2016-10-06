//
//  LibraryTableViewCell.swift
//  HackerBooks
//
//  Created by Francisco Gómez Pino.
//  Copyright © 2016 Francisco Gómez Pino. All rights reserved.
//

import UIKit

class LibraryTableViewCell: UITableViewCell {
    
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    var model:Book?
    
    //--------------------------------------
    // MARK: - IBOutlets
    //--------------------------------------

    @IBOutlet weak var bookImageView: UIImageView!
    @IBOutlet weak var bookTitleLabel: UILabel!
    @IBOutlet weak var bookAuthorsLabel: UILabel!
    @IBOutlet weak var bookImageActivityIndicator: UIActivityIndicatorView!
    
    //--------------------------------------
    // MARK: - Syncing
    //--------------------------------------
    
    func syncModelWithView() {
        
        self.bookImageView.image = UIImage(named: "NoImage")
        
        if let book:Book = self.model {
            
            if let title:String = book.title {
                self.bookTitleLabel?.text = title
            } else {
                self.bookTitleLabel?.text = "Book Untitled"
            }
            
            if let authorsString:String = book.authorsString {
                self.bookAuthorsLabel?.text = authorsString
            } else {
                self.bookAuthorsLabel?.text = "Authorless"
            }
            
            self.bookImageActivityIndicator.startAnimating()
            
            book.getPhoto(block: { (image:UIImage?) in
                self.bookImageActivityIndicator.stopAnimating()
                if let image:UIImage = image {
                    self.bookImageView.image = image
                }
            })
            
        }
        
    }
    
}

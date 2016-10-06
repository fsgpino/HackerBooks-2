//
//  AnnotationCollectionViewCell.swift
//  HackerBooks 2
//
//  Created by Francisco Gómez Pino.
//  Copyright © 2016 Francisco Gómez Pino. All rights reserved.
//

import UIKit

class AnnotationCollectionViewCell: UICollectionViewCell {
    
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    var model:Annotation?
    
    //--------------------------------------
    // MARK: - IBOutlets
    //--------------------------------------
    
    @IBOutlet weak var noteText: UILabel!
    @IBOutlet weak var image: UIImageView!
    
    //--------------------------------------
    // MARK: - UICollectionViewCell
    //--------------------------------------
    
    override func awakeFromNib() {
        self.backgroundColor = UIColor(white: 1.0, alpha: 0.9)
        self.layer.cornerRadius = 5
        self.image.layer.cornerRadius = 2
    }
    
    //--------------------------------------
    // MARK: - Syncing
    //--------------------------------------
    
    func syncModelWithView() {
        
        self.image.image = UIImage(named: "NoImageAnnotation")
        
        if let annotation:Annotation = self.model {
            
            if let text:String = annotation.text {
                if text.isEmpty {
                    self.noteText?.text = "No text"
                    self.noteText.textColor = UIColor.lightGray
                } else {
                self.noteText?.text = text
                self.noteText.textColor = UIColor.black
                }
            } else {
                self.noteText?.text = "No text"
                self.noteText.textColor = UIColor.lightGray
            }
            
            if annotation.photo != nil {
                self.image.image = UIImage(data: annotation.photo?.photoData as! Data)!
            }
            
        }
        
    }
    
}

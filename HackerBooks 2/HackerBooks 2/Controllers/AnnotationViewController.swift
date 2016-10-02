//
//  AnnotationViewController.swift
//  HackerBooks 2
//
//  Created by Francisco Gómez Pino.
//  Copyright © 2016 Francisco Gómez Pino. All rights reserved.
//

import CoreData
import UIKit

class AnnotationViewController: UIViewController, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    var model : Annotation
    
    //--------------------------------------
    // MARK: - IBOutlets
    //--------------------------------------
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var photo: UIImageView!
    
    //--------------------------------------
    // MARK: - Initialization
    //--------------------------------------
    
    init(model: Annotation){
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //--------------------------------------
    // MARK: - UIViewController
    //--------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.title = "Annotation"
        
        self.edgesForExtendedLayout = .bottom
        self.textView.delegate = self
        
        if (model.text?.isEmpty)! {
            self.textView.text = "Enter your note here"
            self.textView.textColor = UIColor.lightGray
        } else {
            self.textView.text = model.text
        }
        
        if let photo = model.photo {
            self.photo.image = photo.image
        } else {
            self.photo.image = UIImage(named: "NoImageAnnotation")
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(AnnotationViewController.deleteAnnotation))
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //--------------------------------------
    // MARK: - UITextViewDelegate
    //--------------------------------------
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let currentText:NSString = textView.text as NSString
        let updatedText = currentText.replacingCharacters(in: range, with:text)
        if updatedText.isEmpty {
            textView.text = "Enter your note here"
            textView.textColor = UIColor.lightGray
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            
            return false
            
        } else if textView.textColor == UIColor.lightGray && !text.isEmpty {
            textView.text = nil
            textView.textColor = UIColor.black
        }
        
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        return true
        
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            self.textView.text = "Enter your note here"
            self.textView.textColor = UIColor.lightGray
            self.model.text = ""
        } else {
            self.model.text = textView.text
        }
    }
    
    //--------------------------------------
    // MARK: - IBActions
    //--------------------------------------
    
    @IBAction func share(_ sender: AnyObject) {
        var sharingItems = [AnyObject]()
        
        if let text = self.model.text {
            sharingItems.append(text as AnyObject)
        }
        if let image = self.model.photo?.image {
            sharingItems.append(image)
        }
        if let url = self.model.book?.pdfURL {
            sharingItems.append(url as AnyObject)
        }
        
        let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
        
        self.present(activityViewController, animated: true, completion: nil)
        
    }
    
    @IBAction func uploadPhoto(_ sender: AnyObject) {
        if let _ = self.model.photo {
            self.showUploadImageOptionMenu(menu: 0)
        } else {
            self.showUploadImageOptionMenu(menu: 1)
        }
    }
    
    //--------------------------------------
    // MARK: - Actions
    //--------------------------------------
    
    func deleteAnnotation() {
        
        // Make actionSheet
        let actionSheet:UIAlertController = UIAlertController(title: "Are you sure you want remove this note?", message: nil, preferredStyle: (UIDevice.current.userInterfaceIdiom == .phone ? .actionSheet : .alert))
        
        // Remove option
        actionSheet.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: {
            (action:UIAlertAction) in
            
            // Remove actionSheet
            actionSheet.dismiss(animated: true, completion: nil)
            
            // Remove annotation
            self.model.managedObjectContext?.delete(self.model)
            
            // Remove view
            _ = self.navigationController?.popViewController(animated: true)
            
        }))
        
        // Cancel option
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (action:UIAlertAction) in
            
            // Remove actionSheet
            actionSheet.dismiss(animated: true, completion: nil)
            
        }))
        
        // Show actionSheet in view
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    //--------------------------------------
    // MARK: - UIImagePickerControllerDelegate
    //--------------------------------------
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // Dismiss picker view
        self.dismiss(animated: true, completion: nil)
        
        // Setting new image
        self.photo.image = image
        if let photo = self.model.photo {
            photo.image = image
        } else {
            self.model.photo = Photo(image: image, annotation: self.model, in: self.model.managedObjectContext!)
        }
    }
    
    //--------------------------------------
    // MARK: - Functions
    //--------------------------------------
    
    private func showUploadImageOptionMenu(menu: Int){
        
        if (menu == 1) {
            
            // Make a picker
            let picker = UIImagePickerController()
            
            // Setting preference of editing and delegate
            picker.allowsEditing = true
            picker.delegate = self
            
            // Make actionSheet
            let actionSheet:UIAlertController = UIAlertController(title: "Select source for image", message: nil, preferredStyle: (UIDevice.current.userInterfaceIdiom == .phone ? .actionSheet : .alert))
            
            // Camera option
             if UIImagePickerController.isCameraDeviceAvailable(.rear){
                actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: {
                    (action:UIAlertAction) in
                    
                    // Remove actionSheet
                    actionSheet.dismiss(animated: true, completion: nil)
                    
                    // Setting source image
                    picker.sourceType = UIImagePickerControllerSourceType.camera
                    
                    // Show picker
                    self.present(picker, animated: true, completion: nil)
                    
                }))
            }
            
            // Photo library option
            actionSheet.addAction(UIAlertAction(title: "Photo library", style: .default, handler: {
                (action:UIAlertAction) in
                
                // Remove actionSheet
                actionSheet.dismiss(animated: true, completion: nil)
                
                // Setting source image
                picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
                
                // Show picker
                self.present(picker, animated: true, completion: nil)
                
            }))
            
            // Cancel option
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
                (action:UIAlertAction) in
                
                // Remove actionSheet
                actionSheet.dismiss(animated: true, completion: nil)
                
            }))
            
            // Show actionSheet in view
            self.present(actionSheet, animated: true, completion: nil)
            
        } else { // Else: (menu == 1)
            
            // Make actionSheet
            let actionSheet:UIAlertController = UIAlertController(title: "You want to do with the current image?", message: nil, preferredStyle: (UIDevice.current.userInterfaceIdiom == .phone ? .actionSheet : .alert))
            
            // Remove option
            actionSheet.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: {
                (action:UIAlertAction) in
                
                // Remove actionSheet
                actionSheet.dismiss(animated: true, completion: nil)
                
                // Remove image
                self.model.managedObjectContext?.delete(self.model.photo!)
                self.photo.image = UIImage(named: "NoImageAnnotation")
                
            }))
            
            // Replace option
            actionSheet.addAction(UIAlertAction(title: "Replace", style: .default, handler: {
                (action:UIAlertAction) in
                
                // Remove actionSheet
                actionSheet.dismiss(animated: true, completion: nil)
                
                // Show a menu option for new image
                self.showUploadImageOptionMenu(menu: 1)
                
            }))
            
            // Cancel option
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
                (action:UIAlertAction) in
                
                // Remove actionSheet
                actionSheet.dismiss(animated: true, completion: nil)
                
            }))
            
            // Show actionSheet in view
            self.present(actionSheet, animated: true, completion: nil)
            
        } // End: (menu == 1)
        
    }
    
}

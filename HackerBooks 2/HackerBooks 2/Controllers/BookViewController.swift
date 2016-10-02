//
//  BookViewController.swift
//  HackerBooks
//
//  Created by Francisco Gómez Pino.
//  Copyright © 2016 Francisco Gómez Pino. All rights reserved.
//

import CoreData
import UIKit

let BookIsFavoriteDidChangeNotification = "Book isFavorite property did change"

class BookViewController: UIViewController {
    
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    var model : Book?
    
    //--------------------------------------
    // MARK: - IBOutlets
    //--------------------------------------
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var authorsLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var readBookButton: UIButton!
    
    //--------------------------------------
    // MARK: - Initialization
    //--------------------------------------
    
    init(model: Book?){
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = "Book Info"
        
        self.imageView.image = UIImage(named: "NoImage")
        self.imageActivityIndicator.stopAnimating()
        
        self.edgesForExtendedLayout = .bottom
        self.backgroundImageView.clipsToBounds = true
        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.light))
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleRightMargin, .flexibleLeftMargin, .flexibleBottomMargin, .flexibleTopMargin] // for supporting device rotation
        self.backgroundImageView.addSubview(blurEffectView)
     
        self.favoriteButton.layer.cornerRadius = 5
        self.readBookButton.layer.cornerRadius = 5
        
        self.syncModelWithView()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //--------------------------------------
    // MARK: - IBActions
    //--------------------------------------
    
    @IBAction func displayBook(_ sender: AnyObject) {
        
        if let model = model {
            
            let simplePDFviewController = SimplePDFViewController(model: model)
            
            self.navigationController?.pushViewController(simplePDFviewController, animated: true)
            
        }
        
    }

    @IBAction func changeFavoriteStatus(_ sender: AnyObject) {
        
        if let model = model {
            
            model.isFavorite = !model.isFavorite
            syncModelWithFavoriteButton()
            
        }
    }
    
    //--------------------------------------
    // MARK: - Syncing
    //--------------------------------------
    
    func syncModelWithView(){
        
        self.imageView.image = UIImage(named: "NoImage")
        
        if self.model != nil {
            
            self.model?.lastViewing = NSDate()
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Annotations", style: .plain, target: self, action: #selector(BookViewController.showAnnotations))
            
            self.favoriteButton.isHidden = false
            self.readBookButton.isHidden = false
        
            if let title:String = self.model?.title {
                self.titleLabel.text = title
            } else {
                self.titleLabel.text = "Book Untitled"
            }
            
            if let authorsString:String = self.model?.authorsString {
                self.authorsLabel.text = "Written by \(authorsString)"
            } else {
                self.authorsLabel.text = "Authorless"
            }
            
            if let tagsString:String = self.model?.tagsString {
                self.tagsLabel.text = "Tagged as: \(tagsString)"
            } else {
                self.tagsLabel.text = "No tagged"
            }
            
            self.imageActivityIndicator.startAnimating()
        
            model?.getPhoto(block: { (image:UIImage?) in
                
                self.imageActivityIndicator.stopAnimating()
                
                if let image:UIImage = image {
                    self.imageView.image = image
                }
                
            })
            
            self.syncModelWithFavoriteButton()
            
        } else {
            
            self.navigationItem.rightBarButtonItem = nil
            self.titleLabel.text = "Select a book"
            self.authorsLabel.text = ""
            self.tagsLabel.text = ""
            self.favoriteButton.isHidden = true
            self.readBookButton.isHidden = true
            
        }
        
    }
    
    func syncModelWithFavoriteButton() {
        
        if (model?.isFavorite)! {
            self.favoriteButton.backgroundColor = UIColor(red:0.81, green:0.00, blue:0.00, alpha:1.0)
            self.favoriteButton.setTitle(" Remove from your favorites ", for: .normal)
        } else {
            self.favoriteButton.backgroundColor = UIColor(red:0.07, green:0.81, blue:0.00, alpha:1.0)
            self.favoriteButton.setTitle(" Add to your favorites ", for: .normal)
        }
        
    }
    
    //--------------------------------------
    // MARK: - Selectors
    //--------------------------------------
    
    func showAnnotations(){
        
        // Query
        let request : NSFetchRequest<Annotation> = Annotation.fetchRequest()
        (request.sortDescriptors,request.predicate)  = ([NSSortDescriptor(key:"updatedAt",ascending:false)],NSPredicate(format: "book == %@", self.model!))
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: (self.model?.managedObjectContext!)!, sectionNameKeyPath: nil, cacheName: nil)
        
         // Controllers
        let annotationsCollectionVC = AnnotationsCollectionViewController(model: self.model!, fetchedResultsController: fetchedResultsController as! NSFetchedResultsController<NSFetchRequestResult>, layout: UICollectionViewFlowLayout())
        let annotationsNav = UINavigationController(rootViewController: annotationsCollectionVC)
        annotationsNav.modalPresentationStyle = .fullScreen;
        
        // Show controller
        self.present(annotationsNav, animated: true, completion: nil)
        
    }
    
}

//--------------------------------------
// MARK: - Extensions
//--------------------------------------

extension BookViewController: LibraryTableViewControllerDelegate{
    
    func libraryTableViewController(vc: LibraryTableViewController, didSelectBook book: Book) {
        
        self.model = book
        
        self.syncModelWithView()
        
    }
    
}

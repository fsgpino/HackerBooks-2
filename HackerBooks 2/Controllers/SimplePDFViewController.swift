//
//  SimplePDFViewController.swift
//  HackerBooks
//
//  Created by Francisco Gómez Pino.
//  Copyright © 2016 Francisco Gómez Pino. All rights reserved.
//

import CoreData
import UIKit

class SimplePDFViewController: UIViewController, UIWebViewDelegate {
    
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    var model : Book
    
    //--------------------------------------
    // MARK: - IBOutlets
    //--------------------------------------
    
    @IBOutlet weak var browser: UIWebView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    //--------------------------------------
    // MARK: - Initialization
    //--------------------------------------
    
    init(model: Book){
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
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Annotations", style: .plain, target: self, action: #selector(SimplePDFViewController.showAnnotations))
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SimplePDFViewController.bookDidChange), name: NSNotification.Name(rawValue: BookDidChangeNotification), object: nil)
        syncModelWithView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //--------------------------------------
    // MARK: - UIWebViewDelegate
    //--------------------------------------
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        activityView.stopAnimating()
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        if navigationType == .linkClicked || navigationType == .formSubmitted {
            return false
        } else {
            return true
        }
        
    }
    
    //--------------------------------------
    // MARK: - Syncing
    //--------------------------------------
    
    func syncModelWithView(){
        
        browser.delegate = self
        
        if let title:String = self.model.title {
            self.navigationItem.title = title
        } else {
            self.navigationItem.title = "Book Untitled"
        }
        
        activityView.startAnimating()
        
        self.model.getPDF { (pdf:Data?) in
            if let resource:Data = pdf {
                self.browser.load(resource, mimeType: "application/pdf", textEncodingName: "UTF-8", baseURL: self.model.pdfURL!)
            } else {
                self.activityView.stopAnimating()
                self.displayAlert(title: "Downloading Error", message: "A problem occurred downloading PDF document.")
            }
            
        }
        
    }
    
    //--------------------------------------
    // MARK: - Selectors
    //--------------------------------------
    
    func showAnnotations(){
        
        // Query
        let request : NSFetchRequest<Annotation> = Annotation.fetchRequest()
        (request.sortDescriptors,request.predicate)  = ([NSSortDescriptor(key:"updatedAt",ascending:false)],NSPredicate(format: "book == %@", self.model))
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: (self.model.managedObjectContext!), sectionNameKeyPath: nil, cacheName: nil)
        
        // Controllers
        let annotationsCollectionVC = AnnotationsCollectionViewController(model: self.model, fetchedResultsController: fetchedResultsController as! NSFetchedResultsController<NSFetchRequestResult>, layout: UICollectionViewFlowLayout())
        let annotationsNav = UINavigationController(rootViewController: annotationsCollectionVC)
        annotationsNav.modalPresentationStyle = .fullScreen;
        
        // Show controller
        self.present(annotationsNav, animated: true, completion: nil)
        
    }
    
    //--------------------------------------
    // MARK: - Syncing
    //--------------------------------------
    
    func bookDidChange(notification: NSNotification)  {
        
        model = notification.userInfo![BookKey] as! Book
        syncModelWithView()
        
    }
    
    //--------------------------------------
    // MARK: - Utils
    //--------------------------------------
    
    func displayAlert(title:String, message:String){
        
        // Show alert with UIAlertController
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            (action) -> Void in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
}

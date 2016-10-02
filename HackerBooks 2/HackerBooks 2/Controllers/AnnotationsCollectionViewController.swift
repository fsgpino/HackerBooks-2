//
//  AnnotationsCollectionViewController.swift
//  HackerBooks 2
//
//  Created by Francisco Gómez Pino.
//  Copyright © 2016 Francisco Gómez Pino. All rights reserved.
//

import UIKit
import CoreData

let cellAnnotationId = "AnnotationCell"

class AnnotationsCollectionViewController: CoreDataCollectionViewController {
    
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    var model : Book
    
    //--------------------------------------
    // MARK: - Initialization
    //--------------------------------------
    
    init(model: Book, fetchedResultsController fc: NSFetchedResultsController<NSFetchRequestResult>, layout: UICollectionViewLayout){
        self.model = model
        super.init(fetchedResultsController: fc, layout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //--------------------------------------
    // MARK: - UIViewController
    //--------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Annotations"
        
        let addAnnotation =  UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(AnnotationsCollectionViewController.addAnnotation))
        let showMap = UIBarButtonItem(image: UIImage(named:"881-globe"), style: .plain, target: self, action: #selector(AnnotationsCollectionViewController.showAnnotationsMap))
        
        self.navigationItem.rightBarButtonItems = [addAnnotation, showMap]
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(AnnotationsCollectionViewController.closeAnnotations))
        
        let nib = UINib(nibName: "AnnotationCollectionViewCell", bundle: Bundle.main)
        self.collectionView?.register(nib, forCellWithReuseIdentifier: cellAnnotationId)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        collectionView?.backgroundColor = UIColor(red:0.87, green:0.87, blue:0.87, alpha:1.0)
    }
    
    //--------------------------------------
    // MARK: - UICollectionViewDelegate
    //--------------------------------------
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let annotation = fetchedResultsController?.object(at: indexPath) as! Annotation
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellAnnotationId, for: indexPath) as? AnnotationCollectionViewCell
        if cell == nil{
            cell = AnnotationCollectionViewCell()
        }
        cell?.model = annotation
        cell?.syncModelWithView()
        return cell!
    }
    
    @objc(collectionView:layout:sizeForItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let annotation = self.fetchedResultsController?.object(at: indexPath) as! Annotation
        self.navigationController?.pushViewController(AnnotationViewController(model:annotation), animated: true)
    }
    
    //--------------------------------------
    // MARK: - Actions
    //--------------------------------------
    
    func addAnnotation(){
        let newAnnotation = Annotation(text: "", book: self.model, in: self.model.managedObjectContext!)
        self.navigationController?.pushViewController(AnnotationViewController(model:newAnnotation), animated: true)
    }
    
    func closeAnnotations(){
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func showAnnotationsMap(){
        self.navigationController?.pushViewController(AnnotationsMapViewController(models: fetchedResultsController?.fetchedObjects as! [Annotation]), animated: true)
    }
    
}

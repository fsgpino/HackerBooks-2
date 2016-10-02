//
//  LibraryTableViewController.swift
//  HackerBooks 2
//
//  Created by Francisco Gómez Pino.
//  Copyright © 2016 Francisco Gómez Pino. All rights reserved.
//

import UIKit
import CoreData

let BookDidChangeNotification = "Selected book did change"
let BookKey = "BookKey"
let cellId = "BookCell"

class LibraryTableViewController: CoreDataTableViewController, UISearchBarDelegate, UISearchResultsUpdating {
    
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    let searchController : UISearchController = UISearchController(searchResultsController: nil)
    var delegate : LibraryTableViewControllerDelegate?
    
    //--------------------------------------
    // MARK: - UIViewController
    //--------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Hackerbooks 2"

        self.searchController.searchBar.delegate = self
        self.searchController.searchResultsUpdater = self
        self.tableView.tableHeaderView = self.searchController.searchBar
        
        let nib = UINib(nibName: "LibraryTableViewCell", bundle: Bundle.main)
        self.tableView.register(nib, forCellReuseIdentifier: cellId)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(LibraryTableViewController.reloadData), name: NSNotification.Name(rawValue: BookIsFavoriteDidChangeNotification), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    //--------------------------------------
    // MARK: - UITableViewDelegate
    //--------------------------------------
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchedResultsController?.sections?[section].name.capitalized
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> LibraryTableViewCell {
        
        let bookTag = fetchedResultsController?.object(at: indexPath) as! BookTag
        let book = bookTag.book
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? LibraryTableViewCell
        
        if cell == nil{
            cell = LibraryTableViewCell()
        }
        
        cell?.model = book
        
        cell?.syncModelWithView()
        
        return cell!
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let bookTag = self.fetchedResultsController?.object(at: indexPath) as! BookTag
        
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            
            delegate?.libraryTableViewController(vc: self, didSelectBook: bookTag.book!)
            
            let nc = NotificationCenter.default
            let notif = NSNotification(name: NSNotification.Name(rawValue: BookDidChangeNotification), object: self, userInfo: [BookKey:bookTag.book!])
            nc.post(notif as Notification)
            
        } else {
            
            navigationController?.pushViewController(BookViewController(model: bookTag.book!), animated: true)
            
        }
        
    }
    
    //--------------------------------------
    // MARK: - Syncing
    //--------------------------------------
    
    func reloadData(notification: NSNotification)  {
        self.tableView.reloadData()
    }
    
    //--------------------------------------
    // MARK: - UISearchBarDelegate
    //--------------------------------------
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<BookTag> = BookTag.fetchRequest()
        request.sortDescriptors = self.fetchedResultsController?.fetchRequest.sortDescriptors
        let _fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: (self.fetchedResultsController?.managedObjectContext)!, sectionNameKeyPath: "tag.name", cacheName: nil)
        self.fetchedResultsController = _fetchedResultsController as? NSFetchedResultsController<NSFetchRequestResult>
    }
    
    func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
        self.searchController.searchBar.text = searchBar.text
    }
    
    //--------------------------------------
    // MARK: - UISearchResultsUpdating
    //--------------------------------------
    
    public func updateSearchResults(for searchController: UISearchController){
        if let searchText = searchController.searchBar.text {
            if !searchText.isEmpty {
                let request : NSFetchRequest<BookTag> = BookTag.fetchRequest()
                let titlePredicate = NSPredicate(format: "book.title contains[cd] %@", searchText)
                let authorPredicate = NSPredicate(format: "ANY book.authors.name contains[cd] %@", searchText)
                let tagPredicate = NSPredicate(format: "tag.name contains[cd] %@", searchText)
                request.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [titlePredicate,authorPredicate,tagPredicate])
                request.sortDescriptors = self.fetchedResultsController?.fetchRequest.sortDescriptors
                let _fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: (self.fetchedResultsController?.managedObjectContext)!, sectionNameKeyPath: "tag.name", cacheName: nil)
                self.fetchedResultsController = _fetchedResultsController as? NSFetchedResultsController<NSFetchRequestResult>
            }
        }
    }
    
}

//--------------------------------------
// MARK: - Protocols
//--------------------------------------

protocol LibraryTableViewControllerDelegate {
    
    func libraryTableViewController(vc : LibraryTableViewController, didSelectBook book: Book)
    
}

//--------------------------------------
// MARK: - Extensions
//--------------------------------------

extension LibraryTableViewController: UISplitViewControllerDelegate {
    
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
        return true
    }
    
}

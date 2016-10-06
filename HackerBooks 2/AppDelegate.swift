//
//  AppDelegate.swift
//  HackerBooks 2
//
//  Created by Francisco Gómez Pino.
//  Copyright © 2016 Francisco Gómez Pino. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let model = CoreDataStack(modelName: "Model")!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
		
		// Drop all data (Uncomment for Debug)
		//try! model.dropAllData()
        
        let request : NSFetchRequest<BookTag> = BookTag.fetchRequest()
        (request.includesPropertyValues, request.sortDescriptors) = (false,[NSSortDescriptor(key: "tag.proxyForSorting", ascending: true),NSSortDescriptor(key: "book.title", ascending: true)])
        
        do{
			
			// Get number books
            let bookCounter = try self.model.context.count(for: request)
			
			// Check if exist books
            if bookCounter == 0 {
				
				// Getting book from network
                getResourceInBackground(fromURL: URL(string: "https://t.co/K9ziV0z3SJ")!, withBlock: { (jsonData:Data?) in
                    let json = try! load(fromData: jsonData!)
                    for dict in json {
                        do {
                            let _ = try decode(book: dict, in:self.model.context)
                        } catch {
                            print("Error proccessing \(dict)")
                        }
                        let _ = Tag(name: "Favorites", in: self.model.context)
                    }
					self.model.save()
                })
                
            }
			
			// Fetch to Table View Controller
            let fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: model.context, sectionNameKeyPath: "tag.name", cacheName: nil)
            
            // ViewControllers
            let libraryController = LibraryTableViewController(fetchedResultsController: fetchedResultsController as! NSFetchedResultsController<NSFetchRequestResult>)
            let bookController:BookViewController = BookViewController(model: Book.getLastViewed(in: model.context))
            
            // NavigationControllers
            let libraryNav = UINavigationController(rootViewController: libraryController)
            let bookNav:UINavigationController = UINavigationController(rootViewController: bookController)
            
            // SplitController
            let splitController = UISplitViewController()
            
            // Set views in SplitController
            splitController.viewControllers =  [libraryNav, bookNav]
            
            // Set delegates
            splitController.delegate = libraryController
            libraryController.delegate = bookController
            
            // Show back button to library in portrait ipad view
            bookNav.navigationItem.leftItemsSupplementBackButton = true
            if (UIDevice.current.userInterfaceIdiom == .pad) {
                bookController.navigationItem.leftBarButtonItem = splitController.displayModeButtonItem
            }
            
            // Window
            window = UIWindow(frame: UIScreen.main.bounds)
            
            // Set rootViewController And show view
            window?.rootViewController = splitController
            window?.makeKeyAndVisible()
			
			// Saving each 7 seconds
			self.model.autoSave(7)
			
            return true
			
        } catch {
            
            fatalError("Error loading coredata")
            
        }
       
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
		
		// Saving model
		self.model.save()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
		
		// Saving model
		self.model.save()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
		
		print("¡Good bye! ¡May the Force be with you!")
    }


}


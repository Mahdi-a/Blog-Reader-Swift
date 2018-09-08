//
//  MasterViewController.swift
//  Blog Reader
//
//  Created by Mahdi Amirmazaheri on 22/7/18.
//  Copyright © 2018 Mahdi Amirmazaheri. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

	var detailViewController: DetailViewController? = nil
	var managedObjectContext: NSManagedObjectContext? = nil

	let appDel : AppDelegate = UIApplication.shared.delegate as! AppDelegate
	
	lazy var context : NSManagedObjectContext = appDel.persistentContainer.viewContext
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
//		cleanDatabase()
		
		getBlogItems()
		
		// Do any additional setup after loading the view, typically from a nib.
//		navigationItem.leftBarButtonItem = editButtonItem

//		let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
//		navigationItem.rightBarButtonItem = addButton
		
		if let split = splitViewController {
		    let controllers = split.viewControllers
		    detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
		super.viewWillAppear(animated)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// MARK: - Segues

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showDetail" {
		    if let indexPath = tableView.indexPathForSelectedRow {
		    let object = fetchedResultsController.object(at: indexPath)
		        let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
		        controller.detailItem = object
		        controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
		        controller.navigationItem.leftItemsSupplementBackButton = true
		    }
		}
	}

	// MARK: - Table View

	override func numberOfSections(in tableView: UITableView) -> Int {
//		return fetchedResultsController.sections?.count ?? 0
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let sectionInfo = fetchedResultsController.sections![section]
		return sectionInfo.numberOfObjects
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
		let event = fetchedResultsController.object(at: indexPath)
		configureCell(cell, withEvent: event)
		return cell
	}

	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return true
	}

//	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//		if editingStyle == .delete {
//		    let context = fetchedResultsController.managedObjectContext
//		    context.delete(fetchedResultsController.object(at: indexPath))
//
//		    do {
//		        try context.save()
//		    } catch {
//		        // Replace this implementation with code to handle the error appropriately.
//		        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//		        let nserror = error as NSError
//		        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//		    }
//		}
//	}

	func configureCell(_ cell: UITableViewCell, withEvent event: BlogItems) {
		cell.textLabel!.text = event.title!.description
	}

	// MARK: - Fetched results controller

	var fetchedResultsController: NSFetchedResultsController<BlogItems> {
	    if _fetchedResultsController != nil {
	        return _fetchedResultsController!
	    }
	    
	    let fetchRequest: NSFetchRequest<BlogItems> = BlogItems.fetchRequest()
	    
	    // Set the batch size to a suitable number.
	    fetchRequest.fetchBatchSize = 20
	    
	    // Edit the sort key as appropriate.
	    let sortDescriptor = NSSortDescriptor(key: "title", ascending: false)
	    
	    fetchRequest.sortDescriptors = [sortDescriptor]
	    
	    // Edit the section name key path and cache name if appropriate.
	    // nil for section name key path means "no sections".
	    let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
	    aFetchedResultsController.delegate = self
	    _fetchedResultsController = aFetchedResultsController
	    
	    do {
	        try _fetchedResultsController!.performFetch()
	    } catch {
	         // Replace this implementation with code to handle the error appropriately.
	         // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	         let nserror = error as NSError
	         fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
	    }
	    
	    return _fetchedResultsController!
	}    
	var _fetchedResultsController: NSFetchedResultsController<BlogItems>? = nil

	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
	    tableView.beginUpdates()
	}

//	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
//	    switch type {
//	        case .insert:
//	            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
//	        case .delete:
//	            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
//	        default:
//	            return
//	    }
//	}

	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
	    switch type {
	        case .insert:
	            tableView.insertRows(at: [newIndexPath!], with: .fade)
	        case .delete:
	            tableView.deleteRows(at: [indexPath!], with: .fade)
	        case .update:
	            configureCell(tableView.cellForRow(at: indexPath!)!, withEvent: anObject as! BlogItems)
	        case .move:
	            configureCell(tableView.cellForRow(at: indexPath!)!, withEvent: anObject as! BlogItems)
	            tableView.moveRow(at: indexPath!, to: newIndexPath!)
	    }
	}

	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
	    tableView.endUpdates()
	}
	
	/*
	// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
	
	func controllerDidChangeContent(controller: NSFetchedResultsController) {
	// In the simplest, most efficient, case, reload the table view.
	tableView.reloadData()
	}
	*/
	
	func getBlogItems() {
		
		let blogUrl = URL(string: "https://www.googleapis.com/blogger/v3/blogs/4371296950668142214/posts?key=AIzaSyAyQkPvddviuTCsFWV3KinzUgiMEuGXPYk")!;
		
		let urlSession = URLSession.shared;
		
		let task = urlSession.dataTask(with: blogUrl) { (urlData, urlResponse, error) in
			
			if error != nil {
				print(error!)
			} else {
				
				if urlData != nil {
					
					do {
						let jsonResult = try JSONSerialization.jsonObject(with: urlData!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
						
						let titlesInDB = self.checkDatabase(entity: "BlogItems", attribute: "title")
						
						if jsonResult.count > 0 {
							
							if let items = jsonResult["items"] as? NSArray {
								
								for item in items {
									
									if let post:NSObject = item as? NSObject {
										
										let title:String = post.value(forKey: "title") as! String
										let content:String = post.value(forKey: "content") as! String
										
										if !titlesInDB.contains(title) {
											
											let newPost:NSManagedObject = NSEntityDescription.insertNewObject(forEntityName: "BlogItems", into: self.context)
											
											newPost.setValue(title, forKey: "title")
											newPost.setValue(content, forKey: "content")
										}
									}
								}
								try self.context.save()
							}
						}
					} catch {}
				}
			}
		}
		
		task.resume()
	}
	
	func checkDatabase(entity:String, attribute:String) -> [String]{
		
		let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
		
		var titles = [String]()
		
		request.returnsObjectsAsFaults = false
		
		do { let results = try context.fetch(request)
			
			if results.count > 0 {
				
				for result in results as! [NSManagedObject] {
					
					titles.append(result.value(forKey: "title")! as! String)
				}
			}
		} catch {}

		return titles
	}
	
	// This function delete everything from database
	func cleanDatabase(){
		let request = NSFetchRequest<NSFetchRequestResult>(entityName: "BlogItems")

		request.returnsObjectsAsFaults = false

		do { let results = try self.context.fetch(request)
			if results.count > 0 {
				for result in results as! [NSManagedObject] {
					print(result.value(forKey: "title")!)
					self.context.delete(result)
				}
			}
		} catch {}
	}
}


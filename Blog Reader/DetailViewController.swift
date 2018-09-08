//
//  DetailViewController.swift
//  Blog Reader
//
//  Created by Mahdi Amirmazaheri on 22/7/18.
//  Copyright © 2018 Mahdi Amirmazaheri. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {

	
	@IBOutlet var contentWebkit: WKWebView!
	

	func configureView() {
		// Update the user interface for the detail item.
//		if let detail = detailItem {
//		    if let label = detailDescriptionLabel {
//		        label.text = detail.title!.description
//		    }
//		}
		
		if let detail = detailItem {
			if let postWebkit = self.contentWebkit {
				postWebkit.loadHTMLString(detail.value(forKey: "content")! as! String, baseURL: URL(string: "https://australia.googleblog.com"))
			}
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		configureView()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	var detailItem: BlogItems? {
		didSet {
		    // Update the view.
		    configureView()
		}
	}


}


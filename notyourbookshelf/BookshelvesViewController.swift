//
//  BookshelvesViewController.swift
//  NotYourBookshelf
//
//  Created by William Kelley on 12/2/18.
//  Copyright © 2018 William Kelley. All rights reserved.
//

import UIKit

class BookshelvesViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func YourBookTap(_ sender: Any) {
    }
    
    @IBAction func NotYourBookTap(_ sender: Any) {
    }
    
    //- (IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
    //}
    
    
    @IBAction func unwindToBookshelvesViewController(segue: UIStoryboardSegue) {
        print("Unwind to Bookshelves View Controller")
    }
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "YourBookPress") {
            let vc = segue.destination as! YourBookViewController
            vc.fromBookshelves = true
        }
        /*
        if (segue.identifier == "NotYourBookPress") {
            let vc = segue.destination as! BookViewController
        }
        */
    }
    */
}


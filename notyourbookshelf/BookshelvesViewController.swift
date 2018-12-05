//
//  BookshelvesViewController.swift
//  Not Your Bookshelf
//
//  Created by William Kelley on 12/2/18.
//  Copyright © 2018 William Kelley. All rights reserved.
//

import UIKit
import CoreGraphics

class BookshelvesViewController: UIViewController {

    @IBOutlet weak var bookOneButton: bookButton!
    @IBOutlet weak var bookTwoButton: bookButton!
    @IBOutlet weak var bookThreeButton: bookButton!
    @IBOutlet weak var bookFourButton: bookButton!
    @IBOutlet weak var bookFiveButton: bookButton!
    @IBOutlet weak var bookSixButton: bookButton!
    @IBOutlet weak var bookSevenButton: bookButton!
    @IBOutlet weak var bookOneLabel: UILabel!
    @IBOutlet weak var bookTwoLabel: UILabel!
    @IBOutlet weak var bookThreeLabel: UILabel!
    @IBOutlet weak var bookFourLabel: UILabel!
    @IBOutlet weak var bookFiveLabel: UILabel!
    @IBOutlet weak var bookSixLabel: UILabel!
    @IBOutlet weak var bookSevenLabel: UILabel!
    
    var sampleListings: [String] = ["Intro to Prog", "Linear Alg", "Intro to Analysis", "", "", "", ""] // 6 TOTAL
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.bookOneLabel.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
        self.bookTwoLabel.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
        self.bookThreeLabel.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
        self.bookFourLabel.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
        self.bookFourLabel.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
        self.bookFiveLabel.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
        self.bookSixLabel.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
        
        self.bookOneLabel.text = self.sampleListings[0]
        self.bookTwoLabel.text = self.sampleListings[1]
        self.bookThreeLabel.text = self.sampleListings[2]
        self.bookFourLabel.text = self.sampleListings[3]
        self.bookFiveLabel.text = self.sampleListings[4]
        self.bookSixLabel.text = self.sampleListings[5]
        self.bookSevenLabel.text = self.sampleListings[6]
        
        self.bookOneButton.showsTouchWhenHighlighted = true
        self.bookTwoButton.showsTouchWhenHighlighted = true
        self.bookThreeButton.showsTouchWhenHighlighted = true
        self.bookFourButton.showsTouchWhenHighlighted = true
        self.bookFiveButton.showsTouchWhenHighlighted = true
        self.bookSixButton.showsTouchWhenHighlighted = true
        self.bookSevenButton.showsTouchWhenHighlighted = true
    }
    
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


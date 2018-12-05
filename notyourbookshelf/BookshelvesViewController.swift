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
    
    @IBOutlet weak var yourBookButton: UIButton!
    @IBOutlet weak var notYourBookButton: UIButton!
    @IBOutlet weak var nybButtton: bookButton!
    
    @IBOutlet weak var bookOneLabel: UILabel!
    @IBOutlet weak var bookTwoLabel: UILabel!
    @IBOutlet weak var bookThreeLabel: UILabel!
    @IBOutlet weak var bookFourLabel: UILabel!
    @IBOutlet weak var bookFiveLabel: UILabel!
    @IBOutlet weak var bookSixLabel: UILabel!
    @IBOutlet weak var bookSevenLabel: UILabel!
    
    @IBOutlet weak var nybOneLabel: UILabel!
    @IBOutlet weak var nybTwoLabel: UILabel!
    @IBOutlet weak var nybThreeLabel: UILabel!
    @IBOutlet weak var nybFourLabel: UILabel!
    @IBOutlet weak var nybFiveLabel: UILabel!
    @IBOutlet weak var nybSixLabel: UILabel!
    @IBOutlet weak var nybSevenLabel: UILabel!
    
    var sampleListings: [String] = ["Intro to Prog", "Linear Alg", "Intro to Analysis", "", "", "", ""] // 6 TOTAL
    var sampleFavorites: [String] = ["f1","f2","","","","",""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        //background color for the view
        //view.backgroundColor = UIColor(white: 0.25, alpha: 1.0)
        //Iteration 1: Make a button
        //view.addSubview(makeButtonWithText("Indie Button"))
        
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
        
        self.nybOneLabel.text = self.sampleFavorites[0]
        self.nybTwoLabel.text = self.sampleFavorites[1]
        self.nybThreeLabel.text = self.sampleFavorites[2]
        self.nybFourLabel.text = self.sampleFavorites[3]
        self.nybFiveLabel.text = self.sampleFavorites[4]
        self.nybSixLabel.text = self.sampleFavorites[5]
        self.nybSevenLabel.text = self.sampleFavorites[6]
        
        self.bookOneButton.showsTouchWhenHighlighted = true
        self.bookTwoButton.showsTouchWhenHighlighted = true
        self.bookThreeButton.showsTouchWhenHighlighted = true
        self.bookFourButton.showsTouchWhenHighlighted = true
        self.bookFiveButton.showsTouchWhenHighlighted = true
        self.bookSixButton.showsTouchWhenHighlighted = true
        self.bookSevenButton.showsTouchWhenHighlighted = true
    }
    
    func makeButtonWithText(text:String) -> UIButton {
        let myButton = UIButton(type: UIButton.ButtonType.system)
        //Set a frame for the button. Ignored in AutoLayout/ Stack Views
        myButton.frame = CGRect(x: 30, y: 30, width: 150, height: 150)
        //Set background color
        myButton.backgroundColor = UIColor.blue
        return myButton
    }
    
    @IBAction func YourBookButtonPress(_ sender: Any) {
        presentingViewController?.performSegue(withIdentifier: "SegueToYourBook", sender: self)
    }
    
    @IBAction func NotYourBookButtonPress(_ sender: Any) {
        presentingViewController?.performSegue(withIdentifier: "SegueToNotYourBook", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueToYourBook" {
            let vc = segue.destination as? BookViewController
            vc?.yourBook = true
        }
        if segue.identifier == "SegueToNotYourBook" {
            let vc = segue.destination as? BookViewController
            vc?.yourBook = false
        }
    }
    
}


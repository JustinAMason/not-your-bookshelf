//
//  BookshelvesViewController.swift
//  Not Your Bookshelf
//
//  Created by William Kelley on 12/2/18.
//  Copyright © 2018 William Kelley. All rights reserved.
//

import UIKit
import Firebase
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
    
    var db: Firestore!
    
    var username: String = "demo_user" // HARD CODED
    var user_id: String!
    
    var userListings: Array<Listing>!
    var userBookmarks: Array<Listing>!
    var yourBookLabels: [String] = ["Intro to Prog", "Linear Alg", "Intro to Analysis", "", "", "", ""] // 7 spaces
    var notYourBookLabels: [String] = ["f1","f2","","","","",""] // 7 again
    
    var sampleListings: [String] = ["Intro to Prog", "Linear Alg", "Intro to Analysis", "", "", "", ""] // 7 TOTAL
    var sampleFavorites: [String] = ["f1","f2","","","","",""] // 7 AGAIN
    
    /************
    * Load Time *
    ************/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectToDatabase()
        
        // Populate Bookshelves
        populateYourBookshelf(username: username)
        populateNotYourBookshelf(username: username)
        
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
    
    
    /**********************
    * Firebase connection *
    **********************/
    
    func connectToDatabase() {
        db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
    }
    
    
    /***********************
    * Dynamic Book Buttons *
    ************************/
    
    func makeBookButtonWithTitle(title:String) -> UIButton {
        let myButton = 
            //UIButton(type: UIButton.ButtonType.system)
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
    
    
    /*************************
    * Populating Bookshelves *
    **************************/
    
    func populateYourBookshelf(username: String) {
        retrieveUserListings(username: username)
        
        makeBookButtonArray(listings: userListings)
    }
    
    func populateNotYourBookshelf(username: String) {
        retrieveUserBookmarks(username: username)
        
        makeBookButtonArray(listings: userBookmarks)
    }
    
    func getUserID(username: String) -> String {
        var user_id = ""
        db.collection("users").whereField("username", isEqualTo: username).getDocuments() { (querySnapshot, err) in
            if let err = err { print("Error getting documents: \(err)") }
            else if (querySnapshot!.documents.count == 0) { print("No users") }
            else {
                print("User Found") // Should be unique (because usernames would be unique)
                user_id = querySnapshot!.documents[0].documentID
            }
        }
        return user_id
    }
    
    func retrieveUserListings(username: String) {
        let user_id = getUserID(username: self.username)
        db.collection("listings").whereField("seller_id", isEqualTo: user_id).getDocuments() { (querySnapshot, err) in
            if let err = err { print("Error getting documents: \(err)") }
            else if (querySnapshot!.documents.count == 0) { print("No Listings") }
            else {
                print("User Listing(s) found")
                for listing in querySnapshot!.documents {
                    let listing_id = listing.documentID
                    let book_id = listing["book_id"] as? String ?? ""
                    let seller_id = listing["seller_id"] as? String ?? ""
                    let price = listing["price"] as? String ?? ""
                    let condition = listing["condition"] as? String ?? ""
                    let latitude = listing["latitude"] as? String ?? ""
                    let longitude = listing["longitude"] as? String ?? ""
                    self.userListings.append(Listing( listing_id: listing_id,
                                                      book_id: book_id,
                                                      seller_id: seller_id,
                                                      price: price,
                                                      condition: condition,
                                                      latitude: latitude,
                                                      longitude: longitude ) )
                }
            }
        }
    }
    
    func retrieveUserBookmarks(username: String) {
        let user_id = getUserID(username: self.username)
        db.collection("favorites").whereField("seller_id", isEqualTo: user_id).getDocuments() { (querySnapshot, err) in
            if let err = err { print("Error getting documents: \(err)") }
            else if (querySnapshot!.documents.count == 0) { print("No Bookmarks") }
            else {
                print("User Bookmark(s) found")
                for bookmark in querySnapshot!.documents {
                    let listing_id = bookmark.documentID
                    let book_id = bookmark["book_id"] as? String ?? ""
                    let seller_id = bookmark["seller_id"] as? String ?? ""
                    let price = bookmark["price"] as? String ?? ""
                    let condition = bookmark["condition"] as? String ?? ""
                    let latitude = bookmark["latitude"] as? String ?? ""
                    let longitude = bookmark["longitude"] as? String ?? ""
                    self.userBookmarks.append(Listing( listing_id: listing_id,
                                                       book_id: book_id,
                                                      seller_id: seller_id,
                                                      price: price,
                                                      condition: condition,
                                                      latitude: latitude,
                                                      longitude: longitude) )
                }
            }
        }
    }
    
    func getTitle(book_id: String) -> String {
        var title = ""
        db.collection("books").document(book_id).getDocument { (document, error) in
            if let document = document, document.exists {
                print("Document found")
                title = document["title"] as? String ?? ""
            } else {
                print("Document does not exist")
            }
        }
        
        return title
    }
    
    func makeBookButtonArray(listings: Array<Listing>) {
        // declare bookshelf as empty array
        for listing in listings {
            let title = self.getTitle(book_id: listing.book_id)
            let bookButton = makeBookButtonWithTitle(title: title)
            // add bookButton to bookshelf
        }
        
        // return bookshelf -- REQUIRED: add return type to this func. ; add yourBookshelf & notYourBookshelf variables of return type in VC class. ; in populate... func's, set those var's equal to the return of this function.
    }
    
    /******
    * End *
    ******/
    
}


/********************************************
* Custom UIButton Class to appear as a Book *
*********************************************/

class bookButton: UIButton {
    var title: String!
    var listing_id: String!
    
    var bookColorOptions: [UIColor] = [UIColor(named: "bookOrange")!,
                                 UIColor(named: "bookRed")!,
                                 UIColor(named: "bookGreen")!,
                                 UIColor(named: "bookPurple")!]
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 4)
        let number = Int.random(in: 0 ... 3)
        self.bookColorOptions[number].setFill()
        path.fill()
    }
    
    init(title: String, listing_id: String) {
        self.title = title
        self.listing_id = listing_id
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

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

    /**********
    * Outlets *
    ***********/
    
    @IBOutlet weak var stackViewNYB: UIStackView!
    @IBOutlet weak var stackViewYB: UIStackView!
    
    /************
    * Variables *
    *************/
    
    var db: Firestore!
    
    var username: String = "demo_user" // HARD CODED
    var user_id = "00o3tUgaYM297sZSVtdi"
    
    var userListings: Array<Listing> = []
    var userBookmarks: Array<Listing> = []
    
    var selectedBookTag: Int = 0
    //var isSelectedYourBook: Bool = true
    
    
//    var yourBookLabels: [String] = ["Intro to Prog", "Linear Alg", "Intro to Analysis", "", "", "", ""] // 7 spaces
//    var notYourBookLabels: [String] = ["f1","f2","","","","",""] // 7 again
//
//    var sampleListings: [String] = ["Intro to Prog", "Linear Alg", "Intro to Analysis", "", "", "", ""] // 7 TOTAL
//    var sampleFavorites: [String] = ["f1","f2","","","","",""] // 7 AGAIN
    
    var bookColors: [UIColor] = [UIColor(named: "bookOrange")!,
                                 UIColor(named: "bookRed")!,
                                 UIColor(named: "bookGreen")!,
                                 UIColor(named: "bookPurple")!]
    
    /************
    * Load Time *
    ************/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectToDatabase()
        
        populateYourBookshelf(username: username)
        populateNotYourBookshelf(username: username)
        
        //populateYourBookshelf(username: username)
        //populateNotYourBookshelf(username: username)
        
        //view.backgroundColor = UIColor(white: 0.25, alpha: 1.0)
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
    
    func makeBookButtonWithInfo(title:String, listing_id:String, indexOfListing: Int, isYourBook: Bool) -> UIButton {
        print("Making button for... \(title)")
        let myButton = UIButton(type: UIButton.ButtonType.system)
        
        myButton.titleLabel?.text = title
        myButton.titleLabel?.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2) // ROTATE TEXT
        
        myButton.tag = indexOfListing // LISTING_ID -- MUST ACCESS THIS (INT), then USE TO ACCESS userListings[i].listing_id -- IN SEGUE
        
        myButton.frame = CGRect(x: 60, y: 135, width: 120, height: 35) // will be IGNORED in stack view
        myButton.layer.cornerRadius = 4
        myButton.clipsToBounds = true
        myButton.showsTouchWhenHighlighted = true
        
        let number = Int.random(in: 0 ..< self.bookColors.count)
        myButton.backgroundColor = self.bookColors[number]
        
        if isYourBook {
            myButton.addTarget(self, action: #selector(BookshelvesViewController.tapYourBook(sender:)), for: .touchUpInside)
        } else {
            myButton.addTarget(self, action: #selector(BookshelvesViewController.tapNotYourBook(sender:)), for: .touchUpInside)
        }
        
        return myButton
    }
    
    @IBAction func tapYourBook(sender: UIButton) {
        selectedBookTag = sender.tag
        presentingViewController?.performSegue(withIdentifier: "SegueToYourBook", sender: self)
    }
    
    @IBAction func tapNotYourBook(sender: UIButton) {
        selectedBookTag = sender.tag
        presentingViewController?.performSegue(withIdentifier: "SegueToNotYourBook", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueToYourBook" {
            let vc = segue.destination as? BookViewController
            vc?.listing_id = self.userListings[selectedBookTag].listing_id
            vc?.yourBook = true
        }
        if segue.identifier == "SegueToNotYourBook" {
            let vc = segue.destination as? BookViewController
            vc?.listing_id = self.userBookmarks[selectedBookTag].listing_id
            vc?.yourBook = false
        }
    }
    
    
    /*************************
    * Populating Bookshelves *
    **************************/
    
    func populateYourBookshelf(username: String) {
        
        print("...Populating Your Bookshelf...")
        
        queryUserListings(username: username)
        
        print("...Queried Listings...")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            
            print("Waited")
            
            if (!self.userListings.isEmpty) {
                self.addBooksToStackView(listings: self.userListings, stack: self.stackViewYB, areYourBooks: true)
                
                print("...Stacked Listings...")
                
            }
            return
        })
        
        print("--Populated Your Bookshelf--")
    }
    
    func populateNotYourBookshelf(username: String) {
        print("...Populating Not Your Bookshelf...")
        queryUserBookmarks(username: username)
        print("...Queried Bookmarks...")
        if (!self.userBookmarks.isEmpty) {
            addBooksToStackView(listings: self.userBookmarks, stack: self.stackViewNYB, areYourBooks: false)
        }
        print("--Populated Not Your Bookshelf--")
    }
    
    // BROKEN: function returns before database query does -- user_id is not assigned quick enough
    func getUserID(username: String) -> String {
        var user_id = ""
        db.collection("users").whereField("username", isEqualTo: username).getDocuments() { (querySnapshot, err) in
            if let err = err { print("Error getting documents: \(err)") }
            else if (querySnapshot!.documents.count == 0) { print("No users") }
            else {
                print("User Found") // Should be unique (because usernames would be unique)
                user_id = querySnapshot!.documents[0].documentID
                print("\twithID: \(user_id)")
            }
        }
        print("\treturning: \(user_id)")
        return user_id
    }
    
    func queryUserListings(username: String) {
        //let user_id = getUserID(username: self.username)
        
        db.collection("listings").whereField("seller_id", isEqualTo: self.user_id).getDocuments() { (querySnapshot, err) in
            if let err = err { print("Error getting documents: \(err)") }
            else if (querySnapshot!.documents.count == 0) {
                print("No Listings found with user_id = \(self.user_id)")
                self.userListings.append(Listing( listing_id: "pHf79ePdtDfQ5X4FBrMO",
                                                  book_id: "AqRPU9VrnGypaGJHxIIs",
                                                  seller_id: "sample",
                                                  price: "29.87",
                                                  condition: "New or Like New, No Markings",
                                                  latitude: "40.6882",
                                                  longitude: "73.9542" ) )
            }
            else {
                print("User Listing(s) found")
                for listing in querySnapshot!.documents {
                    let listing_id = listing.documentID
                    print("\tlistingID: \(listing_id)")
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
    
    func queryUserBookmarks(username: String) {
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
    
    func addBooksToStackView(listings: Array<Listing>, stack: UIStackView, areYourBooks: Bool) {
        print("...Adding Books...")
        for i in listings.indices {
            let listing = listings[i]
            let title = self.getTitle(book_id: listing.book_id)
            print("Book Title: \(title)")
            let bookButton = makeBookButtonWithInfo(title: title, listing_id: listing.listing_id, indexOfListing: i, isYourBook: areYourBooks)

            stack.addArrangedSubview(bookButton)
        }
        
        // add spacer so books appear all to left
    }
    
    /******
    * End *
    ******/
    
}

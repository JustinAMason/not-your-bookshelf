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
    * Firestore *
    ************/
    var db: Firestore!
    
    /************
    * User Info * // HARD CODED
    ************/
    var username: String = "demo_user"
    var user_id: String = "00o3tUgaYM297sZSVtdi"
    
    /******************
    * State Variables *
    *******************/
    var userListings: Array<Listing> = []
    var userListingsLabels: [String] = []
    var userListingsAuthors: [String] = []
    var userListingsEdition: [String] = []
    var userBookmarks: Array<Listing> = []
    var userBookmarksLabels: [String] = []
    var userBookmarksAuthors: [String] = []
    var userBookmarksEdition: [String] = []
    var selectedBookTag: Int = 0
    //var isSelectedYourBook: Bool = true
    
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
        
        populateBookshelves(username: username)
        //populateYourBookshelf(username: username)
        //populateNotYourBookshelf(username: username)
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
        let myButton = UIButton(type: UIButton.ButtonType.system)
        
        myButton.setTitle(title, for: .normal)
        myButton.setTitleColor(UIColor.white, for: .normal)
        myButton.setTitleShadowColor(UIColor.black, for: .normal)
        myButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        myButton.tag = indexOfListing // LISTING_ID -- MUST ACCESS THIS (INT), then USE TO ACCESS userListings[i].listing_id -- IN SEGUE
        myButton.frame = CGRect(x: 60, y: 135, width: 120, height: 35) // will be IGNORED in stack view
        myButton.layer.cornerRadius = 4
        myButton.clipsToBounds = true
        myButton.showsTouchWhenHighlighted = true
        //myButton.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let number = Int.random(in: 0 ..< self.bookColors.count)
        myButton.backgroundColor = self.bookColors[number]
        myButton.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2) // ROTATE
        
        if isYourBook {
            myButton.addTarget(self, action: #selector(self.tapYourBook(sender:)), for: .touchUpInside)
        } else {
            myButton.addTarget(self, action: #selector(self.tapNotYourBook(sender:)), for: .touchUpInside)
        }
        
        return myButton
    }
    
    @IBAction func tapYourBook(sender: UIButton) {
        print("called YBSegue")
        selectedBookTag = sender.tag
        self.performSegue(withIdentifier: "SegueToYourBook", sender: self)
    }
    
    @IBAction func tapNotYourBook(sender: UIButton) {
        print("called NYBSegue")
        selectedBookTag = sender.tag
        self.performSegue(withIdentifier: "SegueToNotYourBook", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("\n[Preparing for a segue...]")
        if segue.identifier == "SegueToYourBook" {
            let vc = segue.destination as? BookViewController
            vc?.bookTitle = self.userListingsLabels[selectedBookTag]
            vc?.author = self.userListingsAuthors[selectedBookTag]
            vc?.edition = self.userListingsEdition[selectedBookTag]
            vc?.condition = self.userListings[selectedBookTag].condition
            vc?.listing_id = self.userListings[selectedBookTag].listing_id
            vc?.price = self.userListings[selectedBookTag].price
            vc?.meetup = self.userListings[selectedBookTag].latitude + ", " + self.userListings[selectedBookTag].longitude
            vc?.isYourBook = true
        }
        if segue.identifier == "SegueToNotYourBook" {
            let vc = segue.destination as? BookViewController
            vc?.bookTitle = self.userBookmarksLabels[selectedBookTag]
            vc?.author = self.userBookmarksAuthors[selectedBookTag]
            vc?.edition = self.userBookmarksEdition[selectedBookTag]
            vc?.condition = self.userBookmarks[selectedBookTag].condition
            vc?.listing_id = self.userBookmarks[selectedBookTag].listing_id
            vc?.price = self.userBookmarks[selectedBookTag].price
            vc?.meetup = self.userBookmarks[selectedBookTag].latitude + ", " + self.userBookmarks[selectedBookTag].longitude
            vc?.isYourBook = false
        }
    }
    
    
    /*************************
    * Populating Bookshelves *
    **************************/
    
    func populateBookshelves(username: String) {
        queryUserListings(username: username)
        queryUserBookmarks(username: username)
        
        // 1 second later
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            self.queryTitles(listings: self.userListings, areYourBooks: true)
            self.queryTitles(listings: self.userBookmarks, areYourBooks: false)
        })
        
        // 2 seconds later
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            if (!self.userListings.isEmpty) {
                print("\nYour Books")
                self.addBooksToStackView(listings: self.userListings, stack: self.stackViewYB, areYourBooks: true)
            }
            if (!self.userBookmarks.isEmpty) {
                print("\nNot Your Books")
                self.addBooksToStackView(listings: self.userBookmarks, stack: self.stackViewNYB, areYourBooks: false)
            }
        })
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
        //let user_id = getUserID(username: self.username)
        db.collection("favorites").whereField("user_id", isEqualTo: self.username).getDocuments() { (querySnapshot, err) in
            if let err = err { print("Error getting documents: \(err)") }
            else if (querySnapshot!.documents.count == 0) { print("No Bookmarks") }
            else {
                print("User Bookmark(s) found")
                for bookmark in querySnapshot!.documents {
                    let bookmark_id = bookmark["listing_id"] as? String ?? ""
                    self.db.collection("listings").document(bookmark_id).getDocument { (document, error) in
                        if let document = document, document.exists {
                            print("\tBookmarked Listing found")
                            let listing_id = document.documentID
                            print("\t\tbookmarkID: \(listing_id)")
                            let book_id = document["book_id"] as? String ?? ""
                            let seller_id = document["seller_id"] as? String ?? ""
                            let price = document["price"] as? String ?? ""
                            let condition = document["condition"] as? String ?? ""
                            let latitude = document["latitude"] as? String ?? ""
                            let longitude = document["longitude"] as? String ?? ""
                            self.userBookmarks.append(Listing( listing_id: listing_id,
                                                              book_id: book_id,
                                                              seller_id: seller_id,
                                                              price: price,
                                                              condition: condition,
                                                              latitude: latitude,
                                                              longitude: longitude ) )
                        } else { print("\tBookmarked Listing does not exist") }
                    }
                }
            }
        }
    }
    
    func queryTitles(listings: Array<Listing>, areYourBooks: Bool) {
        for i in listings.indices {
            let book_id = listings[i].book_id ?? ""
            
            db.collection("books").document(book_id).getDocument { (document, error) in
                if let document = document, document.exists {
                    print("\tBook found")
                    let title = document["title"] as? String ?? "(empty)"
                    let author = document["author"] as? String ?? "(empty)"
                    let edition = document["edition"] as? String ?? "(empty)"
                    if (areYourBooks) {
                        self.userListingsLabels.append(title)
                        self.userListingsAuthors.append(author)
                        self.userListingsEdition.append(edition)
                    }
                    else {
                        self.userBookmarksLabels.append(title)
                        self.userBookmarksAuthors.append(author)
                        self.userBookmarksEdition.append(edition)
                    }
                } else { print("Book does not exist") }
            }
            
        }
        
    }
    
    func addBooksToStackView(listings: Array<Listing>, stack: UIStackView, areYourBooks: Bool) {
        print("Labels: \(userListingsLabels) and Listings: \(listings.count)")
        
        for i in listings.indices {
            
            let listing = listings[i]
            var title = ""
            if (areYourBooks) { title = userListingsLabels[i] }
            else { title = userBookmarksLabels[i] }
            let bookButton = self.makeBookButtonWithInfo(title: title, listing_id: listing.listing_id, indexOfListing: i, isYourBook: areYourBooks)
            
            stack.addArrangedSubview(bookButton)
            print("Book: \(bookButton.titleLabel?.text ?? "(defaulted)")")
        }
        
        // add spacer so books appear all to left
    }
    
    /******
    * End *
    ******/
    
}

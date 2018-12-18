//
//  BookshelvesVC.swift
//  Not Your Bookshelf
//
//  Created by William Kelley on 12/2/18.
//  Copyright © 2018 William Kelley. All rights reserved.
//

import UIKit
import Firebase
import CoreGraphics

class BookshelvesVC: UIViewController {

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
    var userBooksListed: Array<Book> = []
    var userBookmarks: Array<Listing> = []
    var userBooksBookmarked: Array<Book> = []
    var userPurchases: Array<Listing> = []
    var selectedBookTag: Int = 0
    
    var bookColors: [UIColor] = [UIColor.black]
//    var bookColors: [UIColor] = [UIColor(named: "bookOrange")!,
//                                 UIColor(named: "bookRed")!,
//                                 UIColor(named: "bookGreen")!,
//                                 UIColor(named: "bookPurple")!]
    
    /************
    * Load Time * // calls viewLoadSetup so that everytime the user sees this VC, the bookshelves will reload -- ensures deleting, adding, bookmarking listings will be reflected
    ************/
    var isLoadingViewController = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectToDatabase()
        isLoadingViewController = true
        viewLoadSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isLoadingViewController {
            isLoadingViewController = false
        } else {
            viewLoadSetup()
        }
    }
    
    func viewLoadSetup(){
        userListings = []
        userBooksListed = []
        userBookmarks = []
        userBooksBookmarked = []
        userPurchases = []
        populateBookshelves(user_id: user_id)
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
            let vc = segue.destination as? BookVC
            vc?.bookTitle = self.userBooksListed[selectedBookTag].title
            vc?.author = self.userBooksListed[selectedBookTag].author
            vc?.edition = self.userBooksListed[selectedBookTag].edition
            vc?.condition = self.userListings[selectedBookTag].condition
            vc?.listing_id = self.userListings[selectedBookTag].listing_id
            vc?.price = self.userListings[selectedBookTag].price
            vc?.latitude = self.userListings[selectedBookTag].latitude
            vc?.longitude = self.userListings[selectedBookTag].longitude
            vc?.isYourBook = true
        }
        if segue.identifier == "SegueToNotYourBook" {
            let vc = segue.destination as? BookVC
            vc?.bookTitle = self.userBooksBookmarked[selectedBookTag].title
            vc?.author = self.userBooksBookmarked[selectedBookTag].author
            vc?.edition = self.userBooksBookmarked[selectedBookTag].edition
            vc?.condition = self.userBookmarks[selectedBookTag].condition
            vc?.listing_id = self.userBookmarks[selectedBookTag].listing_id
            vc?.price = self.userBookmarks[selectedBookTag].price
            vc?.latitude = self.userListings[selectedBookTag].latitude
            vc?.longitude = self.userListings[selectedBookTag].longitude
            vc?.isYourBook = false
        }
    }
    
    
    /*************************
    * Populating Bookshelves *
    **************************/
    
    func populateBookshelves(user_id: String) {
        queryUserListings(user_id: user_id)
        queryUserBookmarks(user_id: user_id)
        
        // 1 second later
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            self.queryTitles(listings: self.userListings, areYourBooks: true)
            self.queryTitles(listings: self.userBookmarks, areYourBooks: false)
        })
        
        // 2 seconds later
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            if (!self.userListings.isEmpty) {
                print("\nYour Books")
                self.addBooksToStackView(listings: self.userListings, books: self.userBooksListed, stack: self.stackViewYB, areYourBooks: true)
            }
            if (!self.userBookmarks.isEmpty) {
                print("\nNot Your Books")
                self.addBooksToStackView(listings: self.userBookmarks, books: self.userBooksBookmarked, stack: self.stackViewNYB, areYourBooks: false)
            }
        })
    }
    
    func queryUserListings(user_id: String) {
        
        db.collection("listings").whereField("seller_id", isEqualTo: user_id).getDocuments() { (querySnapshot, err) in
            if let err = err { print("Error getting documents: \(err)") }
            else if (querySnapshot!.documents.count == 0) { print("\n**\nNo Listings found for user_id = \(user_id)") }
            else {
                print("\n**\nListing(s) found for user_id = \(user_id)")
                for listing in querySnapshot!.documents {
                    let listing_id = listing.documentID
                    //print("\tlistingID: \(listing_id)")
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
    
    func queryUserBookmarks(user_id: String) {
        db.collection("favorites").whereField("user_id", isEqualTo: user_id).getDocuments() { (querySnapshot, err) in
            if let err = err { print("Error getting documents: \(err)") }
            else if (querySnapshot!.documents.count == 0) { print("\n**\nNo Bookmark(s) found for user_id = \(user_id)") }
            else {
                print("\n**\nBookmark(s) found for user_id = \(user_id)")
                for bookmark in querySnapshot!.documents {
                    let bookmark_id = bookmark["listing_id"] as? String ?? ""
                    self.db.collection("listings").document(bookmark_id).getDocument { (document, error) in
                        if let document = document, document.exists {
                            let listing_id = document.documentID
                            //print("\t\tbookmarkID: \(listing_id)")
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
                        } else {
                            print("\tBookmarked Listing does not exist...deleting bookmark")
                            self.db.collection("favorites").document(bookmark.documentID).delete(){ err in
                                if let err = err {
                                    print("Error removing bookmark: \(err)")
                                } else {
                                    print("Bookmark successfully removed!")
                                }
                            }
                        }
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
                    let author = document["author"] as? String ?? "(empty)"
                    let edition = document["edition"] as? String ?? "(empty)"
                    let isbn = document["isbn"] as? String ?? "(empty)"
                    let title = document["title"] as? String ?? "(empty)"
                    print("\tBook found with title = \(title)")
                    if (areYourBooks) {
                        self.userBooksListed.append(Book( author: author,
                                                          edition: edition,
                                                          isbn: isbn,
                                                          title: title ))
                    }
                    else {
                        self.userBooksBookmarked.append(Book( author: author,
                                                              edition: edition,
                                                              isbn: isbn,
                                                              title: title ))
                    }
                } else { print("Book does not exist") }
            }
            
        }
        
    }
    
    func addBooksToStackView(listings: Array<Listing>, books: Array<Book>, stack: UIStackView, areYourBooks: Bool) {
        print("Listings: \(listings.count), and Books: \(books.count)  ")
        for i in listings.indices {
            let listing = listings[i]
            let title = books[i].title
            let bookButton = self.makeBookButtonWithInfo(title: title!, listing_id: listing.listing_id, indexOfListing: i, isYourBook: areYourBooks)
            
            stack.addArrangedSubview(bookButton)
            print("Book: \(bookButton.titleLabel?.text ?? "(defaulted)")")
        }
        
        // add spacer so books appear all to left
    }
    
    /******
    * End *
    ******/
    
}

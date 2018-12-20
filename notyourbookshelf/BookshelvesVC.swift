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
    @IBOutlet weak var stackViewYB: UIStackView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var stackViewNYB: UIStackView!
    
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
    var userBookmarks: Array<Listing> = []
    var userPurchases: Array<Listing> = []
    
    var userBooksListed: Array<Book> = []
    var userBooksBookmarked: Array<Book> = []
    var userBooksPurchased: Array<Book> = []
    
    var selectedBookTag: Int = 0
    
    var bookColors: [UIColor] = [UIColor(named: "bookOrange")!,
                                 UIColor(named: "bookRed")!,
                                 UIColor(named: "bookGreen")!,
                                 UIColor(named: "bookPurple")!]
    
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
            stackViewYB.removeAlmostAllArrangedSubviews()
            stackViewNYB.removeAllArrangedSubviews()
            viewLoadSetup()
        }
    }
    
    func viewLoadSetup(){
        userListings = []
        userBookmarks = []
        userPurchases = []
        
        userBooksListed = []
        userBooksBookmarked = []
        userBooksPurchased = []
        
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
    
    func makeBookButtonWithInfo(title:String, indexOfBook: Int, isYourBook: Bool, isYourPurchase: Bool) -> UIButton {
        let myButton = UIButton(type: UIButton.ButtonType.system)
        
        myButton.setTitle(title, for: .normal)
        myButton.titleLabel!.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        myButton.titleLabel!.lineBreakMode = NSLineBreakMode.byTruncatingTail
        
        if isYourPurchase {
            myButton.setTitleColor(UIColor.black, for: .normal)
            myButton.setTitleShadowColor(UIColor.white, for: .normal)
            myButton.backgroundColor = UIColor.lightGray
            myButton.layer.borderColor = UIColor.black.cgColor
            myButton.layer.borderWidth = CGFloat(1.0)
        } else {
            myButton.setTitleColor(UIColor.white, for: .normal)
            myButton.setTitleShadowColor(UIColor.black, for: .normal)
            let number = Int.random(in: 0 ..< self.bookColors.count) // randomly chooses color
            myButton.backgroundColor = self.bookColors[number]
        }
        
        myButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.fill
        myButton.contentVerticalAlignment = UIControl.ContentVerticalAlignment.fill
        myButton.layer.cornerRadius = 5
        myButton.showsTouchWhenHighlighted = true
        myButton.textRotation = -90
        myButton.contentTopBottomInsets = 7
        myButton.tag = indexOfBook // for LISTING_ID -- MUST ACCESS THIS (INT), then USE TO ACCESS userListings[i].listing_id -- IN SEGUE
        myButton.widthAnchor.constraint(equalToConstant: 30.0).isActive = true
        
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
            vc?.seller_id = self.userListings[selectedBookTag].seller_id
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
            vc?.seller_id = self.userBookmarks[selectedBookTag].seller_id
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
        queryUserPurchases(user_id: user_id)
        
        // 1 second later
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            self.queryTitles(listings: self.userListings,
                             areYourBooks: true,
                             areYourPurchases: false)
            self.queryTitles(listings: self.userBookmarks,
                             areYourBooks: false,
                             areYourPurchases: false)
            self.queryTitles(listings: self.userPurchases,
                             areYourBooks: false,
                             areYourPurchases: true)
        })
        
        // 2 seconds later
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            self.displayBookshelfOnView(stackView: self.stackViewYB,
                                        books: self.userBooksListed,
                                        isYourBookshelf: true,
                                        areYourPurchased: false)
            self.displayBookshelfOnView(stackView: self.stackViewNYB,
                                        books: self.userBooksBookmarked,
                                        isYourBookshelf: false,
                                        areYourPurchased: false)
        })
        
        // 3 seconds later -- happens after 'your listed books' are added to 'stackViewYB' (your bookshelf) so that nothing weird happens if 'your purchased books' are added at the same time.
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
            self.displayBookshelfOnView(stackView: self.stackViewYB,
                                        books: self.userBooksPurchased,
                                        isYourBookshelf: true,
                                        areYourPurchased: true)
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
                            let book_id = document["book_id"] as? String ?? ""
                            let seller_id = document["seller_id"] as? String ?? ""
                            let price = document["price"] as? String ?? ""
                            let condition = document["condition"] as? String ?? ""
                            let latitude = document["latitude"] as? String ?? ""
                            let longitude = document["longitude"] as? String ?? ""
                            self.userBookmarks.append(Listing(listing_id: listing_id,
                                                              book_id: book_id,
                                                              seller_id: seller_id,
                                                              price: price,
                                                              condition: condition,
                                                              latitude: latitude,
                                                              longitude: longitude ) )
                        } else {
                            print("\tBookmarked Listing does not exist...deleting bookmark")
                            self.db.collection("favorites").document(bookmark.documentID).delete(){ err in
                                if let err = err { print("Error removing bookmark: \(err)") }
                                else { print("Bookmark successfully removed!") }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func queryUserPurchases(user_id: String) {
        db.collection("purchases").whereField("buyer_id", isEqualTo: user_id).getDocuments() { (querySnapshot, err) in
            if let err = err { print("Error getting purchases: \(err)") }
            else if (querySnapshot!.documents.count == 0) { print("\n**\nNo Purchases found for user_id = \(user_id)") }
            else {
                print("\n**\nPurchases(s) found for user_id = \(user_id)")
                for purchase in querySnapshot!.documents {
                    let listing_id = purchase["listing_id"] as? String ?? ""
                    //let seller_id = purchase["seller_id"] as? String ?? "" // unused
                    //let buyer_id = purchase["buyer_id"] as? String ?? "" // unused
                    self.db.collection("listings").document(listing_id).getDocument { (document, error) in
                        if let document = document, document.exists {
                            let listing_id = document.documentID
                            let book_id = document["book_id"] as? String ?? ""
                            let seller_id = document["seller_id"] as? String ?? ""
                            let price = document["price"] as? String ?? ""
                            let condition = document["condition"] as? String ?? ""
                            let latitude = document["latitude"] as? String ?? ""
                            let longitude = document["longitude"] as? String ?? ""
                            self.userPurchases.append(Listing(listing_id: listing_id,
                                                              book_id: book_id,
                                                              seller_id: seller_id,
                                                              price: price,
                                                              condition: condition,
                                                              latitude: latitude,
                                                              longitude: longitude ) )
                        } else {
                            print("\tPurchased Listing does not exist...deleting purchase")
                            self.db.collection("purchases").document(purchase.documentID).delete(){ err in
                                if let err = err { print("Error removing purchase: \(err)") }
                                else { print("Purchase successfully removed!") }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func queryTitles(listings: Array<Listing>, areYourBooks: Bool, areYourPurchases: Bool) {
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
                        self.userBooksListed.append(Book(author: author,
                                                         edition: edition,
                                                         isbn: isbn,
                                                         title: title ))
                    }
                    else if (areYourPurchases){
                        self.userBooksPurchased.append(Book(author: author,
                                                            edition: edition,
                                                            isbn: isbn,
                                                            title: title ))
                    } else { // not your books or purchases -> your bookmarks
                        self.userBooksBookmarked.append(Book(author: author,
                                                             edition: edition,
                                                             isbn: isbn,
                                                             title: title ))
                    }
                } else { print("Book does not exist") }
            }
            
        }
        
    }
    
    func displayBookshelfOnView(stackView: UIStackView, books: Array<Book>, isYourBookshelf: Bool, areYourPurchased: Bool) {
        print("\n**\nDisplaying Bookshelf...")
        //create book button array
        let stack = stackView
        print("\tisYourBookshelf \(isYourBookshelf), Number of Books: \(books.count)")
        for i in books.indices {
            let book = books[i]
            let newBook = makeBookButtonWithInfo(title: book.title,
                                                 indexOfBook: i,
                                                 isYourBook: isYourBookshelf && !areYourPurchased,
                                                 isYourPurchase: areYourPurchased)
            
            var index = 0
            if (isYourBookshelf) {
                index = stack.arrangedSubviews.count - 1
            }
            
            
            newBook.isHidden = true
            stack.insertArrangedSubview(newBook, at: index)
            
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                newBook.isHidden = false
            })
            
            print("\t\t...added book with title = \(book.title!)")
        }
        
        return
    }
    
    /******
    * End *
    ******/
    
}

extension UIStackView {
    
    func removeAllArrangedSubviews() {
        
        let removedSubviews = arrangedSubviews.reduce([]) { (allSubviews, subview) -> [UIView] in
            self.removeArrangedSubview(subview)
            return allSubviews + [subview]
        }
        
        // Deactivate all constraints
        NSLayoutConstraint.deactivate(removedSubviews.flatMap({ $0.constraints }))
        
        // Remove the views from self
        removedSubviews.forEach({ $0.removeFromSuperview() })
    }
    
    func removeAlmostAllArrangedSubviews() {
        //var removedSubviews = Array<UIView>()
        let books = arrangedSubviews[..<(arrangedSubviews.count - 1)]
        var i = 0
        while arrangedSubviews.count > 1 {
            self.removeArrangedSubview(books[i])
            i += 1
        }
        
        // Deactivate all constraints
        NSLayoutConstraint.deactivate(books.flatMap({ $0.constraints }))
        
        // Remove the views from self
        books.forEach({ $0.removeFromSuperview() })
    }
}

//
//  BookVC.swift
//  Not Your Bookshelf
//
//  Created by William Kelley on 12/3/18.
//  Copyright © 2018 William Kelley. All rights reserved.
//

import UIKit
import Firebase

class BookVC: UIViewController {
    
    var db: Firestore!
    
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var buyButton: UIBarButtonItem!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var editionLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var meetupLabel: UILabel!
    @IBOutlet weak var priceAmtLabel: UILabel!
    @IBOutlet weak var optionButton: UIButton!
    
    /************
     * User Info * // HARD CODED
     ************/
    var username: String = "demo_user"
    var user_id: String = "00o3tUgaYM297sZSVtdi"
    
    /************
    * Variables *
    ************/
    var listing_id: String!
    var seller_id: String!
    var book_id: String!
    var bookTitle: String!
    var author: String!
    var edition: String!
    var condition: String!
    var price: String!
    var latitude: String!
    var longitude: String!
    var isYourBook: Bool = false
    
    
    func connectToDatabase() {
        db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectToDatabase()
        updateBookmark()
        
        //Listing(listing_id: listing_id, book_id: book_id, seller_id: username, price: price, condition: condition, latitude: latitude, longitude: longitude)
        titleLabel.text = bookTitle;
        authorLabel.text = author;
        editionLabel.text = edition;
        conditionLabel.text = condition;
        priceAmtLabel.text = price;
        meetupLabel.text = latitude + ", " + longitude;
        
        // Determine if Your Book or Not Your Book -- Set title, enable/disable Buy button, enable/disable bookmark or edit
        if (self.isYourBook) {
            navBar.title = "Your Book"
            buyButton.isEnabled = false
            optionButton.isEnabled = true
            optionButton.setImage(UIImage(named: "Edit_Unfilled"), for: UIControl.State.normal);
            optionButton.setImage(UIImage(named: "Edit_Filled"), for: UIControl.State.highlighted);
        }
        else {
            navBar.title = "Not Your Book"
            buyButton.isEnabled = true
            optionButton.isEnabled = true
            optionButton.setImage(UIImage(named: "Bookmark_Unfilled"), for: UIControl.State.normal)
            //optionButton.setImage(UIImage(named: "Bookmark_Filled"), for: UIControl.State.highlighted);
        }
    }
    
    
    /*******************
    * Back & Buy Press *
    *******************/
    
    @IBAction func backPress(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buyPress(_ sender: Any) {
        print("Checking purchases...")
        //check if listing already purchased by the user, if so, do nothing.
        //else, add to purchased, check if in bookmarks (if so, remove it), dismiss VC
        db.collection("purchases")
            .whereField("listing_id", isEqualTo: self.listing_id)
            .whereField("buyer_id", isEqualTo: self.user_id)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error in checking purchases: \(err)");
                } else if (querySnapshot!.documents.count == 1) {
                    print("Listing = \(self.listing_id!) already purchased by user = \(self.user_id)")
                    return
                } else if (querySnapshot!.documents.count == 0) {
                    print("Adding to Purchases...")
                    // if in favorites, remove
                    self.db.collection("favorites")
                        .whereField("user_id", isEqualTo: self.user_id)
                        .whereField("listing_id", isEqualTo: self.listing_id)
                        .getDocuments() { (querySnapshot, err) in
                            if let err = err {
                                print("Error checking bookmarks: \(err)");
                            } else if (querySnapshot!.documents.count == 1){
                                print("Removing Bookmark");
                                self.removeBookmarkInDatabase(document_id: querySnapshot!.documents[0].documentID);
                            } else {
                                print("Listing not Bookmarked");
                            }
                    }
                    // add to purchases
                    self.db.collection("purchases").addDocument(data: [
                        "listing_id": self.listing_id,
                        "buyer_id": self.user_id,
                        "seller_id": self.seller_id
                    ]) { err in
                        if let err = err { print("Error adding purchase doc: \(err)") }
                        else {
                            print("Purchase added to database!")
                            self.presentingViewController?.dismiss(animated: true, completion: nil)
                        }
                    }
                }
        }
        
    }
    
    
    /**********************************
    * Edit or Bookmark/Favorite Press *
    **********************************/
    
    func updateBookmark() {
        // Only if Not Your Book
        if (!self.isYourBook) {
            db.collection("favorites")
                .whereField("user_id", isEqualTo: self.user_id)
                .whereField("listing_id", isEqualTo: listing_id)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)");
                    } else if (querySnapshot!.documents.count > 0) {
                        self.optionButton.setImage(UIImage(named: "Bookmark_Filled"), for: UIControl.State.normal);
                    }
            }
        }
    }
    
    @IBAction func optionButtonPress() {
        // option: Edit
        if (self.isYourBook) {
            print("Segueing")
            self.performSegue(withIdentifier: "SegueToEditYourBook", sender: self)
        }
        else { // option: Bookmark
            print("Toggling Bookmark...")
            db.collection("favorites")
                .whereField("user_id", isEqualTo: self.user_id)
                .whereField("listing_id", isEqualTo: listing_id)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error checking bookmarks: \(err)");
                    } else if (querySnapshot!.documents.count == 0) {
                        self.addBookmarkToDatabase();
                    } else if (querySnapshot!.documents.count == 1){
                        print("Favorite already stored in database");
                        self.removeBookmarkInDatabase(document_id: querySnapshot!.documents[0].documentID);
                    }
                }
        }
    }
    
    func addBookmarkToDatabase() {
        print("Adding to Bookmarks...")
        db.collection("favorites").addDocument(data: [
            "user_id": self.user_id,
            "listing_id": self.listing_id
        ]) { err in
            if let err = err { print("Error adding document: \(err)") }
            else {
                print("Favorite added to database!")
                self.optionButton.setImage(UIImage(named: "Bookmark_Filled"), for: UIControl.State.normal);
            }
        }
    }
    
    func removeBookmarkInDatabase(document_id: String) {
        print("Removing from Bookmarks...")
        db.collection("favorites").document(document_id).delete(){ err in
            if let err = err { print("Error removing bookmark: \(err)") }
            else {
                print("Bookmark successfully removed!")
                self.optionButton.setImage(UIImage(named: "Bookmark_Unfilled"), for: UIControl.State.normal);
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("\n[Preparing for a segue...]")
        if segue.identifier == "SegueToEditYourBook" {
            let vc = segue.destination as? AddBookVC
            vc?.isEdit = true
            vc?.listing_idFromEdit = listing_id
            vc?.book_idFromEdit = book_id
            vc?.titleFromEdit = bookTitle
            vc?.authorFromEdit = author
            vc?.editionFromEdit = edition
            vc?.priceFromEdit = price
            vc?.latitudeFromEdit = latitude
            vc?.longitudeFromEdit = longitude
            
            let indexOfSeperator = condition.firstIndex(of: ",")
            let indexOfSpace = condition.index(after:indexOfSeperator!)
            let indexOfTextualCondition = condition.index(after:indexOfSpace)
            let physicalCondition = String(condition.prefix(upTo: indexOfSeperator!))
            let textualCondition = String(condition.suffix(from: indexOfTextualCondition))
            vc?.physicalConditionFromEdit = physicalCondition
            vc?.textualConditionFromEdit = textualCondition
        }
    }
}

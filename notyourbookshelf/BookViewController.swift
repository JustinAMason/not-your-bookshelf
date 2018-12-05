//
//  BookViewController.swift
//  Not Your Bookshelf
//
//  Created by William Kelley on 12/3/18.
//  Copyright © 2018 William Kelley. All rights reserved.
//

import UIKit
import Firebase

class BookViewController: UIViewController {
    
    var db: Firestore!
    
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var navBarRightButton: UIBarButtonItem!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var editionLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var meetupLabel: UILabel!
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var priceAmtLabel: UILabel!
    
    var bookTitle: String!
    var author: String!
    var edition: String!
    var condition: String!
    var listing_id: String!
    var price: String!
    var meetup: String!
    var yourBook: Bool = false
    
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
        titleLabel.text = bookTitle;
        authorLabel.text = author;
        editionLabel.text = edition;
        conditionLabel.text = condition;
        priceAmtLabel.text = price;
        meetupLabel.text = meetup;
        
        // Determine if Your Book or Not Your Book -- Set title, enable/disable Buy button, enable/disable bookmark or edit
        if (self.yourBook) {
            self.bookmarkButton.setImage(UIImage(named: "Edit_Unfilled"), for: UIControl.State.normal);
            self.bookmarkButton.setImage(UIImage(named: "Edit_Filled"), for: UIControl.State.highlighted);
            navBar.title = "Your Book"
            navBarRightButton.isEnabled = false
        }
        else {
            self.bookmarkButton.setImage(UIImage(named: "Bookmark_Unfilled"), for: UIControl.State.normal);
            navBar.title = "Not Your Book"
            navBarRightButton.isEnabled = true
        }
    }
    
    
    /*************
    * Back Press *
    *************/
    
    @IBAction func backPress(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    /**********************************
    * Edit or Bookmark/Favorite Press *
    **********************************/
    
    func updateBookmark() {
        // Only if Not Your Book
        if (!self.yourBook) {
            db.collection("favorites")
                .whereField("user_id", isEqualTo: "demo_user")
                .whereField("listing_id", isEqualTo: listing_id)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)");
                    } else if (querySnapshot!.documents.count > 0) {
                        self.bookmarkButton.setImage(UIImage(named: "Bookmark_Filled"), for: UIControl.State.normal);
                    }
            }
        }
    }
    
    @IBAction func favoriteListing() {
        if (self.yourBook) {
            print("Segueing")
            // delete listing from Firebase
            
            // segue to AddBookVC
            presentingViewController?.performSegue(withIdentifier: "SegueToAddBook", sender: self)
        }
        else {
            print("Adding to Favorites")
            db.collection("favorites")
            .whereField("user_id", isEqualTo: "demo_user")
            .whereField("listing_id", isEqualTo: listing_id)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)");
                } else if (querySnapshot!.documents.count == 0) {
                    self.addFavoriteToDatabase();
                } else {
                    print("Favorite already stored in database")
                }
            }
        }
    }
    
    func addFavoriteToDatabase() {
        db.collection("favorites").addDocument(data: [
            "user_id": "demo_user",
            "listing_id": self.listing_id
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Favorite added to database!")
                self.bookmarkButton.setImage(UIImage(named: "Bookmark_Filled"), for: UIControl.State.normal);
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? AddBookViewController
        vc?.TitleField.text = self.bookTitle
        vc?.AuthorField.text = self.author
        vc?.EditionField.text = self.edition
        vc?.PriceField.text = self.price
    }
}

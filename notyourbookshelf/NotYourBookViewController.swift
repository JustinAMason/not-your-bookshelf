//
//  NotYourBookViewController.swift
//  Not Your Bookshelf
//
//  Created by William Kelley on 12/3/18.
//  Copyright © 2018 William Kelley. All rights reserved.
//

import UIKit
import Firebase

class NotYourBookViewController: UIViewController {
    
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
    
    func connectToDatabase() {
        db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
    }
    
    func updateBookmark() {
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
    }
    
    // pressing back
    @IBAction func backPress(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func favoriteListing() {
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

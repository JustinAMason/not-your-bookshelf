//
//  SearchController.swift
//  notyourbookshelf
//
//  Created by Justin Mason on 11/19/18.
//  Copyright © 2018 nyu.edu. All rights reserved.
//

import UIKit
import Firebase

class SearchController: UIViewController {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var titleSearchButton: UIButton!
    @IBOutlet weak var isbnSearchButton: UIButton!
    
    var db: Firestore!
    
    func connectToDatabase() {
        db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
    }
    
    func formatISBN(isbn: String) -> String {
        // strip ISBN of dashes
        // https://stackoverflow.com/questions/32851720/how-to-remove-special-characters-from-string-in-swift-2
        let nums : Set<Character> = Set("0123456789")
        return String(isbn.filter {nums.contains($0) })
    }
    
    func getListings(book_id: String) {
        db.collection("listings").whereField("book_id", isEqualTo: book_id).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else if (querySnapshot!.documents.count == 0) {
                print("No listings")
            } else {
                print("Listing(s) found")
                for listing in querySnapshot!.documents {
                    let seller_id = listing["seller_id"] as? String ?? ""
                    self.db.collection("users").document(seller_id).getDocument() { (user, err) in
                        if let err = err {
                            print("Error getting user: \(err)")
                        } else {
                            print("User found")
                            let username = user?.data()?["username"] as? String ?? ""
                            print(username)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func searchByISBN() {
        //example ISBN: "9780321967602"
        let isbn = formatISBN(isbn: textField.text ?? "")

        db.collection("books").whereField("isbn", isEqualTo: isbn).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else if (querySnapshot!.documents.count == 0) {
                print("Book not found")
            } else {
                print("Book found")
                let book_id = querySnapshot!.documents[0].documentID
                //let title = querySnapshot!.documents[0].data()["title"] as? String ?? ""
                //let author = querySnapshot!.documents[0].data()["author"] as? String ?? ""
                self.getListings(book_id: book_id)
            }
        }
    }
    
    @IBAction func searchByTitle() {
        let title = textField.text ?? "";
        
        db.collection("books").whereField("title", isEqualTo: title).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else if (querySnapshot!.documents.count == 0) {
                print("Book not found")
            } else {
                print("Book found")
                let book_id = querySnapshot!.documents[0].documentID
                //let title = querySnapshot!.documents[0].data()["title"] as? String ?? ""
                //let author = querySnapshot!.documents[0].data()["author"] as? String ?? ""
                self.getListings(book_id: book_id)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        connectToDatabase()
    }
    
}

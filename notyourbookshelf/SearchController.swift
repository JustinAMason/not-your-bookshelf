//
//  SearchController.swift
//  notyourbookshelf
//
//  Created by Justin Mason on 11/19/18.
//  Copyright © 2018 nyu.edu. All rights reserved.
//

import UIKit
import Firebase
import BarcodeScanner

class Listing {
    var lister: String!
    var price: String!
    
    init(lister: String, price: String) {
        self.lister = lister
        self.price = price
    }
}

class SearchController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var numListingsLabel: UILabel!
    
    var db: Firestore!
    var listings: Array<Listing>!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (listings == nil) { return(0) }
        return(listings.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
        cell.textLabel?.text = "Listed by " + listings[indexPath.row].lister + " ($" + listings[indexPath.row].price + ")"
        return(cell)
    }
    
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
    
    func resetListings() {
        listings = []
        numListingsLabel.text = "0 listing(s) found"
        self.tableView.reloadData()
    }
    
    func getListings(book_id: String) {
        resetListings()
        
        db.collection("listings").whereField("book_id", isEqualTo: book_id).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else if (querySnapshot!.documents.count == 0) {
                print("No listings")
            } else {
                print("Listing(s) found")
                self.numListingsLabel.text = String(querySnapshot?.count as! Int) + " listing(s) found"
                for listing in querySnapshot!.documents {
                    let price = listing["price"] as? String ?? ""
                    let seller_id = listing["seller_id"] as? String ?? ""
                    self.db.collection("users").document(seller_id).getDocument() { (user, err) in
                        if let err = err {
                            print("Error getting user: \(err)")
                        } else {
                            let username = user?.data()?["username"] as? String ?? ""
                            self.listings.append(Listing(lister: username, price: price))
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func searchByISBN() {
        //example ISBN: "9780321967602"
        textField.resignFirstResponder()
        let isbn = formatISBN(isbn: textField.text ?? "")

        db.collection("books").whereField("isbn", isEqualTo: isbn).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                self.resetListings()
            } else if (querySnapshot!.documents.count == 0) {
                print("Book not found")
                self.resetListings()
            } else {
                let book_id = querySnapshot!.documents[0].documentID
                self.getListings(book_id: book_id)
            }
        }
    }
    
    @IBAction func searchByTitle() {
        textField.resignFirstResponder()
        let title = textField.text ?? "";
        
        db.collection("books").whereField("title", isEqualTo: title).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                self.resetListings()
            } else if (querySnapshot!.documents.count == 0) {
                print("Book not found")
                self.resetListings()
            } else {
                let book_id = querySnapshot!.documents[0].documentID
                self.getListings(book_id: book_id)
            }
        }
    }
    
    @IBAction func searchByISBNScan() {
        print("Scan pressed")
        let viewController = BarcodeScannerViewController()
        viewController.codeDelegate = self as BarcodeScannerCodeDelegate
        viewController.errorDelegate = self as BarcodeScannerErrorDelegate
        viewController.dismissalDelegate = self as BarcodeScannerDismissalDelegate
        
        present(viewController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectToDatabase()
    }
    
}

extension SearchController: BarcodeScannerCodeDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
        self.textField.text = code
        searchByISBN()
        controller.dismiss(animated: true, completion: nil)
    }
}

extension SearchController: BarcodeScannerErrorDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
        print(error)
    }
}

extension SearchController: BarcodeScannerDismissalDelegate {
    func scannerDidDismiss(_ controller: BarcodeScannerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

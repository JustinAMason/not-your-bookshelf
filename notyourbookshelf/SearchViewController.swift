//
//  SearchViewController.swift
//  Not Your Bookshelf
//
//  Created by William Kelley on 12/2/18.
//  Copyright © 2018 William Kelley. All rights reserved.
//

import UIKit
import Firebase
import BarcodeScanner

class Listing {
    var lister: String!
    var price: String!
    var condition: String!
    var listing_id: String!
    var latitude: String!
    var longitude: String!
    
    init(lister: String, price: String, condition: String, listing_id: String, latitude: String, longitude: String) {
        self.lister = lister;
        self.price = price;
        self.condition = condition;
        self.listing_id = listing_id;
        self.latitude = latitude;
        self.longitude = longitude
    }
}

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var numListingsLabel: UILabel!
    @IBOutlet weak var bookTitle: UILabel!
    @IBOutlet weak var bookAuthor: UILabel!
    @IBOutlet weak var bookEdition: UILabel!
    
    
    var db: Firestore!
    var listings: Array<Listing>!
    var curListingID: String!
    var curCondition: String = ""
    var curPrice: String = ""
    var curMeetup: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectToDatabase()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (listings == nil) { return(0) }
        return(listings.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
        cell.textLabel?.text = "Listed by " + listings[indexPath.row].lister + " ($" + listings[indexPath.row].price + ")"
        return(cell)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentCell = tableView.cellForRow(at: indexPath as IndexPath) as! UITableViewCell;
        self.curListingID = listings[(indexPath[1])].listing_id
        self.curCondition = listings[(indexPath[1])].condition
        self.curPrice = listings[(indexPath[1])].price
        self.curMeetup = listings[(indexPath[1])].latitude + ", " + listings[(indexPath[1])].longitude
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
        tableView.isHidden = true
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
                self.tableView.isHidden = false
                self.numListingsLabel.text = String(querySnapshot!.count) + " listing(s) found"
                for listing in querySnapshot!.documents {
                    let price = listing["price"] as? String ?? ""
                    let condition = listing["condition"] as? String ?? "";
                    let seller_id = listing["seller_id"] as? String ?? "";
                    let listing_id = listing.documentID;
                    let latitude = listing["latitude"] as? String ?? "";
                    let longitude = listing["longitude"] as? String ?? "";
                    print("Lat: \(latitude), Long: \(longitude)")
                    self.db.collection("users").document(seller_id).getDocument() { (user, err) in
                        if let err = err {
                            print("Error getting user: \(err)")
                        } else {
                            let username = user?.data()?["username"] as? String ?? ""
                            self.listings.append(Listing(lister: username, price: price, condition: condition, listing_id: listing_id, latitude: latitude, longitude: longitude))
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
                self.bookTitle.text = "(Book unknown)"
                self.bookAuthor.text = "(Author unknown)"
                self.resetListings()
            } else {
                self.bookTitle.text = querySnapshot!.documents[0]["title"] as? String ?? ""
                self.bookAuthor.text = querySnapshot!.documents[0]["author"] as? String ?? ""
                self.bookEdition.text = querySnapshot!.documents[0]["edition"] as? String ?? ""
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
                self.bookTitle.text = "(Book unknown)"
                self.bookAuthor.text = "(Author unknown)"
                self.resetListings()
            } else {
                self.bookTitle.text = querySnapshot!.documents[0]["title"] as? String ?? ""
                self.bookAuthor.text = querySnapshot!.documents[0]["author"] as? String ?? ""
                self.bookEdition.text = querySnapshot!.documents[0]["edition"] as? String ?? ""
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? BookViewController
        vc?.bookTitle = bookTitle.text
        vc?.author = bookAuthor.text
        vc?.edition = bookEdition.text
        vc?.condition = self.curCondition
        vc?.listing_id = self.curListingID
        vc?.price = self.curPrice
        vc?.meetup = self.curMeetup
        vc?.yourBook = false
    }
    
}

extension SearchViewController: BarcodeScannerCodeDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
        self.textField.text = code
        searchByISBN()
        controller.dismiss(animated: true, completion: nil)
    }
}

extension SearchViewController: BarcodeScannerErrorDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
        print(error)
    }
}

extension SearchViewController: BarcodeScannerDismissalDelegate {
    func scannerDidDismiss(_ controller: BarcodeScannerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

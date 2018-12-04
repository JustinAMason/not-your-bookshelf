//
//  AddBookViewController.swift
//  Not Your Bookshelf
//
//  Created by William Kelley on 12/3/18.
//  Copyright © 2018 William Kelley. All rights reserved.
//

import UIKit
import Firebase
import BarcodeScanner

class AddBookViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var PickerView: UIPickerView!
    @IBOutlet weak var ISBNButton: UIButton!
    @IBOutlet weak var ISBNField: UITextField!
    @IBOutlet weak var TitleField: UILabel!
    @IBOutlet weak var AuthorField: UILabel!
    @IBOutlet weak var EditionField: UILabel!
    @IBOutlet weak var PriceField: UITextField!
    @IBOutlet weak var LatitudeField: UITextField!
    @IBOutlet weak var LongitudeField: UITextField!
    
    var pickerData: [[String]] = [[String]]()
    var condition: [String] = ["(Physical)", "(Text)"]
    var db: Firestore!
    var hasISBN: Bool = false
    var isbn: String = ""
    var book_id: String = ""
    var listingRef: DocumentReference? = nil
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Connect to Database
        connectToDatabase()
        
        // Connecting PickerView
        self.PickerView.delegate = self
        self.PickerView.dataSource = self
        
        // Condition Options
        pickerData = [ ["(Physical)", "New or Like New", "Lightly Used", "Heavily Used"],
                       ["(Text)", "No Markings", "Light Marking", "Heavy Marking"] ]
        
        // [FUTURE]
        // Special Condition Options -- Contributor Signature, Contributor Note, Collectible Cover Art
    }
    
    
    // (Routine) Connect to Firebase
    func connectToDatabase() {
        db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
    }
    
    
    /*************
    * ISBN stuff *
    *************/
    
    // (helper) format raw ISBNS
    func formatISBN(isbn: String) -> String {
        // strip ISBN of dashes
        // https://stackoverflow.com/questions/32851720/how-to-remove-special-characters-from-string-in-swift-2
        let nums : Set<Character> = Set("0123456789")
        return String(isbn.filter {nums.contains($0) })
    }
    
    // Search by ISBN #
    @IBAction func searchByISBN() {
        //example ISBN: "9780321967602"
        ISBNField.resignFirstResponder()
        self.isbn = formatISBN(isbn: ISBNField.text ?? "")
        
        //var bookRef: CollectionReference { db.collection("books").whereField("isbn", isEqualTo: self.isbn!).getDocuments(completion: QuerySnapshot) }
        
        db.collection("books").whereField("isbn", isEqualTo: self.isbn).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else if (querySnapshot!.documents.count == 0) {
                print("Book not found")
                self.TitleField.text = "(Book unknown)"
                self.AuthorField.text = "(Author unknown)"
                self.EditionField.text = "(Edition unknown)"
            } else {
                self.hasISBN = true
                self.book_id = querySnapshot!.documents[0].documentID
                self.TitleField.text = querySnapshot!.documents[0]["title"] as? String ?? ""
                self.AuthorField.text = querySnapshot!.documents[0]["author"] as? String ?? ""
                self.EditionField.text = querySnapshot!.documents[0]["edition"] as? String ?? ""
            }
        }
    }
    
    // Search by ISBN Scanner
    @IBAction func searchByISBNScan() {
        print("Scan pressed")
        let viewController = BarcodeScannerViewController()
        viewController.codeDelegate = self as BarcodeScannerCodeDelegate
        viewController.errorDelegate = self as BarcodeScannerErrorDelegate
        viewController.dismissalDelegate = self as BarcodeScannerDismissalDelegate
        
        present(viewController, animated: true, completion: nil)
    }
    
    
    /**************************
    * Conditions (PickerView) *
    **************************/
    
    // # of Columns in PickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    // # of Rows in PickerView
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData[component].count
    }
    
    // Data return (row and component/column) for PickerView
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[component][row]
    }
    
    // Capture Data from PickerView
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        condition[component] = pickerData[component][row]
        print(condition)
    }
    
    
    /*******************
    * Price & Location *
    *******************/
    
    // textField delegate actions
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    /*************
    * Done Press *
    *************/
    
    // pressing done
    @IBAction func donePress(_ sender: Any) {
        if (addListing()) {
            presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    // (helper func) add new document to 'listings' collection -- with -- book_id (key), condition, meetup (array of lat, long), price, seller_id
    func addListing() -> Bool{
        if (self.hasISBN &&
            self.condition != ["(Physical)", "(Text)"] &&
            !self.PriceField.text!.isEmpty &&
            !self.LongitudeField.text!.isEmpty &&
            !self.LatitudeField.text!.isEmpty
            )
        {
            print("All Fields filled")
        }
        else {
            print("Empty Field(s). View has ...")
            print("ISBN? \(self.hasISBN)")
            print("Condition? \(self.condition != ["(Physical)", "(Text)"])")
            print("Price? \(!self.PriceField.text!.isEmpty)")
            print("Latitude? \(!self.LatitudeField.text!.isEmpty)")
            print("Longitude? \(!self.LongitudeField.text!.isEmpty)")
            return false
        }
        
        listingRef = db.collection("listings").addDocument(data: [
            "book_id": self.book_id,
            "condition": self.condition[0] + ", " + self.condition[1],
            "latitude": Int(self.LatitudeField.text!) ?? 0,
            "longitude": Int(self.LongitudeField.text!) ?? 0,
            "price": self.PriceField.text!,
            "seller_id": "demo_user" // HARD CODED -- [FUTURE] dynamic
        ]) { err in
            if let err = err{
                print("Error adding document: \(err)")
            } else{
                print("Document added with ID: \(self.listingRef!.documentID)")
            }
        }
        return true
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

/****************************
* BarcodeScanner Extensions *
****************************/
 
extension AddBookViewController: BarcodeScannerCodeDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
        self.TitleField.text = code
        searchByISBN()
        controller.dismiss(animated: true, completion: nil)
    }
}

extension AddBookViewController: BarcodeScannerErrorDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
        print(error)
    }
}

extension AddBookViewController: BarcodeScannerDismissalDelegate {
    func scannerDidDismiss(_ controller: BarcodeScannerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}


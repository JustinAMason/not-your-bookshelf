//
//  AddBookVCswift
//  Not Your Bookshelf
//
//  Created by William Kelley on 12/3/18.
//  Copyright © 2018 William Kelley. All rights reserved.
//

import UIKit
import Firebase
import BarcodeScanner

class AddBookVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var backBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var doneBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var ISBNHeaderLabel: UILabel!
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var ISBNSeperatorLabel: UILabel!
    @IBOutlet weak var PickerView: UIPickerView!
    @IBOutlet weak var ISBNButton: UIButton!
    @IBOutlet weak var ISBNField: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var editionLabel: UILabel!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var latitudeField: UITextField!
    @IBOutlet weak var longitudeField: UITextField!
    @IBOutlet weak var deleteButton: UIButton!
    
    var pickerData: [[String]] = [[String]]()
    var condition: [String] = ["(Physical)", "(Text)"]
    var db: Firestore!
    var hasISBN: Bool = false
    var isbn: String = ""
    var book_id: String = ""
    var listingRef: DocumentReference? = nil
    
    /************
     * User Info * // HARD CODED
     ************/
    var username: String = "demo_user"
    var user_id: String = "00o3tUgaYM297sZSVtdi"
    
    /**********************************
    * Info for Fields from Edit Segue *
    **********************************/
    var isEdit: Bool = false
    var listing_idFromEdit: String = ""
    var book_idFromEdit: String = ""
    var titleFromEdit: String = ""
    var authorFromEdit: String = ""
    var editionFromEdit: String = ""
    var priceFromEdit: String = ""
    var physicalConditionFromEdit: String = ""
    var textualConditionFromEdit: String = ""
    var latitudeFromEdit: String = ""
    var longitudeFromEdit: String = ""
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        connectToDatabase()
        
        
        
        
        /*********
        * Set Up *
        *********/
        navBar.title = "Add Book Listing"
        backBarButtonItem.isEnabled = true
        self.PickerView.delegate = self
        self.PickerView.dataSource = self
        pickerData = [ ["(Physical)", "New or Like New", "Lightly Used", "Heavily Used"],
                       ["(Text)", "No Markings", "Light Marking", "Heavy Marking"] ]
        // [FUTURE] Special Condition Options -- Contributor Signature, Contributor Note, Collectible Cover Art
        deleteButton.isEnabled = false
        deleteButton.isHidden = true
        
        // EDITING
        
        if (self.isEdit) {
            navBar.title = "Edit Book Listing"
            ISBNHeaderLabel.isHidden = true
            scanButton.isHidden = true
            ISBNSeperatorLabel.isHidden = true
            ISBNField.isHidden = true
            ISBNButton.isHidden = true
            titleLabel.text = self.titleFromEdit
            authorLabel.text = self.authorFromEdit
            editionLabel.text = self.editionFromEdit
            condition[0] = physicalConditionFromEdit
            condition[1] = textualConditionFromEdit
            let indexOfSelectedPhysical = pickerData[0].firstIndex(of: self.physicalConditionFromEdit)
            let indexOfSelectedTextual = pickerData[1].firstIndex(of: self.textualConditionFromEdit)
            PickerView.selectRow(indexOfSelectedPhysical!, inComponent:0, animated:true)
            PickerView.selectRow(indexOfSelectedTextual!, inComponent:1, animated:true)
            priceField.insertText(self.priceFromEdit)
            latitudeField.insertText(self.latitudeFromEdit)
            longitudeField.insertText(self.longitudeFromEdit)
            backBarButtonItem.isEnabled = false
            deleteButton.isEnabled = true
            deleteButton.isHidden = false
        }
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
                self.titleLabel.text = "(Book unknown)"
                self.authorLabel.text = "(Author unknown)"
                self.editionLabel.text = "(Edition unknown)"
            } else {
                self.hasISBN = true
                self.book_id = querySnapshot!.documents[0].documentID
                self.titleLabel.text = querySnapshot!.documents[0]["title"] as? String ?? ""
                self.authorLabel.text = querySnapshot!.documents[0]["author"] as? String ?? ""
                self.editionLabel.text = querySnapshot!.documents[0]["edition"] as? String ?? ""
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
    
    
    /*****************
    * Button Presses *
    *****************/
    
    // pressing Back
    @IBAction func backPress(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    // pressing Done -- Add if not editing; Update if editing
    @IBAction func donePress(_ sender: Any) {
        if (!isEdit) {
            if (addListing()) {
                presentingViewController?.dismiss(animated: true, completion: nil)
            } else {
                print("Failed to addListing()")
            }
        } else {
            if (editListing()) {
                presentingViewController?.dismiss(animated: true, completion: nil)
                presentingViewController?.dismiss(animated: true, completion: nil)
            } else {
                print("Failed to editListing()")
            }
        }
    }
    
    // pressing Delete
    @IBAction func deletePress(_ sender: Any) {
        if (deleteListing()) {
            presentingViewController?.dismiss(animated: true, completion: nil)
            presentingViewController?.dismiss(animated: true, completion: nil)
        } else {
            print("Failed to deleteListing()")
        }
    }
    
    // (helper func) add new document to 'listings' collection -- with -- book_id (key), condition, meetup (array of lat, long), price, seller_id
    func addListing() -> Bool{
        if (self.hasISBN &&
            self.condition != ["(Physical)", "(Text)"] &&
            !self.priceField.text!.isEmpty &&
            !self.longitudeField.text!.isEmpty &&
            !self.latitudeField.text!.isEmpty
            )
        {
            print("All Fields filled")
        }
        else {
            print("Empty Field(s). View has ...")
            print("ISBN? \(self.hasISBN)")
            print("Condition? \(self.condition != ["(Physical)", "(Text)"])")
            print("Price? \(!self.priceField.text!.isEmpty)")
            print("Latitude? \(!self.latitudeField.text!.isEmpty)")
            print("Longitude? \(!self.longitudeField.text!.isEmpty)")
            return false
        }
        
        listingRef = db.collection("listings").addDocument(data: [
            "book_id": self.book_id,
            "condition": self.condition[0] + ", " + self.condition[1],
            "latitude": self.latitudeField.text!,
            "longitude": self.longitudeField.text!,
            "price": self.priceField.text!,
            "seller_id": self.user_id
        ]) { err in
            if let err = err{
                print("Error adding document: \(err)")
            } else{
                print("Document added with ID: \(self.listingRef!.documentID)")
            }
        }
        
        return true
    }
    
    func editListing() -> Bool{
        db.collection("listings").document(self.listing_idFromEdit).updateData([
            "condition": self.condition[0] + ", " + self.condition[1],
            "latitude": self.latitudeField.text!,
            "longitude": self.longitudeField.text!,
            "price": self.priceField.text!
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
        return true
    }
    
    func deleteListing() -> Bool{
        db.collection("listings").document(self.listing_idFromEdit).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
        return true
    }

}

/****************************
* BarcodeScanner Extensions *
****************************/
 
extension AddBookVC: BarcodeScannerCodeDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
        self.ISBNField.text = code
        searchByISBN()
        controller.dismiss(animated: true, completion: nil)
    }
}

extension AddBookVC: BarcodeScannerErrorDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
        print(error)
    }
}

extension AddBookVC: BarcodeScannerDismissalDelegate {
    func scannerDidDismiss(_ controller: BarcodeScannerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}


//
//  ViewController.swift
//  notyourbookshelf
//
//  Created by Justin Mason on 11/19/18.
//  Copyright © 2018 nyu.edu. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    
    var db: Firestore!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        db.collection("books").whereField("isbn", isEqualTo: "978-0-321-96760-2").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else if (querySnapshot!.documents.count == 0) {
                print("Book not found")
            } else {
                let isbn = querySnapshot!.documents[0].data()["isbn"] as? String ?? ""
                let title = querySnapshot!.documents[0].data()["title"] as? String ?? ""
                let author = querySnapshot!.documents[0].data()["author"] as? String ?? ""
                
                print(isbn)
                print(title)
                print(author)
            }
        }
        
    }


}


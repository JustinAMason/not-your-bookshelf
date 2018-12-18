//
//  AddonClasses.swift
//  notyourbookshelf
//
//  Created by William Kelley on 12/17/18.
//  Copyright © 2018 nyu.edu. All rights reserved.
//

import UIKit

class Listing {
    var listing_id: String!
    var book_id: String!
    var seller_id: String!
    var price: String!
    var condition: String!
    var latitude: String!
    var longitude: String!
    
    init(listing_id: String, book_id: String, seller_id: String, price: String, condition: String, latitude: String, longitude: String) {
        self.seller_id = seller_id
        self.book_id = book_id
        self.price = price
        self.condition = condition
        self.listing_id = listing_id
        self.latitude = latitude
        self.longitude = longitude
    }
}

class Book {
    var author: String!
    var edition: String!
    var isbn: String!
    var title: String!
    
    init(author: String, edition: String, isbn: String, title: String) {
        self.author = author
        self.edition = edition
        self.isbn = isbn
        self.title = title
    }
}

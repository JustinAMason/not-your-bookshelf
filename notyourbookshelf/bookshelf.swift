//
//  bookshelf.swift
//  notyourbookshelf
//
//  Created by William Kelley on 12/5/18.
//  Copyright © 2018 nyu.edu. All rights reserved.
//

import UIKit

class bookshelf: UILabel {

    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 1)
        UIColor(named: "bookshelfBrown")!.setFill()
        path.fill()
    }

}

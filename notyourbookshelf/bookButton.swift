//
//  bookButton.swift
//  notyourbookshelf
//
//  Created by William Kelley on 12/5/18.
//  Copyright © 2018 nyu.edu. All rights reserved.
//

import UIKit

class bookButton: UIButton {
    
    var bookColors: [UIColor] = [UIColor(named: "bookOrange")!,
                                 UIColor(named: "bookRed")!,
                                 UIColor(named: "bookGreen")!,
                                 UIColor(named: "bookPurple")!]

    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 4)
        let number = Int.random(in: 0 ... 3)
        self.bookColors[number].setFill()
        path.fill()
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

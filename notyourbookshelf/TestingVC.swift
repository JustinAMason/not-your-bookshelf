//
//  TestingVC.swift
//  notyourbookshelf
//
//  Created by William Kelley on 12/19/18.
//  Copyright © 2018 nyu.edu. All rights reserved.
//

import UIKit

class TestingVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

}

extension UILabel {
    @IBInspectable
    var rotation: Int {
        get {
            return 0
        } set {
            let radians = CGFloat(CGFloat(Double.pi) * CGFloat(newValue) / CGFloat(180.0))
            self.transform = CGAffineTransform(rotationAngle: radians)
        }
    }
}

extension UIButton {
    @IBInspectable
    var rotation: Int {
        get {
            return 0
        } set {
            let radians = CGFloat(CGFloat(Double.pi) * CGFloat(newValue) / CGFloat(180.0))
            self.transform = CGAffineTransform(rotationAngle: radians)
        }
    }
    
    @IBInspectable
    var textRotation: Int {
        get {
            return 0
        } set {
            let radians = CGFloat(CGFloat(Double.pi) * CGFloat(newValue) / CGFloat(180.0))
            self.titleLabel!.transform = CGAffineTransform(rotationAngle: radians)
        }
    }
    
    @IBInspectable
    var contentTopBottomInsets: Int {
        get {
            return 0
        } set {
            let amt = CGFloat(newValue)
            self.contentEdgeInsets = UIEdgeInsets(top: amt, left: CGFloat(0), bottom: amt, right: CGFloat(0))
        }
    }
    //myButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
}

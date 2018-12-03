//
//  AddBookViewController.swift
//  NotYourBookshelf
//
//  Created by William Kelley on 12/3/18.
//  Copyright © 2018 William Kelley. All rights reserved.
//

import UIKit

class AddBookViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var PickerView: UIPickerView!
    
    var pickerData: [[String]] = [[String]]()
    var condition: [String] = ["(Physical)", "(Text)"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Connecting PickerView
        self.PickerView.delegate = self
        self.PickerView.dataSource = self
        
        // Condition Options
        pickerData = [ ["(Physical)", "New or Like New", "Lightly Used", "Heavily Used"],
                       ["(Text)", "No Markings", "Light Marking", "Heavy Marking"] ]
        
        // [FUTURE]
        // Special Condition Options -- Contributor Signature, Contributor Note, Collectible Cover Art
    }
    
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

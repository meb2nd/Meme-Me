//
//  FontPickerViewController.swift
//  Meme Me
//
//  Created by Pete Barnes on 8/28/17.
//  Copyright © 2017 Pete Barnes. All rights reserved.
//  
//  Code for this controller based on information found at the following URL:
//  http://sourcefreeze.com/ios-uipickerview-example-using-swift/
//

import UIKit



class FontPickerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    // MARK: - Outlets
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    // MARK: - Properties

    static let allowedFonts :[String:String] = [
    "Arial-Black": "Arial Black",
    "HelveticaNeue-CondensedBlack": "Helvetica Neue",
    "Impact": "Impact"]
    
    
    let pickerDataSource: [String] = Array(allowedFonts.values)
    let fontNames: [String] = Array(allowedFonts.keys)
    var selected: String {
        
        return UserDefaults.standard.string(forKey: "memeFont") ?? "Impact"
        
    }
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.pickerView.dataSource = self;
        self.pickerView.delegate = self;
        
        if let row = fontNames.index(of: selected) {
            pickerView.selectRow(row, inComponent: 0, animated: false)
        }
        
    }

    
    // MARK: UI Picker View Data Source Delegate Methods
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count;
    }
    
    
    // MARK: UI Picker View Delegate Methods
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataSource[row]
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        
        UserDefaults.standard.set(fontNames[row], forKey: "memeFont")

    }
    

    // MARK: - Actions

    
    @IBAction func dismiss(_ sender: Any) {
        // Dismiss this view controller
        self.dismiss(animated: true, completion: nil)
    }

}

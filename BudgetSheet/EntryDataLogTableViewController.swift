//
//  EntryDataLogTableViewController.swift
//  BudgetSheet
//
//  Created by Fiona O'Mahoney on 13/08/2018.
//  Copyright © 2018 Fiona O'Mahoney. All rights reserved.
//

import UIKit

class EntryDataLogTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var enteredBy: UITextField!
    @IBOutlet weak var spender: UITextField!
    @IBOutlet weak var date: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var category: UITextField!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var subcategory: UITextField!
    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var method: UITextField!
    @IBOutlet weak var note: UITextView!
    @IBOutlet weak var spenderButton: UIButton!
    @IBOutlet weak var subcategoriesPickerView: UIPickerView!
    
    var hideDatePicker = true
    var hideEnteredBy = true
    var hideSubcategories = true
    
    private var subcategories_data: [Any] = []
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Remove extra lines
        tableView.tableFooterView = UIView()
        
        tableView.keyboardDismissMode = .onDrag
        
        // Setup Data
        if let user = UserDefaults.standard.dictionary(forKey: "user"),
           let userName = user["fullName"] as? String {
            self.enteredBy.text = userName
            self.spender.text = userName
        }
        
        amount.becomeFirstResponder()
        
        copyDatePickerDate()
        
        setupSubcategories()
        
        // Keyboard Adjustments
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 11
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 1) {
            if (hideDatePicker) {
                return 0
            }
            else {
                return 120
            }
        }
        else if (indexPath.row == 5) {
            if (hideSubcategories) {
                return 0
            }
            else {
                return 120
            }
        }
        else if (indexPath.row == 10 && hideEnteredBy) {
            return 0
        }
        return 60
    }
    
    @IBAction func datePickerChanged(_ sender: Any) {
        copyDatePickerDate()
    }
    
    func setupSubcategories() {
        self.subcategoriesPickerView.delegate = self
        self.subcategoriesPickerView.dataSource = self
        if let subcategories = UserDefaults.standard.array(forKey: "subcategories") {
            self.subcategories_data = subcategories
            // Select first by default
            let rowData = subcategories_data[0] as! NSArray
            self.subcategory.text = rowData[1] as? String
        }
    }
    
    func copyDatePickerDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let strDate = dateFormatter.string(from: self.datePicker.date)
        self.date.text = strDate
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide {
            tableView.contentInset = UIEdgeInsets.zero
        } else {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        
        tableView.scrollIndicatorInsets = tableView.contentInset
    }
    
    @IBAction func dateFieldClicked(_ sender: Any) {
        hideDatePicker = !hideDatePicker
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    @IBAction func spenderClicked(_ sender: Any) {
        if (hideEnteredBy) {
            hideEnteredBy = false
            spenderButton.isUserInteractionEnabled = false
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    
    @IBAction func subcategoryClicked(_ sender: Any) {
        hideSubcategories = !hideSubcategories
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return subcategories_data.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let rowData = subcategories_data[row] as! NSArray
        return rowData[1] as? String
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let rowData = subcategories_data[row] as! NSArray
        self.subcategory.text = rowData[1] as? String
    }
    
}

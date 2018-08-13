//
//  EntryDataLogTableViewController.swift
//  BudgetSheet
//
//  Created by Fiona O'Mahoney on 13/08/2018.
//  Copyright © 2018 Fiona O'Mahoney. All rights reserved.
//

import UIKit

class EntryDataLogTableViewController: UITableViewController {

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
    
    var hideDatePicker = true
    var hideEnteredBy = true
    
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
        
        copyDatePickerDate()
        
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
        return 10
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
        else if (indexPath.row == 9 && hideEnteredBy) {
            return 0
        }
        return 60
    }
    
    @IBAction func datePickerChanged(_ sender: Any) {
        copyDatePickerDate()
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
    
}

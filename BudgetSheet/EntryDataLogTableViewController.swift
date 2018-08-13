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
    @IBOutlet weak var category: UITextField!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var subcategory: UITextField!
    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var method: UITextField!
    @IBOutlet weak var note: UITextView!
    
    override func viewWillAppear(_ animated: Bool) {

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Remove extra lines
        tableView.tableFooterView = UIView()
        
        if let user = UserDefaults.standard.dictionary(forKey: "user") {
            self.enteredBy.text = user["fullName"] as? String
        }
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
        return 9
    }
}

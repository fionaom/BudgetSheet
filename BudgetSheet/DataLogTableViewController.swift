//
//  DataLogTableViewController.swift
//  BudgetSheet
//
//  Created by Fiona O'Mahoney on 02/08/2018.
//  Copyright © 2018 Fiona O'Mahoney. All rights reserved.
//

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST.GTLRSheetsService
import GTMSessionFetcher

struct Category: Codable {
    let id: String
    let name: String
    let subcategories: [Subcategory]
}

struct Subcategory: Codable {
    let id: String
    let name: String
}

struct PaymentMethod: Codable {
    let id: String
    let name: String
}

class DataLogTableViewController: UITableViewController {
    
    static let SHEET_ID = "19loQJ9hQZMzR-z3PATC_w9RsL-0KpYyuplexSwpshyk"
    static let DATALOG = "DataLog!A:I"
    static let CATEGORIES = "Categories!A:B"
    static let SUBCATEGORIES = "Subcategories!A:C"
    static let PAYMENT_METHODS = "PayMethods!A:B"
    
    private let service = GTLRSheetsService()
    private var headers: [String] = []
    private var data: [[String]] = []
    
    private var categories_headers: [String] = []
    private var categories_data: [[String]] = []
    
    private var subcategories_headers: [String] = []
    private var subcategories_data: [[String]] = []
    
    private var payment_method_headers: [String] = []
    private var payment_method_data: [[String]] = []
    
    private var categories: [String:Category] = [:]
    private var payment_methods: [PaymentMethod] = []
    
    override func viewWillAppear(_ animated: Bool) {
        
         let loadingViewController = LoadingViewController.init(nibName:"LoadingViewController", bundle: nil)
         loadingViewController.modalPresentationStyle = .overCurrentContext
         navigationController!.present(loadingViewController, animated: false)
        
        service.authorizer = GIDSignIn.sharedInstance().currentUser.authentication.fetcherAuthorizer()
        
        if let authorizer = service.authorizer,
            let canAuth = authorizer.canAuthorize, canAuth {
            getPaymentMethods()
            getCategories()
            getSubcategories()
            openSheet()
            
            // Scroll to bottom
            tableView.setContentOffset(CGPoint(x: 0, y: CGFloat.greatestFiniteMagnitude), animated: true)
        } else {
            print("Unauthorized")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Remove extra lines
        tableView.tableFooterView = UIView()
    }
    
    func getCategories() {
        print("Getting categories sheet data...")
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet.query(withSpreadsheetId: DataLogTableViewController.SHEET_ID, range:DataLogTableViewController.CATEGORIES)
        service.executeQuery(query,
                             delegate: self,
                             didFinish: #selector(displayResultWithTicket(ticket:finishedWithObject:error:)))
    }
    
    func getSubcategories() {
        print("Getting subcategories sheet data...")
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet.query(withSpreadsheetId: DataLogTableViewController.SHEET_ID, range:DataLogTableViewController.SUBCATEGORIES)
        service.executeQuery(query,
                             delegate: self,
                             didFinish: #selector(displayResultWithTicket(ticket:finishedWithObject:error:)))
    }
    
    func getPaymentMethods() {
        print("Getting payment methods sheet data...")
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet.query(withSpreadsheetId: DataLogTableViewController.SHEET_ID, range:DataLogTableViewController.PAYMENT_METHODS)
        service.executeQuery(query,
                             delegate: self,
                             didFinish: #selector(displayResultWithTicket(ticket:finishedWithObject:error:)))
    }
    
    func openSheet() {
        print("Getting data log sheet data...")
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet.query(withSpreadsheetId: DataLogTableViewController.SHEET_ID, range:DataLogTableViewController.DATALOG)
        service.executeQuery(query,
                             delegate: self,
                             didFinish: #selector(displayResultWithTicket(ticket:finishedWithObject:error:)))
    }
    
    func sortCategories() {
        for category in categories_data {
            if let categoryId = category[0] as String? {
                var categorySubcategories: [Subcategory] = []
                for subcategory in subcategories_data {
                    if let subcategoryCategoryId = subcategory[2] as String?,
                        subcategoryCategoryId == categoryId {
                        //print("Adding \(subcategory[0]) to \(categoryId)")
                        categorySubcategories.append(Subcategory(id: subcategory[0], name: subcategory[1]))
                    }
                }
                categories[categoryId] = Category(id: categoryId, name: category[1], subcategories: categorySubcategories)
            }
        }
        //print(categories)
        UserDefaults.standard.set(codable: categories, forKey: "categories")
    }
    
    func sortPaymentMethods() {
        for paymentMethod in payment_method_data {
            if let paymentMethodId = paymentMethod[0] as String?,
               let paymentMethodName = paymentMethod[1] as String?{
                payment_methods.append(PaymentMethod(id: paymentMethodId, name: paymentMethodName))
            }
        }
        UserDefaults.standard.set(codable: payment_methods, forKey: "payment_methods")
    }
    
    @objc func displayResultWithTicket(ticket: GTLRServiceTicket,
                                       finishedWithObject result: GTLRSheets_ValueRange,
                                       error: Error?) {
        
        if let error = error {
            print("Error: " + error.localizedDescription)
            return
        }
        
        // var majorsString = ""
        let rows = result.values!
        
        if rows.isEmpty {
            print("No data found")
            return
        }
        
        if (result.range?.hasPrefix("Categories"))! {
            // Store the headers
            categories_headers = rows[0] as! [String]
            
            // Remove header row from data
            categories_data = rows as! [[String]]
            categories_data.remove(at: 0)
        }
        else if (result.range?.hasPrefix("Subcategories"))! {
            // Store the headers
            subcategories_headers = rows[0] as! [String]
            
            // Remove header row from data
            subcategories_data = rows as! [[String]]
            subcategories_data.remove(at: 0)
        }
        else if (result.range?.hasPrefix("PayMethods"))! {
            // Store the headers
            payment_method_headers = rows[0] as! [String]
            
            // Remove header row from data
            payment_method_data = rows as! [[String]]
            payment_method_data.remove(at: 0)
            
            sortPaymentMethods()
        }
        else if (result.range?.hasPrefix("DataLog"))! {
            // Store the headers
            headers = rows[0] as! [String]
            
            // Remove header row from data
            data = rows as! [[String]]
            data.remove(at: 0)
            
            tableView.reloadData()
            
            // Scroll to bottom so more recent is in view
            tableView.scrollToRow(at: IndexPath.init(row: data.count - 1, section: 0), at: .none, animated: true)
            
            dismiss(animated: false)
        }
        
        if (categories_data.count > 0 && subcategories_data.count > 0) {
            sortCategories();
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
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = indexPath.row
        let rowData = data[row]
        
       // print("Row: \(row)")
       // print("Row Data: \(rowData)")
       // print("Row Data Length: \(rowData.count)")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DataLogCell", for: indexPath) as! DataLogTableViewCell
        
        cell.amount.text = ""
        if (rowData.count > 5) {
            cell.amount.text = rowData[5]
        }
        
        cell.debitImageView.image = nil
        if (rowData.count > 6) {
            let method = rowData[6]
            if(method.caseInsensitiveCompare("debit") == ComparisonResult.orderedSame) {
                cell.debitImageView.image = UIImage.init(named: "debit")
            }
            else {
                cell.debitImageView.image = UIImage.init(named: "cash")
            }
        }
        
        cell.title.text = ""
        if (rowData.count > 7) {
            cell.title.text = rowData[7]
        }
        
        return cell
    }
}

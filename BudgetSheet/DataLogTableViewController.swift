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

class DataLogTableViewController: UITableViewController {

    static let SHEET_ID = "19loQJ9hQZMzR-z3PATC_w9RsL-0KpYyuplexSwpshyk"
    static let RANGE = "DataLog!A:I"

    private let service = GTLRSheetsService()
    private var headers: [String] = []
    private var data: [Any] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Remove extra lines
        tableView.tableFooterView = UIView()
        
        service.authorizer = GIDSignIn.sharedInstance().currentUser.authentication.fetcherAuthorizer()
    
        if let authorizer = service.authorizer,
            let canAuth = authorizer.canAuthorize, canAuth {
            openSheet()
        } else {
            print("Unauthorized")
        }
    }
    
    func openSheet() {
        print("Getting sheet data...")
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet.query(withSpreadsheetId: DataLogTableViewController.SHEET_ID, range:DataLogTableViewController.RANGE)
        service.executeQuery(query,
                             delegate: self,
                             didFinish: #selector(displayResultWithTicket(ticket:finishedWithObject:error:)))
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
        
        // Store the headers
        headers = rows[0] as! [String]
        
        // Remove header row from data
        data = rows
        data.remove(at: 0)
        
        self.tableView.reloadData()
        
      /*  majorsString += "Name, Major:\n"
        for row in rows {
            let name = row[0]
            let major = row[4]
            
            majorsString += "\(name), \(major)\n"
        }
        
        print(majorsString) */
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
        let rowData = data[row] as! NSArray
        
       // print("Row: \(row)")
       // print("Row Data: \(rowData)")
       // print("Row Data Length: \(rowData.count)")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DataLogCell", for: indexPath) as! DataLogTableViewCell
        if (rowData.count > 5) {
            cell.amount.text = rowData[5] as? String
        }
     
        if (rowData.count > 7) {
            cell.title.text = rowData[7] as? String
        }
        
        return cell
     }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

//
//  EntryViewController.swift
//  BudgetSheet
//
//  Created by Fiona O'Mahoney on 13/08/2018.
//  Copyright © 2018 Fiona O'Mahoney. All rights reserved.
//

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST.GTLRSheetsService
import GTMSessionFetcher

class EntryViewController: UIViewController {

    private let service = GTLRSheetsService()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        service.authorizer = GIDSignIn.sharedInstance().currentUser.authentication.fetcherAuthorizer()
        
        if let authorizer = service.authorizer,
            let canAuth = authorizer.canAuthorize, canAuth {
        } else {
            print("Unauthorized")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Assuming right now we only have 1 child
    @IBAction func handleSubmit(_ sender: Any) {
        
        // Show loading
        let loadingViewController = LoadingViewController.init(nibName:"LoadingViewController", bundle: nil)
        loadingViewController.modalPresentationStyle = .overCurrentContext
        navigationController!.present(loadingViewController, animated: false)
        
        let entryDataLogTableViewController = self.childViewControllers[0] as? EntryDataLogTableViewController

        let valueRange = GTLRSheets_ValueRange.init()
        let enteredBy = entryDataLogTableViewController?.enteredBy.text ?? ""
        let spender = entryDataLogTableViewController?.spender.text ?? ""
        let date = entryDataLogTableViewController?.date.text ?? ""
        let amount = entryDataLogTableViewController?.amount.text ?? ""
        let category = entryDataLogTableViewController?.category.text ?? ""
        let subcategory = entryDataLogTableViewController?.subcategory.text ?? ""
        let method = entryDataLogTableViewController?.method.text ?? ""
        let location = entryDataLogTableViewController?.location.text ?? ""
        let note = entryDataLogTableViewController?.note.text ?? ""
        let latitude = entryDataLogTableViewController?.currentLocation.latitude ?? ""
        let longitude = entryDataLogTableViewController?.currentLocation.longitude ?? ""
        
        valueRange.values = [
            [enteredBy, spender, date, category, subcategory, amount, method, location, note, "", "", "", latitude, longitude]
        ]
        
        let query = GTLRSheetsQuery_SpreadsheetsValuesAppend
            .query(withObject: valueRange, spreadsheetId:DataLogTableViewController.SHEET_ID, range:DataLogTableViewController.DATALOG)
        query.valueInputOption = "USER_ENTERED"
        service.executeQuery(query,
                             delegate: self,
                             didFinish: #selector(displayResultWithTicket(ticket:finishedWithObject:error:)))
    }
    
    @objc func displayResultWithTicket(ticket: GTLRServiceTicket,
                                       finishedWithObject result: GTLRSheets_ValueRange,
                                       error: Error?) {
        
        if let error = error {
            print("Error: \(error)")
            return
        }
        
        navigationController!.dismiss(animated: true)
        let alertController = UIAlertController(title: "Success!", message: "Data successfully logged", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }))
        
       /* let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { action in
            self.dismiss(animated: true, completion: {
                self.shouldPerformSegue(withIdentifier: "ShowDataLog", sender: self)
            })
            }
        }) */
        
        present(alertController, animated: true, completion: nil)
        
        // Success
        print(result)
    }

}

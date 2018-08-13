//
//  DataLogViewController.swift
//  BudgetSheet
//
//  Created by Fiona O'Mahoney on 13/08/2018.
//  Copyright © 2018 Fiona O'Mahoney. All rights reserved.
//

import UIKit
import GoogleSignIn

class DataLogViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

       self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(signOut))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func signOut() {
        GIDSignIn.sharedInstance().signOut()
        self.navigationController?.popToRootViewController(animated: true)
    }
}

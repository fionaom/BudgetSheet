//
//  ViewController.swift
//  BudgetSheet
//
//  Created by Fiona O'Mahoney on 02/08/2018.
//  Copyright © 2018 Fiona O'Mahoney. All rights reserved.
//

import UIKit
import GoogleSignIn

class SignInViewController: UIViewController, GIDSignInUIDelegate {

    override func viewWillAppear(_ animated: Bool) {
        let loadingViewController = LoadingViewController.init(nibName:"LoadingViewController", bundle: nil)
        loadingViewController.modalPresentationStyle = .overCurrentContext
        navigationController!.present(loadingViewController, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
       dismiss(animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


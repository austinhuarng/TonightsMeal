//
//  ViewController.swift
//  TonightsMeal
//
//  Created by austin on 4/19/22.
//

import UIKit
import Firebase

private var model = RecipesModel.shared

class ViewController: UIViewController {

    // auto login user if already logged in
    override func viewDidLoad() {
        super.viewDidLoad()
        Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            // show login
            if user == nil{
                self?.performSegue(withIdentifier: "signUpPageSegue", sender: nil)
            //show welcome
            } else{
                // set general user data
                model.userID = Auth.auth().currentUser!.uid
                model.loadData()
                self?.performSegue(withIdentifier: "alreadyLoggedInSegue", sender: nil)
            }
        }
        // Do any additional setup after loading the view.
    }


}


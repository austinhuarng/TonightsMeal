//
//  LoginViewController.swift
//  TonightsMeal
//
//  Created by austin on 4/19/22.
//

import UIKit
import Firebase

private var model = RecipesModel.shared

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(String(describing: Auth.auth().currentUser))")
        // Do any additional setup after loading the view.
    }
    
    // log in button clicked
    @IBAction func loginDidTapped(_ sender: Any) {
        let email = emailTextField.text!
        let password = passwordTextField.text!
                
        //validate empty fields
        if email.isEmpty || password.isEmpty{
            let alert = UIAlertController(title: "Empty Fields", message: "Please be sure to fill out all fields.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard self != nil else { return }
            if let error = error{
                print(error)
                // alert for invalid user (i.e. non-existent user)
                let alert = UIAlertController(title: "Invalid Inputs", message: "\(error.localizedDescription)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self!.present(alert, animated: true, completion: nil)
                return
            }
            
            if let userId = authResult?.user.uid{
                print("User has successfully signed in \(userId)")
                model.userID = userId
                model.loadData()
                self?.performSegue(withIdentifier: "loginSuccessSegue", sender: nil)
            }
        }
    }
    
    //dismiss keyboard on background click
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first

        if emailTextField.isFirstResponder && touch?.view != emailTextField {
            emailTextField.resignFirstResponder()
        }
        if passwordTextField.isFirstResponder && touch?.view != passwordTextField {
            passwordTextField.resignFirstResponder()
        }
        super.touchesBegan(touches, with: event)
    }
    
    // next field on "next" click, dismiss on "done" click
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            textField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    
    func clearFields(_ action: UIAlertAction) -> Void {
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    // sign in button clicked
    @IBAction func signUpDidTapped(_ sender: Any) {
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        //check if email is already a user
        Auth.auth().fetchSignInMethods(forEmail: email) { methods, error in
            if let error = error{
                print(error)
                return
            }
            if methods != nil{
                let alert = UIAlertController(title: "User already exists.", message: "User with email address \(email) already exists. Please login in or sign up with a different email.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: self.clearFields(_:)))
                self.present(alert, animated: true, completion: nil)
                return
            }
        }
        
        // validate empty fields
        if email.isEmpty || password.isEmpty{
            let alert = UIAlertController(title: "Empty Fields", message: "Please be sure to fill out all fields.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        // firebase call
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error{
                print(error)
                return
            }
            
            if let userId = authResult?.user.uid{
                print("User has successfully signed up \(userId)")
                model.userID = userId
                self?.performSegue(withIdentifier: "loginSuccessSegue", sender: nil)
            }
        }
    }
}

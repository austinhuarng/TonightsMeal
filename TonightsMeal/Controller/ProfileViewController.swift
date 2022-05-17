//
//  ProfileViewController.swift
//  TonightsMeal
//
//  Created by austin on 4/20/22.
//

import UIKit
import Firebase

private let reuseIdentifier = "inventoryReuseIdentifier"
private var model = RecipesModel.shared

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var inventoryTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        inventoryTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.inventory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = inventoryTableView.dequeueReusableCell(withIdentifier: "inventoryReuseIdentifier", for: indexPath)
        let item = model.inventory[indexPath.row]
        cell.textLabel?.text = item
        return cell
    }
    
    // log out button clicked, reset all local variables
    @IBAction func logOutDidTapped(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            print("trying")
            model.inventory.removeAll()
            model.recipes.removeAll()
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
        
        if Auth.auth().currentUser == nil{
            print("here")
            self.performSegue(withIdentifier: "logoutSegue", sender: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        model.loadData()
        self.inventoryTableView.reloadData()
        // Do any additional setup after loading the view.
    }

    // show alert to add new ingredient to pantry
    @IBAction func addDidTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add Ingredient", message: "Enter new ingredient item.", preferredStyle: .alert)

        alert.addTextField { (textField) in
            textField.placeholder = "Add ingredient"
        }

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            if let newItem = textField?.text{
                if newItem.isEmpty{
                    return
                }
                if model.inventory.contains(newItem){
                    return
                }
                else{
                    model.inventory.append(newItem)
                    // save to Firebase
                    model.saveData()
                    self.inventoryTableView.reloadData()
                }
            }
            else{
                return
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // edit pantry table view
    @IBAction func editDidTapped(_ sender: UIBarButtonItem) {
        
        if inventoryTableView.isEditing{
            inventoryTableView.isEditing = false
            sender.title = "Edit"
        } else{
            inventoryTableView.isEditing = true
            sender.title = "Done"
        }
    }
    
    // edit - remove item
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
            // Remove data from model
            model.inventory.remove(at: indexPath.row)
            // Remove data from Firebase
            model.saveData()
            // Animate delete action
            inventoryTableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

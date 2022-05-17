//
//  SearchViewController.swift
//  TonightsMeal
//
//  Created by austin on 4/20/22.
//

import UIKit

private var model = RecipesModel.shared

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var resultsTableView: UITableView!
    @IBOutlet weak var ignorePantrySwitch: UISwitch!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create Cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultsReuseIdentifier", for: indexPath)
        
        // Modify Cell
        let recipe = model.recipe(at: indexPath.row)
        cell.textLabel?.text = recipe?.title
         
        // Return Cell
        return cell
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // get list of recipes run on main thread
    @IBAction func getNewRecipes(_ sender: Any) {
        model.getRecipes{ images in
            DispatchQueue.main.async {
                model.recipes = images
                print(images)
                self.resultsTableView.reloadData()
            }
        }
    }
    
    // getRecipeCard endpoint run on main thread
    func getNewCard(id: Int){
        model.getRecipeCard(id: id) { card in
            DispatchQueue.main.async {
                model.currCard = card
                print(card.url)
            }
        }
    }
    
    // ibaction for ignore pantry switch
    @IBAction func ignorePantry(_ sender: Any) {
        if ignorePantrySwitch.isOn{
            model.ignorePantry = true
        } else{
            model.ignorePantry = false
        }
    }
    
    // Segue to Detail View Controller
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "RecipeDetailVC") as? DetailViewController
        let recipe = model.recipe(at: indexPath.row)
        vc?.recipe = recipe
        vc?.recipeId = recipe?.id
        print(recipe?.id as Any)
        vc?.recipeCardUrl = model.currCard?.url
        vc?.rowNum = indexPath.row
        navigationController?.pushViewController(vc!, animated: true)
    }
}

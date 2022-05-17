//
//  RecipesModel.swift
//  TonightsMeal
//
//  Created by austin on 4/20/22.
//

import Foundation
import UIKit
import Firebase

class RecipesModel : NSObject {
    private let RECIPE_COUNT: Int = 5
    private let ACCESS_KEY: String = ""
    private let BASE_URL: String = "https://api.spoonacular.com/"
    
    var recipes = [Recipe]()
    var currCard: RecipeCard? = nil
    var currSummary: RecipeSummary? = nil
    var inventory: [String] = []
    var images: [UIImage] = []
    var ignorePantry: Bool = true
    var noCard: Bool = true
    var userID: String = ""
    
    static let shared = RecipesModel()
    
    // get recipe at index
    func recipe(at index: Int) -> Recipe? {
        if index > (recipes.count - 1){
            print("Index out of bounds")
            return nil
        }
        else{
            return recipes[index]
        }
    }
    
    // load data from Firestore into "inventory" array
    // parse comma separated string into array
    func loadData(){
        let ref = Firestore.firestore().collection("users").document(userID)
        ref.getDocument { document, error in
            if let document = document, document.exists {
                let invString: String = document.data()!["inventory"] as! String
                print("inv string \(String(describing: invString))")
                let invArr = invString.split(separator: ",").map { String($0) }
                print(invArr)
                self.inventory = invArr
            } else {
                print("Document does not exist")
            }
        }
    }
    
    // save data to firebase as comma separated string
    func saveData(){
        let ref = Firestore.firestore().collection("users").document(userID)
        let invString: String = inventory.joined(separator: ",")
        print(invString)
        ref.setData([
            "inventory" : "\(invString)"
        ])
    }
    
    func getNewUrl() -> URLComponents{
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.spoonacular.com"
        components.path = "/recipes/findByIngredients"
        components.queryItems = [
            URLQueryItem(name: "ingredients", value: "\(inventory.joined(separator:",+"))"),
            URLQueryItem(name: "apiKey", value: "\(ACCESS_KEY)"),
            URLQueryItem(name: "number", value: "\(RECIPE_COUNT)"),
            URLQueryItem(name: "ignorePantry", value: "\(ignorePantry)")
        ]
        return components
    }
    
    // Get List of Recipes
    func getRecipes(onSuccess: @escaping ([Recipe]) -> Void){
        print(inventory)
        //dont show results if no inventory
        if inventory.isEmpty{
            return
        }

        let components = getNewUrl()
        
        if let url = components.url{
            var urlRequest = URLRequest(url: url)
            print("get rcupes \(url)")
            urlRequest.httpMethod = "GET"
            URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                
                if let error = error{
                    print("error code \(error.localizedDescription)")
                    exit(1)
                }
                if let data = data {
                    do{
                        let recipes = try JSONDecoder().decode([Recipe].self, from: data)
                        self.recipes = recipes
                        onSuccess(recipes)
                    } catch let error{
                        print(error)
                        exit(1)
                    }
                }
            }.resume()
        }
    }
    
    // Get image of recipe card in DetailViewController
    func getRecipeCard(id: Int, onSuccess: @escaping (RecipeCard) -> Void){
        if let url = (URL(string: "https://api.spoonacular.com/recipes/\(id)/card?apiKey=\(ACCESS_KEY)")){
            print(url)
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "GET"
            URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                
                if let error = error{
                    print("error code \(error.localizedDescription)")
                    exit(1)
                }
                if let data = data {
                    do{
                        self.noCard = false
                        print("data is \(data)")
                        let card = try JSONDecoder().decode(RecipeCard.self, from: data)
                        print("i am heree now hehehehehheehhe card is \(card.url)")
                        self.currCard = card
                        onSuccess(card)
                    } catch let error{
                        print(" RECIPE CARD ERROR \(error)")
//                        exit(1)
                    }
                }
            }.resume()
        }
    }
    
    // Get summary of recipe in DetailViewController
    func getRecipeSummary(id: Int, onSuccess: @escaping (RecipeSummary) -> Void){
        if let url = (URL(string: "https://api.spoonacular.com/recipes/\(id)/summary?apiKey=\(ACCESS_KEY)")){
            print(url)
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "GET"
            URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                
                if let error = error{
                    print("error code \(error.localizedDescription)")
                    exit(1)
                }
                if let data = data {
                    do{
                        print("data is \(data)")
                        let summary = try JSONDecoder().decode(RecipeSummary.self, from: data)
                        self.currSummary = summary
                        onSuccess(summary)
                    } catch let error{
                        print(" RECIPE SUMMARY ERROR \(error)")
                        exit(1)
                    }
                }
            }.resume()
        }
    }
    
}

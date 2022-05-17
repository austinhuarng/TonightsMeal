//
//  DetailViewController.swift
//  TonightsMeal
//
//  Created by austin on 4/21/22.
//

import UIKit
import Kingfisher

private var model = RecipesModel.shared

class DetailViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var recipeCardImageView: UIImageView!
    @IBOutlet weak var haveLabel: UILabel!
    @IBOutlet weak var needLabel: UILabel!
    
    var recipe: Recipe?
    var recipeId: Int?
    var recipeCardUrl: String?
    var card: RecipeCard?
    var rowNum: Int?
    var summaryString: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set title label
        titleLabel.text = recipe?.title
        
        // if bad endpoint, use placeholder image for recipe card
        if model.noCard{
            self.recipeCardImageView.image = UIImage(named: "Tonight's Meal-logos")
        }
        
        // call recipe card endpoint
        model.getRecipeCard(id: recipeId!) { card in
            DispatchQueue.main.async {
                model.noCard = true
                model.currCard = card
                self.card = card
                self.recipeCardUrl = card.url
                let url = URL(string: card.url)
                self.recipeCardImageView.kf.setImage(with: url)
                print(card.url)
            }
        }
        
        // call recipe summary endpoint
        model.getRecipeSummary(id: recipeId!) { summary in
            DispatchQueue.main.async {
                model.currSummary = summary
                self.summaryString = summary.summary
                
                // convert HTML string to attributed string
                let htmlText = summary.summary
                let encodedData = htmlText.data(using: String.Encoding.utf8)!
                var attributedString: NSAttributedString
                do {
                    attributedString = try NSAttributedString(data: encodedData, options: [NSAttributedString.DocumentReadingOptionKey.documentType:NSAttributedString.DocumentType.html,NSAttributedString.DocumentReadingOptionKey.characterEncoding:NSNumber(value: String.Encoding.utf8.rawValue)], documentAttributes: nil)
                    self.summaryLabel.attributedText = attributedString
                } catch let error as NSError {
                    self.summaryLabel.text = ""
                    print(error.localizedDescription)
                } catch {
                    self.summaryLabel.text = ""
                    print("error")
                }
                print(summary.summary)
            }
        }
        
        // Create numbered list of used ingredients
        let haveIngredientsArray: [missedIngredients] = recipe!.usedIngredients
        var haveArrayString: [String] = []
        for (index, item) in haveIngredientsArray.enumerated(){
            haveArrayString.append("\(index+1). \(item.original)")
        }
        let haveString: String = "\(haveArrayString.joined(separator: "\n"))"
        self.haveLabel.text = haveString
        
        // Create numbered list of unused ingredients
        let missedIngredientsArray: [missedIngredients] = recipe!.missedIngredients
        var missedArrayString: [String] = []
        for (index, item) in missedIngredientsArray.enumerated(){
            missedArrayString.append("\(index+1). \(item.original)")
        }
        let missedString: String = "\(missedArrayString.joined(separator: "\n"))"
        self.needLabel.text = missedString
    }
}

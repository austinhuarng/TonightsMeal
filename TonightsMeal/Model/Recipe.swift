//
//  Recipe.swift
//  TonightsMeal
//
//  Created by austin on 4/20/22.
//

import Foundation

struct Recipe : Decodable {
    let id: Int
    let image: String
    let missedIngredientCount: Int
    let missedIngredients: [missedIngredients]
    let title: String
    let usedIngredientCount: Int
    let usedIngredients: [missedIngredients]
    
    func getTitle()->String{
        return title
    }
}

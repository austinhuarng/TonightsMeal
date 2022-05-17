//
//  RecipeSummary.swift
//  TonightsMeal
//
//  Created by austin on 4/22/22.
//

import Foundation

struct RecipeSummary : Decodable {
    let id: Int
    let title: String
    let summary: String
}

//
//  RecipeViewModel.swift
//  Recipup
//
//  Created by Arvind Ravi on 29/08/18.
//  Copyright © 2018 Arvind Ravi. All rights reserved.
//

import Foundation

protocol RecipeItemPresentable {
  var title: String? { get }
  var thumbnail: Data? { get }
  var ingredients: String? { get }
}

protocol APIServiceProtocol {
  func fetch(url: URL) -> Decodable
}

struct RecipeItemViewModel: RecipeItemPresentable {
  var title: String?
  var thumbnail: Data?
  var ingredients: String?
}

struct RecipeViewModel {
  
  var items: [RecipeItemPresentable] = []
  var searchQuery: String?
  var isLoading: Bool = false
  
  var recipePuppyAPIService: APIServiceProtocol?
  
  init(apiService: APIServiceProtocol) {
    self.recipePuppyAPIService = apiService
  }
  
  func getRecipes(completion: @escaping () -> Void) {
    // TODO: Comm. with Networking Layer
    // - Populate Data
    // - self.items = items
    // - completion()
    
  }
}


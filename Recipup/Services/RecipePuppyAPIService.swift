//
//  RecipePuppyAPIService.swift
//  Recipup
//
//  Created by Arvind Ravi on 29/08/18.
//  Copyright © 2018 Arvind Ravi. All rights reserved.
//

import Foundation

class RecipePuppyAPIService: NSObject, APIServiceProtocol {
  
  // URLSession
  var session: URLSession = {
    return URLSession(configuration: URLSessionConfiguration())
  }()
  
  // Fetched Items
  var fetchedRecipes: [Recipe] = []
  var fetchedRecipesCompletionHandler: (Data?, URLResponse?, Error?) -> Void
  
  override init() {
    logger = OSLog
    
    fetchedRecipesCompletionHandler = { (data, response, error) in
      
      guard error != nil else {
        
      }
      
      guard let data = data else { return }
      guard response = response else { return }
      
    }
  }
  
  func fetch(url: URL) -> [Recipe] {
    let dataTask = session.dataTask(with: K.URLEndpoints.RecipeSearchEndpoint, completionHandler: <#T##(Data?, URLResponse?, Error?) -> Void#>)
  }
}

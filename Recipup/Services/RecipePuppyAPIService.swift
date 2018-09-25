//
//  RecipePuppyAPIService.swift
//  Recipup
//
//  Created by Arvind Ravi on 29/08/18.
//  Copyright © 2018 Arvind Ravi. All rights reserved.
//

import Foundation

/// RecipePuppyAPIService: Class used to interface with the Recipe Puppy API
class RecipePuppyAPIService: NSObject {
  
  // MARK: Properties
  
  // Setup
  var session: URLSession = {
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = UserDefaults.standard.sessionTimeoutDurationInSeconds
    configuration.timeoutIntervalForResource = UserDefaults.standard.sessionTimeoutDurationInSeconds
    return URLSession(configuration: configuration)
  }()
  
  // Fetched Items
  var fetchedRecipes: [Recipe] = []
  
  // Result Type
  enum Result<T> {
    case success(T)
    case error(Error?)
  }

  // MARK: - Function
  func fetch(url: URL, completion: @escaping (Result<[Recipe]?>) -> Void) {
    print("Request #: \(UUID().uuidString)")
    print("Request URL: \(url)")
    let fetchedRecipesCompletionHandler: (Data?, URLResponse?, Error?) -> Void = { (data, response, error) in
      guard let _ = response as? HTTPURLResponse else {
        completion(.error(error))
        return
      }
      
      // Unwrap data
      guard let data = data else { return }
      
      // Decode Data Object
      do {
        let decoder = JSONDecoder()
        let decodedData = try decoder.decode(Resource<[Recipe]>.self, from: data)
        completion(.success(decodedData.results))
      } catch {
        completion(.error(error))
      }
    }

    let dataTask = session.dataTask(with: url, completionHandler: fetchedRecipesCompletionHandler)
    dataTask.resume()
  }
}

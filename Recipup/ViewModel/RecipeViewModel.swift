//
//  RecipeViewModel.swift
//  Recipup
//
//  Created by Arvind Ravi on 29/08/18.
//  Copyright © 2018 Arvind Ravi. All rights reserved.
//

import Foundation


// MARK: - RecipeItemViewModel
struct RecipeItemViewModel {
  var title: String?
  var ingredients: String?
  var thumbnail: String?
  
  init(withRecipe recipe: Recipe) {
    self.title = recipe.title
    self.ingredients = recipe.ingredients
    self.thumbnail = recipe.thumbnail
  }
}


/// FetchResult: Result of a API request
///
/// - success: successful request
/// - failure: request failed
enum FetchResult {
  case success
  case failure(Error?)
}

// MARK: - RecipeViewModel
// RecipeViewModel
// This is a class rather than a struct as it communicates with the Networking Layer and has async calls that
// mutate it's properties.
class RecipeViewModel: NSObject {
  
  // MARK: - Public Interface
  var items: [RecipeItemViewModel] = []
  var searchQuery: String = "bacon"
  var isLoading: Bool = false
  
  // Retry Properties
  var retryBlock: (Bool) -> () = { _ in }
  var retryInProgress: Bool = false {
    didSet {
      DispatchQueue.main.async {
        self.retryBlock(self.retryInProgress)
      }
    }
  }
  
  // Default Values for retry mechanism
  var currentInterval: Double = 1.0
  var numberOfAttempts: Int = UserDefaults.standard.defaultNumberOfAttempts
  
  // MARK: - Datasource
  var viewModelsCount: Int {
    return items.count
  }
  
  func viewModel(at index: Int) -> RecipeItemViewModel? {
    guard index >= 0  && index < viewModelsCount else { return nil }
    return items[index]
  }
  
  // MARK: - Private Properties
  
  // Operation Queue for fetching Images
  fileprivate let operationQueue = OperationQueue()
  fileprivate var operations = [IndexPath: ImageOperation]()
  
  // API Client
  fileprivate var recipePuppyAPIService: RecipePuppyAPIService = RecipePuppyAPIService()
  
  /// Most Recent Fetch Error
  fileprivate var reasonForRequestFailure: Error?
  
  // Retry Attempt: To retry immediately before strategy
  fileprivate var isFirstRetryAttempt = true
  
  // MARK: - Public Interface
  
  /// Fetch recipes by retrying on failure based on the Exponential Backoff Algorithm
  ///
  /// - Parameter completion: Completion Block
  public func getRecipesByRetrying(completion: @escaping (_ result: FetchResult) -> Void) {
    if !isFirstRetryAttempt {
      // Cap the interval after it has grown considerably, and fail gracefully.
      if currentInterval > 10000 {
        // Reset Interval
        currentInterval = 1.0
        
        // Call Failure block
        completion(.failure(nil))
        return
      }
      
      // Exponential Backoff
      let queue = DispatchQueue(label: "recipeFetchDispatchQueue")
      
      let task = DispatchWorkItem {
        self.fetchRecipesRecursively(completion: completion)
      }
      
      // Retry after `currentInterval` seconds
      queue.asyncAfter(deadline: .now() + currentInterval, execute: task)
    } else {
      fetchRecipesRecursively(completion: completion)
    }
  }
  
  
  /// Fetch recipes by retrying on failure based on the number of retry attempts (`numberOfTimes`)
  ///
  /// - Parameters:
  ///   - numberOfTimes: Number of Retry Attempts
  ///   - completion: Completion Block
  public func getRecipesByRetrying(numberOfTimes: Int, completion: @escaping (_ result: FetchResult) -> Void) {
    print("Attempt Number: \(numberOfTimes)")
    self.numberOfAttempts = numberOfTimes
    if numberOfAttempts < 1 {
      guard let error = reasonForRequestFailure else { return }
      
      // Invalidate retry flag
      self.retryInProgress = false
      
      // Call Completion
      DispatchQueue.main.async {
        completion(.failure(error))
      }
    } else {
      fetchRecipesRecursively(numberOfTimes: numberOfTimes - 1, completion: completion)
    }
  }
  
  
  /// Returns image data downloaded asynchronously using Image Operation
  ///
  /// - Parameters:
  ///   - indexPath: indexPath of the tableview cell
  ///   - completion: completion block with image data
  public func imageForViewModel(at indexPath: IndexPath, completion: @escaping (Data?) -> ()) {
    guard let viewModel = self.viewModel(at: indexPath.row) else { return }
    if let operation = operations[indexPath] {
      guard let imageData = operation.imageData else { return }
      completion(imageData)
    } else {
      guard let urlString = viewModel.thumbnail else { return }
      guard let url = URL(string: urlString) else { return }
      let operation = ImageOperation(url: url)
      operation.completionHandler = { [weak self] (imageData) in
        guard let strongSelf = self else { return }
        completion(imageData)
        strongSelf.operations.removeValue(forKey: indexPath)
      }
      operationQueue.addOperation(operation)
      operations[indexPath] = operation
    }
  }
  
  // MARK: - Private Methods
  
  /// Fetch recursively using exponential backoff
  ///
  /// - Parameter completion: completion block with FetchResult
  private func fetchRecipesRecursively(completion: @escaping (_ result: FetchResult) -> Void) {
    isFirstRetryAttempt = false
    isLoading = true
    
    guard let url = URL(string: K.URLEndpoints.RecipeSearchEndpointString.appending(searchQuery)) else { return }
    
    recipePuppyAPIService.fetch(url: url) { result in
      switch result {
      case .success(let recipes):
        // Reset retry interval on success
        self.currentInterval = 1.0
        
        // Reset retry flag if it was a retry-request
        self.retryInProgress = false
        
        // Handle Fetched Recipes
        self.handleFetchedRecipes(recipes, completion: completion)
      case .error(let error):
        // Keep track of the most recent error
        guard let error = error as? URLError else { return }
        self.reasonForRequestFailure = error
        
        // Update current Interval to x10
        self.currentInterval = self.currentInterval * 10.0
        
        // Update Retry Flag
        self.retryInProgress = true
        
        // Retry once immediately to rule out transient error
        self.getRecipesByRetrying(completion: completion)
      }
    }
  }
  
  /// Fetch recursively using numberOfTimes strategy
  ///
  /// - Parameters:
  ///   - numberOfTimes: number of attempts
  ///   - completion: completion block with FetchResult
  private func fetchRecipesRecursively(numberOfTimes: Int, completion: @escaping (_ result: FetchResult) -> Void) {
    isFirstRetryAttempt = false
    isLoading = true
    
    guard let url = URL(string: K.URLEndpoints.RecipeSearchEndpointString.appending(searchQuery)) else { return }
    
    recipePuppyAPIService.fetch(url: url) { result in
      switch result {
      case .success(let recipes):
        // Reset Number of Attempts
        self.numberOfAttempts = 0
        
        // Reset retry flag if it was a retry-request and successful
        self.retryInProgress = false
        
        // Handle Fetched Recipes
        self.handleFetchedRecipes(recipes, completion: completion)
      case .error(let error):
        // Keep track of the most recent error
        guard let error = error as? URLError else { return }
        self.reasonForRequestFailure = error
        
        // Update Retry Flag
        self.retryInProgress = true
        
        // Retry recursively for `numberOfTimes`
        self.getRecipesByRetrying(numberOfTimes: numberOfTimes, completion: completion)
      }
    }
  }
  
  /// Handles Fetched Results and calls the completion block
  ///
  /// - Parameters:
  ///   - recipes: Recipe objects
  ///   - completion: completion block
  private func handleFetchedRecipes(_ recipes: [Recipe]?, completion: @escaping (_ result: FetchResult) -> Void) {
    guard let items = recipes else { return }
    self.items = items.map(RecipeItemViewModel.init)
    DispatchQueue.main.async {
      self.isLoading = false
      completion(.success)
    }
  }
}

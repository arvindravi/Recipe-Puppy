//
//  ViewController.swift
//  Recipup
//
//  Created by Arvind Ravi on 29/08/18.
//  Copyright © 2018 Arvind Ravi. All rights reserved.
//

import UIKit
import Reachability
import Whisper

class ViewController: UIViewController {
  
  // MARK: Properties
  var recipeViewModel: RecipeViewModel!
  var searchQuery: String = "" {
    didSet {
      recipeViewModel.searchQuery = searchQuery
    }
  }
  var isLoadingRecipes: Bool = false {
    didSet {
      if isLoadingRecipes {
        DispatchQueue.main.async {
          self.spinner.startAnimating()
        }
      } else {
        DispatchQueue.main.async {
          self.spinner.stopAnimating()
        }
      }
    }
  }
  // Reachability Object: To Check Network Status
  let reachability = Reachability()!
  
  // Dispatch Queue for fetching Recipes
  fileprivate let dispatchQueue = DispatchQueue(label: "recipeDispatchQueue")
  
  // Timer for Keeping Track of the time since last keypress
  var timer: Timer?
  
  // Use Exponential Backoff
  lazy var useExponentialBackoffStrategy: Bool = {
    return UserDefaults.standard.useExponentialBackoff
  }()
  
  // MARK: IBOutlets
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var spinner: UIActivityIndicatorView!
  
  // MARK: Lifecycle Methods
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setupReachability()
  }
  
  func setupReachability() {
    NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
    do{
      try reachability.startNotifier()
    }catch{
      print("could not start reachability notifier")
    }
  }
  
  @objc func reachabilityChanged(note: Notification) {
    let reachability = note.object as! Reachability
    switch reachability.connection {
    case .wifi:
      print("Reachable via WiFi")
      self.hideWhisper()
    case .cellular:
      print("Reachable via Cellular")
      self.hideWhisper()
    case .none:
      self.whisper(message: "No Internet Connection.", textColor: .white, backgroundColor: .red, isPermananent: true)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  func setup() {
    // View Model Setup
    recipeViewModel = RecipeViewModel()
    fetchRecipes()

    // Tableview Setup
    setupTableView()
    
    // View Controller Setup
    navigationController?.navigationBar.prefersLargeTitles = true
    title = "Recipes"
    
    // Show retry notification if any
    recipeViewModel.retryBlock = { retryInProgress in
      // Message to display
      var message = "Retry is in progress.. "
      
      // Return if retry is not in progress
      if !retryInProgress {
        self.hideMurmur()
        return
      }
      
      let numberOfAttempts = self.recipeViewModel.numberOfAttempts
      
      if !(UserDefaults.standard.useExponentialBackoff) { // Using Number of Attempts
        if (numberOfAttempts - 1) == 0 { message = "Out of retry attempts. " }
        message = message.appending("\(numberOfAttempts - 1) attempt(s) remaining.")
      } else { // Using Exponential Backoff
        message = message.appending("Next retry is in \(self.recipeViewModel.currentInterval) seconds.")
      }
      
      self.murmur(message: message)
    }
  }
  
  func setupTableView() {
    tableView.register(RecipeItemTableViewCell.self, forCellReuseIdentifier: RecipeItemTableViewCell.identifier)
    tableView.dataSource = self
    tableView.delegate = self

    let searchController = UISearchController(searchResultsController: nil)
    searchController.hidesNavigationBarDuringPresentation = false
    searchController.dimsBackgroundDuringPresentation = false
    searchController.searchBar.sizeToFit()
    searchController.searchBar.delegate = self
    navigationItem.searchController = searchController
    navigationItem.searchController?.searchBar.delegate = self
  }
  
  @objc func fetchRecipes() {
    
    // Reset Fetch Recipes Timer
    resetFetchRecipesTimer()
    
    guard recipeViewModel != nil else {
      print("View Model is nil")
      return
    }

    guard !(recipeViewModel.searchQuery.isEmpty) else {
      print("Search Query is nil")
      return
    }
    
    self.isLoadingRecipes = true
    
    // Completion Block that handles the fetch result
    let fetchCompletion: (FetchResult) -> Void = { (result) in
      switch result {
      case .success:
        self.isLoadingRecipes = false
        DispatchQueue.main.async {
          self.tableView.reloadData()
        }
      case .failure(let error):
        self.isLoadingRecipes = false
        DispatchQueue.main.async {
          self.tableView.displayError(error)
        }
      }
    }
    
    if useExponentialBackoffStrategy {
      recipeViewModel.getRecipesByRetrying(completion: fetchCompletion)
    } else {
      recipeViewModel.getRecipesByRetrying(numberOfTimes: UserDefaults.standard.defaultNumberOfAttempts, completion: fetchCompletion)
    }  
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Helper Methods
  fileprivate func resetFetchRecipesTimer() {
    if let timer = timer, timer.isValid {
      timer.invalidate()
    }
  }
  
  fileprivate func cancelPreviousFetchRequests() {
    NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(fetchRecipes), object: nil)
  }
  
  fileprivate func resetTableData() {
    recipeViewModel.items = []
    tableView.reloadData()
  }
  
  fileprivate func murmur(message: String) {
    let message = Message(title: message, textColor: .white, backgroundColor: .blue, images: nil)

    let murmur = Murmur(title: message.title)
    
    // Show and hide a message after delay
    Whisper.show(whistle: murmur, action: .show(15))
    
//    // Present a permanent status bar message
//    Whisper.show(whistle: murmur, action: .present)
//
//    // Hide a message
//    Whisper.hide(whistleAfter: 3)
  }
  
  fileprivate func hideMurmur() {
    Whisper.hide()
  }
  
  fileprivate func whisper(message: String, textColor: UIColor = .red, backgroundColor: UIColor = .white, isPermananent: Bool = false) {
    let message = Message(title: message, textColor: textColor, backgroundColor: backgroundColor, images: nil)
    
    guard let navigationController = navigationController else { return }

    var action: WhisperAction = .show
    if isPermananent {
      action = .present
    } else {
      action = .show
    }
    
    Whisper.show(whisper: message, to: navigationController, action: action)
  }
  
  fileprivate func hideWhisper() {
    Whisper.hide()
  }
}

extension ViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    // Reset Timer
    resetFetchRecipesTimer()
    
    // Cancel Previous Requests if Search Box is Empty
    guard !searchText.isEmpty else {
      cancelPreviousFetchRequests()
      return
    }
    
    // Cancel Previous Requests if Search Query Count is below "2" characters
    guard searchText.count > 2 else {
      cancelPreviousFetchRequests()
      return
    }
    
    // Scenario: If there's a fetch loading already while the user enters more text.
    //
    // Cancel Last Request, and use new query for a new request
    if isLoadingRecipes {
      cancelPreviousFetchRequests()
    }
    
    cancelPreviousFetchRequests()
    
    // Set Search Query for Fetch
    searchQuery = searchText
    
    // Reset Table Data
    resetTableData()
    
    // Wait 200ms before firing `fetchRecipes`
    timer = Timer.scheduledTimer(timeInterval: 0.2,
                                 target: self,
                                 selector: #selector(fetchRecipes),
                                 userInfo: nil,
                                 repeats: false)
  }
}

// MARK: Data Source Methods
extension ViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return recipeViewModel.viewModelsCount
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: RecipeItemTableViewCell.identifier) as? RecipeItemTableViewCell else { return UITableViewCell() }
    if let viewModel = recipeViewModel.viewModel(at: indexPath.row) {
      cell.configure(withViewModel: viewModel)
      recipeViewModel.imageForViewModel(at: indexPath) { (data) in
        guard let data = data else { return }
        cell.imageView?.image = UIImage(data: data)
      }
    }
    return cell
  }
}

extension ViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 200
  }
}

extension UITableView {
  func displayError(_ error: Error?) {
    
    var errorMessage = ""
    if let error = error {
      errorMessage = error.localizedDescription
    } else {
      errorMessage = "Unknown Error."
    }
    
    
//    switch error {
//    case URLError.networkConnectionLost, URLError.notConnectedToInternet:
//      errorMessage = "No Internet"
//    case URLError.cannotFindHost, URLError.cannotFindHost:
//      errorMessage = "Cannot find host. Failed after retrying."
//    case URLError.timedOut:
//      errorMessage =
//    default:
//      errorMessage = "Unknown Error. \(error.localizedDescription)"
//    }
    
    // TODO: Make Errors Useful
    
    let errorLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height))
    errorLabel.text = errorMessage
    errorLabel.textColor  = UIColor.red
    errorLabel.textAlignment = .center
    backgroundView = errorLabel
    separatorStyle = .none
    setNeedsDisplay()
  }
  
  func displayMessage(_ message: String) {
    let messageLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height))
    messageLabel.text = message
    messageLabel.textColor  = UIColor.blue
    messageLabel.textAlignment = .center
    backgroundView = messageLabel
    separatorStyle = .none
    setNeedsDisplay()
  }
}


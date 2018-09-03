//
//  RecipeItemTableViewCell.swift
//  Recipup
//
//  Created by Arvind Ravi on 29/08/18.
//  Copyright © 2018 Arvind Ravi. All rights reserved.
//

import UIKit

class RecipeItemTableViewCell: UITableViewCell {
  
  var imageData: Data?
  
  static let identifier = "RecipeCell"
    
  override func prepareForReuse() {
    super.prepareForReuse()
    imageView?.image = #imageLiteral(resourceName: "Placeholder")
    textLabel?.text = ""
  }
  
  override func layoutSubviews() {
    imageView?.image = #imageLiteral(resourceName: "Placeholder")
    super.layoutSubviews()
  }
  
  
  /// This function is used to configure the cell using the View Model.
  ///
  /// - Parameter viewModel: Recipe View Model which conforms to RecipeItemPresentable
  func configure(withViewModel viewModel: RecipeItemViewModel) {
    selectionStyle = .none
    guard let title = viewModel.title else { return }
    self.textLabel?.text = title
  }
}

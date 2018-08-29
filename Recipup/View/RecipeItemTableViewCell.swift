//
//  RecipeItemTableViewCell.swift
//  Recipup
//
//  Created by Arvind Ravi on 29/08/18.
//  Copyright © 2018 Arvind Ravi. All rights reserved.
//

import UIKit

class RecipeItemTableViewCell: UITableViewCell {
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  
  /// This function is used to configure the cell using the View Model.
  ///
  /// - Parameter viewModel: Recipe View Model which conforms to RecipeItemPresentable
  func configure(withViewModel viewModel: RecipeItemPresentable) {
    self.textLabel?.text = viewModel.title
  }
}

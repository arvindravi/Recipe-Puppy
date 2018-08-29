//
//  Recipe.swift
//  Recipup
//
//  Created by Arvind Ravi on 29/08/18.
//  Copyright © 2018 Arvind Ravi. All rights reserved.
//

import Foundation

struct Recipe: Decodable {
  let title: String?
  let ingredients: String?
  var thumbnail: String?  
}

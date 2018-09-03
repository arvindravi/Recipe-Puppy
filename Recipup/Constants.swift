//
//  Constants.swift
//  Recipup
//
//  Created by Arvind Ravi on 29/08/18.
//  Copyright © 2018 Arvind Ravi. All rights reserved.
//

import Foundation

struct K {
  struct URLEndpoints {
    static let RecipeSearchEndpointString = "http://www.recipepuppy.com/api/?q="
  }
  static let DefaultNumberOfAttempts: Int = 3
  static let DefaultTimeoutCapForExponentialBackoffInSeconds: Double = 10000
  static let SessionTimeoutDurationInSeconds: Double = 10
  
  static let UseExponentialBackoffAsTheRetryStrategy: Bool = false
}

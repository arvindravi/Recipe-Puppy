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
  
  // Default Number of Attempts for the Retry Strategy
  static let DefaultNumberOfAttempts: Int = 3
  
  // To use Exponential Backoff or Not
  static let UseExponentialBackoffAsTheRetryStrategy: Bool = false
  
  // Cap time out after 10000 seconds if its not successful when using Exponential Backoff
  static let DefaultTimeoutCapForExponentialBackoffInSeconds: Double = 10000
  
  // Session Timeout Duration, (default is 60)
  static let SessionTimeoutDurationInSeconds: Double = 15
}

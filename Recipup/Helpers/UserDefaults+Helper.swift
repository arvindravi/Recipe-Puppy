//
//  Errors.swift
//  Recipup
//
//  Created by Arvind Ravi on 29/08/18.
//  Copyright © 2018 Arvind Ravi. All rights reserved.
//

import Foundation

extension UserDefaults {
  static let applicationDefaults: [String: Any] = [
    "DefaultNumberOfAttempts": K.DefaultNumberOfAttempts,
    "DefaultTimeoutCapForExponentialBackoffInSeconds": K.DefaultTimeoutCapForExponentialBackoffInSeconds,
    "SessionTimeoutDurationInSeconds": K.SessionTimeoutDurationInSeconds,
    "UseExponentialBackoff": K.UseExponentialBackoffAsTheRetryStrategy
  ]
  
  var defaultNumberOfAttempts: Int {
    get { return integer(forKey: "DefaultNumberOfAttempts") }
    set { set(newValue, forKey: "DefaultNumberOfAttempts") }
  }
  
  var defaultTimeOutCapForExponentialBackoffInSeconds: Double {
    get { return double(forKey: "DefaultTimeoutCapForExponentialBackoffInSeconds") }
    set { set(newValue, forKey: "DefaultTimeoutCapForExponentialBackoffInSeconds") }
  }
  
  var sessionTimeoutDurationInSeconds: Double {
    get { return double(forKey: "SessionTimeoutDurationInSeconds") }
    set { set(newValue, forKey: "SessionTimeoutDurationInSeconds") }
  }
  
  var useExponentialBackoff: Bool {
    get { return bool(forKey: "UseExponentialBackoff") }
    set { set(newValue, forKey: "UseExponentialBackoff") }
  }
}

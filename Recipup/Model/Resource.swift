//
//  Resource.swift
//  Recipup
//
//  Created by Arvind Ravi on 29/08/18.
//  Copyright © 2018 Arvind Ravi. All rights reserved.
//

import Foundation

// To mirror the root of the API response
struct Resource<T: Decodable>: Decodable {
  let title: String?
  let version: Float?
  let href: String
  let results: T?
}


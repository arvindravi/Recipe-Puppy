//
//  String+Util.swift
//  Recipup
//
//  Created by Arvind Ravi on 03/09/18.
//  Copyright © 2018 Arvind Ravi. All rights reserved.
//

import Foundation

extension String {
  var stringByAddingPercentEncoding: String {
    let allowed = CharacterSet.alphanumerics
    return self.addingPercentEncoding(withAllowedCharacters: allowed)!
  }
}

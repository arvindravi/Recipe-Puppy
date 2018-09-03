//
//  ImageOperation.swift
//  Recipup
//
//  Created by Arvind Ravi on 29/08/18.
//  Copyright © 2018 Arvind Ravi. All rights reserved.
//

import Foundation

typealias ImageOperationCompletionHandlerType = ((Data) -> ())?

/// The Image Operation class is an Operation which is responsible for downloading images from a URL and saves the image data to `imageData` on completion
class ImageOperation: Operation {
  var url: URL
  var completionHandler: ImageOperationCompletionHandlerType
  var imageData: Data?
  
  init(url: URL) {
    self.url = url
  }
  
  // This method is called when an instance of this operation is added to a operation queue
  override func main() {
    guard !isCancelled else { return }
    URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
      guard error == nil else { return }
      
      guard let strongSelf = self,
        !strongSelf.isCancelled,
        let data = data else { return }
      
      strongSelf.imageData = data
      DispatchQueue.main.async {
        strongSelf.completionHandler?(data)
      }
    }.resume()
  }
}

//
//  CachedImageView.swift
//  WeatherApp
//
//  Created by Magfurul Abeer on 10/12/17.
//  Copyright © 2017 Magfurul Abeer. All rights reserved.
//

import UIKit

class CachedImageView: UIImageView {

    let cache = NSCache<NSString, UIImage>()
    
    func setImage(url: URL) {
        let urlString = url.absoluteString as NSString
        
        if let cachedImage = cache.object(forKey: urlString) {
            image = cachedImage
        } else {
            DispatchQueue.main.async {
                URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                    
                    guard let strongSelf = self else { return }
                    
                    guard error != nil,
                        let data = data,
                        let downloadedImage = UIImage(data: data) else {
                        // TODO: Handle this in future.
                        // I decided not to handle this as that approach depends on what's expected from the app
                        // Can be separated in separate guard statements for more precise error handling
                        return
                    }
                    
                    strongSelf.cache.setObject(downloadedImage, forKey: urlString)
                    OperationQueue.main.addOperation {
                        strongSelf.image = downloadedImage
                    }
                }.resume()
            }
        }
    }
}

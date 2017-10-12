//
//  UnsplashService.swift
//  WeatherApp
//
//  Created by Magfurul Abeer on 10/12/17.
//  Copyright © 2017 Magfurul Abeer. All rights reserved.
//

import Foundation

//enum DataError: Error {
//    case invalidUrl
//    case missingData
//}

struct UnsplashService {
    func retrieveRandomImage(query: String, _ completionHandler: @escaping (Weather?, Error?) -> Void) {
        
        guard let url = generateUrl(params: ["query": query]) else {
            completionHandler(nil, DataError.invalidUrl)
            return
        }
        
        URLSession(configuration: .default).dataTask(with: url) { data, response, error in
            
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            
            guard let data = data else {
                completionHandler(nil, DataError.missingData)
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                let weather = try Weather(data: json ?? [:])
                completionHandler(weather, nil)
            } catch let e {
                completionHandler(nil, e)
            }
            
            return
            }.resume()
    }
    
    func generateUrl(params: [String: String] = [:]) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.unsplash.com/"
        components.path = "/photos/random"
        components.queryItems = params.map { URLQueryItem(name: $0, value: $1) }
        components.queryItems?.append(URLQueryItem(name: "client_id", value: Constants.openWeatherAppId))
        return components.url
    }
}

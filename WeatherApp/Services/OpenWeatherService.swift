//
//  OpenWeatherService.swift
//  WeatherApp
//
//  Created by Magfurul Abeer on 10/12/17.
//  Copyright © 2017 Magfurul Abeer. All rights reserved.
//

import Foundation

enum DataError: Error {
    case invalidUrl
    case missingData
}


// Normally I would abstract the networking layer to something similar to Moya
struct OpenWeatherService {    
    public func retrieveWeather(query: String, _ completionHandler: @escaping (Weather?, Error?) -> Void) {
        
        guard let url = generateUrl(params: ["q": query]) else {
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
    
    private func urlComponents() -> URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.openweathermap.org"
        return components
    }
    
    private func generateUrl(params: [String: String] = [:]) -> URL? {
        var components = self.urlComponents()
        components.path = "/data/2.5/weather"
        components.queryItems = params.map { URLQueryItem(name: $0, value: $1) }
        components.queryItems?.append(URLQueryItem(name: "APPID", value: Constants.openWeatherAppId))
        return components.url
    }
    
    public func iconUrl(icon: String) -> URL? {
        var components = self.urlComponents()
        components.path = "img/w/\(icon)"
        print(components.path)
        return URL(string: "https://api.openweathermap.org/img/w/03d")
        return components.url
    }
}

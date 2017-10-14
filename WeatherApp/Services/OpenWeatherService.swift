//
//  OpenWeatherService.swift
//  WeatherApp
//
//  Created by Magfurul Abeer on 10/12/17.
//  Copyright © 2017 Magfurul Abeer. All rights reserved.
//

import UIKit

enum DataError: Error {
    case invalidUrl
    case missingData
}

typealias CompletionHandler = ((Weather?, Error?) -> Void)

// Normally I would abstract the networking layer to something similar to Moya but it seemed severely unnecessarily for the scope of this project
struct OpenWeatherService {    
    public func retrieveWeather(query: String, _ completionHandler: @escaping CompletionHandler) {
        
        guard let url = generateUrl(params: ["q": query]) else {
            completionHandler(nil, DataError.invalidUrl)
            return
        }
        
        requestLocation(url: url, completionHandler)
    }
    
    public func retrieveWeather(latitude: Double, longitude: Double, _ completionHandler: @escaping CompletionHandler) {
        
        let params = ["lat": "\(latitude)", "lon": "\(longitude)"]
        guard let url = generateUrl(params: params) else {
            completionHandler(nil, DataError.invalidUrl)
            return
        }
        
        requestLocation(url: url, completionHandler)
    }
    
    private func requestLocation(url: URL, _ completionHandler: @escaping CompletionHandler) {
        URLSession(configuration: .default).dataTask(with: url) { data, response, error in
            
            if let error = error {
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
        components.path = "/img/w/\(icon)"
        return components.url
    }
}

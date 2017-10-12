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

struct OpenWeatherService {
    let scheme = "https"
    let host = "api.openweathermap.org"
    
    enum Endpoint {
        case retrieveWeather(String)
        case retrieveIcon(String)
        
        // Normally I would differentiate the HTTP Methods but for the scope of this project, it's safe to assume it's always GET
        // public var method
        
        public var path: String {
            switch self {
            case .retrieveWeather:
                return "/data/2.5/weather"
            case .retrieveIcon(let icon):
                return "/img/w/\(icon)"
            }
        }
        
        public var parameters: [String: Any] {
            switch self {
            case .retrieveWeather(let query):
                return ["APPID": Constants.openWeatherAppId, "q": query]
            case .retrieveIcon(_):
                return [:]
            }
        }
    }
    
    func request(endpoint: Endpoint, _ completionHandler: @escaping (AnyObject?, Error?) -> Void) {
        guard let url = generateUrl(path: endpoint.path, params: endpoint.parameters) else {
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
            
            completionHandler
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
    
    func generateUrl(path: String, params: [String: Any] = [:]) -> URL? {
        var components = URLComponents()
        components.scheme = self.scheme
        components.host = self.host
        components.path = path
        components.queryItems = params.map { URLQueryItem(name: $0, value: $1 as? String) }
        return components.url
    }
}

//
//  Weather.swift
//  WeatherApp
//
//  Created by Magfurul Abeer on 10/12/17.
//  Copyright © 2017 Magfurul Abeer. All rights reserved.
//

import Foundation

enum ParsingError: Error {
    case missingAttribute
}

struct Weather {
    let name: String
    let temperature: Double
    let humidity: Int
    let pressure: Int
    let description: String
    let icon: String
    
    public init(data: [String: Any]) throws {
        guard let weatherArray = data["weather"] as? [[String: Any]],
            let weather = weatherArray.first,
            let main = data["main"] as? [String: Any] else {
                throw ParsingError.missingAttribute
        }
        
        

        guard let name = data["name"] as? String,
            let temperature = main["temp"] as? Double,
            let humidity = main["humidity"] as? Int,
            let pressure = main["pressure"] as? Int,
            let description = weather["description"] as? String,
            let icon = weather["icon"] as? String else {
                throw ParsingError.missingAttribute
        }

        self.name = name
        self.temperature = temperature
        self.humidity = humidity
        self.pressure = pressure
        self.description = description
        self.icon = icon
    }
}

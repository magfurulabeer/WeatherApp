//
//  WeatherViewController.swift
//  WeatherApp
//
//  Created by Magfurul Abeer on 10/12/17.
//  Copyright © 2017 Magfurul Abeer. All rights reserved.
//

import UIKit

class WeatherViewController: UIViewController {

    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var iconImageView: CachedImageView!
    
    var weather: Weather? {
        didSet {
            self.displayWeather()
        }
    }
    
    let openWeatherService = OpenWeatherService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        weather = nil // TODO: Set it to last weather
        locationTextField.delegate = self
    }
    
    func displayWeather() {
        OperationQueue.main.addOperation { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.locationTextField.text = strongSelf.weather?.name ?? "Error"
            strongSelf.temperatureLabel.text = strongSelf.weather != nil ? "\(strongSelf.weather!.temperature)° C" : "😱"
            if let weather = strongSelf.weather {
                let iconUrl = strongSelf.openWeatherService.iconUrl(icon: weather.icon)
                strongSelf.iconImageView.setImage(url: iconUrl!)
            }
        }
    }
}

extension WeatherViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let query = textField.text ?? ""
        openWeatherService.retrieveWeather(query: query) { [weak self] weather, error in
            guard let strongSelf = self else { return }
            
            guard error == nil else {
                strongSelf.alert(error!)
                return
            }
            
            // If it's nil, it will display the error messages
            strongSelf.weather = weather
        }

        locationTextField.resignFirstResponder()
        return true
    }
}

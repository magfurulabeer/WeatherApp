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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        weather = nil // TODO: Set it to last weather
        locationTextField.delegate = self
    }
    
    func displayWeather() {
        OperationQueue.main.addOperation { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.locationTextField.text = strongSelf.weather?.name ?? "Error"
            strongSelf.temperatureLabel.text = strongSelf.weather != nil ? "\(strongSelf.weather!.temperature)° C" : "😱"
            strongSelf.iconImageView.setImage(url: <#T##URL#>)
        }
    }
}

extension WeatherViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let query = textField.text ?? ""
        OpenWeatherService().retrieveWeather(query: query) { [weak self] weather, error in
            guard error == nil else {
                self?.alert(error!)
                return
            }
            
            self?.weather = weather
        }

        locationTextField.resignFirstResponder()
        return true
    }
}

//
//  WeatherViewController.swift
//  WeatherApp
//
//  Created by Magfurul Abeer on 10/12/17.
//  Copyright © 2017 Magfurul Abeer. All rights reserved.
//

import UIKit
import CoreLocation

// MARK: Properties and Lifecycle Methods
class WeatherViewController: UIViewController {

    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var iconImageView: CachedImageView!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    let openWeatherService = OpenWeatherService()
    let locationManager = CLLocationManager()
    
    var weather: Weather? {
        didSet {
            self.displayWeather()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        view.addGestureRecognizer(tap)
        
        configureLocationTextField()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func handler() -> CompletionHandler {

        let completion: CompletionHandler = { [weak self] weather, error in
            guard let strongSelf = self else { return }
            
            print("Searched!") // Sanity check to make sure refresh it working
            if let error = error {
                strongSelf.alert(error)
                return
            }
            
            // If it's nil, it will display the error messages
            strongSelf.weather = weather
        }
        
        return completion
    }
    
    func search(query: String?) {
        if let query = query {
            UserDefaults.standard.set(true, forKey: Constants.lastSearchedWasQueryKey)
            UserDefaults.standard.set(query, forKey: Constants.lastSearchedKey)
            openWeatherService.retrieveWeather(query: query, handler())
        }
    }
    
    func search(lat: Double, lon: Double) {
        UserDefaults.standard.set(false, forKey: Constants.lastSearchedWasQueryKey)
        openWeatherService.retrieveWeather(latitude: lat, longitude: lon, handler())
    }
    
}

// MARK: Display and Configuration Methods
extension WeatherViewController {
    func displayWeather() {
        OperationQueue.main.addOperation { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.locationTextField.text = strongSelf.weather?.name ?? "Error"
            /*
             Normally I would focus on the ability to change from K, C, and F
             Either by switching the url params according to OpenWeather API (preferred)
             Or by actually doing the math in the app to convert it (not preferred)
             Ideally, it would do the first when there's online access and the second when there isn't
             */
            // TODO: Add ability to change from K to C to F
            // TODO: Refactor this all
            strongSelf.temperatureLabel.text = strongSelf.weather != nil ? "\(strongSelf.weather!.temperature)° K" : "😱"
            strongSelf.humidityLabel.text = strongSelf.weather != nil ? "\(strongSelf.weather!.humidity)%" : "n/a"
            strongSelf.pressureLabel.text = strongSelf.weather != nil ? "\(strongSelf.weather!.pressure)in" : "n/a"
            strongSelf.descriptionLabel.text = strongSelf.weather?.description.capitalized ?? ""
            if let weather = strongSelf.weather {
                let iconUrl = strongSelf.openWeatherService.iconUrl(icon: weather.icon)
                strongSelf.iconImageView.setImage(url: iconUrl!)
            }
        }
    }
    
    func configureLocationTextField() {
        locationTextField.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        locationTextField.text = UserDefaults.standard.string(forKey: Constants.lastSearchedKey)
        locationTextField.delegate = self
    }
}

// MARK: UITextFieldDelegate Methods
extension WeatherViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        search(query: textField.text)
        locationTextField.resignFirstResponder()
        return true
    }
}

// MARK: IBActions
extension WeatherViewController {
    @IBAction func pinButtonTapped(_ sender: UIButton) {
        locationManager.requestLocation()
    }
    
    @IBAction func refreshButtonTapped(_ sender: UIButton) {
        // Using last saved query rather than what is currently in the textfield because of the following
        // If you type 'gggg', it searches 'Miesbach", if you backspace until it becomes "Mie" and then
        // press the refresh button, it should refresh 'Miesbach' and not 'Mie' which are considered
        // different areas according to OpenWeather
        let wasQuery = UserDefaults.standard.bool(forKey: Constants.lastSearchedWasQueryKey)
        
        if wasQuery {
            let lastQuery = UserDefaults.standard.string(forKey: Constants.lastSearchedKey)
            search(query: lastQuery)
        } else {
            pinButtonTapped(sender)
        }
    }
    
    /*
     I did not have time to implement the history modal. The idea was to save
     all weather data to CoreData (and Realm in the Rx project) and list them
     in a History modal. From there you can either clear all saved data or close
     the modal.
    */
    @IBAction func historyButtonTapped(_ sender: UIButton) {
        self.alert("This was not implemented yet due to time constraints!")
    }
}

// MARK: CLLocationManagerDelegate Methods
extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else {
            self.alert("Could not get location!")
            return
        }
        
        let lat = loc.coordinate.latitude
        let lon = loc.coordinate.longitude
        
        search(lat: lat, lon: lon)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.alert(error)
    }
}




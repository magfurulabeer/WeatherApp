//
//  UIViewController+Extensions.swift
//  WeatherApp
//
//  Created by Magfurul Abeer on 10/12/17.
//  Copyright © 2017 Magfurul Abeer. All rights reserved.
//

import UIKit

extension UIViewController {
    func alert(_ err: Error) {
        OperationQueue.main.addOperation { [weak self] in
            let alert = UIAlertController(title: "Error", message: err.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
            let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(ok)
            self?.present(alert, animated: true, completion: nil)
        }
    }
}

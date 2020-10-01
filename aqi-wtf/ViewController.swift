//
//  ViewController.swift
//  aqi-wtf
//
//  Created by Kyle Bashour on 10/1/20.
//

import UIKit

class ViewController: UIViewController {

    let loader = AQILoader()

    override func viewDidLoad() {
        super.viewDidLoad()

        loader.loadClosestAQI { result in
            switch result {
            case .success(let value):
                print(value)
            case .failure(let error):
                print(error)
            }
        }
    }
}

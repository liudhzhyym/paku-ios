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

        loader.loadSensors { result in
            switch result {
            case .success(let sensors):
                print(sensors.count)
                print(sensors[0])
            case .failure(let error):
                print(error)
            }
        }
    }
}

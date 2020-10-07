//
//  RootViewController.swift
//  Paku
//
//  Created by Kyle Bashour on 10/1/20.
//

import UIKit

class RootViewController: ViewController {

    var viewController: UIViewController? {
        didSet {
            oldValue?.removeFromParent()
            viewController.flatMap { add($0) }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        LocationManager.shared.$status.sink { status in
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                self.viewController = AQIViewController()
            default:
                self.viewController = OnboardingViewController()
            }
        }.store(in: &sink)
    }
}

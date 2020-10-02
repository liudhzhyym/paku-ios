//
//  RootViewController.swift
//  aqi-wtf
//
//  Created by Kyle Bashour on 10/1/20.
//

import UIKit
import SwiftLocation

class RootViewController: UIViewController {

    var viewController: UIViewController? {
        didSet {
            oldValue?.removeFromParent()
            viewController.flatMap { add($0) }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        LocationManager.shared.onAuthorizationChange.add { state in
            switch state {
            case .available:
                self.viewController = AQIViewController()
            default:
                self.viewController = OnboardingViewController()
            }
        }
    }
}

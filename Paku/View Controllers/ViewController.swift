//
//  ViewController.swift
//  Paku
//
//  Created by Kyle Bashour on 10/6/20.
//

import Combine
import UIKit

class ViewController: UIViewController {

    var sink: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
    }
}

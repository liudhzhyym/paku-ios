//
//  OnboardingViewController.swift
//  Paku
//
//  Created by Kyle Bashour on 10/1/20.
//

import UIKit

class OnboardingViewController: ViewController {

    private let permissionWrapper = UIView()
    private let locationButton = Button(title: "Let’s do it")
    private let settingsButton = Button(title: "Open Settings")

    private var token: UInt64?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.layoutMargins.left = 30
        view.layoutMargins.right = 30
        view.layoutMargins.bottom = 20
        view.backgroundColor = .systemBackground

        let icon = UIImageView(image: #imageLiteral(resourceName: "in-app-icon"))

        let titleLabel = UILabel(font: .systemFont(ofSize: 38, weight: .bold))
        titleLabel.text = "Welcome to Paku"
        titleLabel.numberOfLines = 0

        let descriptionLabel = UILabel(font: .systemFont(ofSize: 17), color: .secondaryLabel)
        descriptionLabel.text = "Paku is a simple app (and widget!) that shows you the AQI from the nearest Purple Air sensor. We need your location to do that - is that alright?"
        descriptionLabel.numberOfLines = 0

        let permissionLabel = UILabel(font: .systemFont(ofSize: 14), color: .secondaryLabel, alignment: .center)
        permissionLabel.text = "Sorry, but we need your location to show you AQI near you! Open settings to grant us permission."
        permissionLabel.numberOfLines = 0

        permissionWrapper.addSubview(permissionLabel)
        permissionLabel.pinEdges([.top, .bottom], to: permissionWrapper)
        permissionLabel.pinCenter(to: permissionWrapper)

        let topSpacer = UIView()
        let bottomSpacer = UIView()

        let stackView = UIStackView(arrangedSubviews: [topSpacer, icon, titleLabel, descriptionLabel, bottomSpacer, locationButton, settingsButton, permissionWrapper])
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.spacing = 16

        view.addSubview(stackView)

        stackView.pinEdges(to: view.layoutMarginsGuide)
        settingsButton.widthAnchor.pin(to: stackView.widthAnchor)
        locationButton.widthAnchor.pin(to: stackView.widthAnchor)
        topSpacer.heightAnchor.pin(to: bottomSpacer.heightAnchor)

        permissionWrapper.widthAnchor.pin(to: stackView.widthAnchor)
        permissionLabel.widthAnchor.pin(lessThan: stackView.widthAnchor, constant: -60)

        locationButton.addTarget(self, action: #selector(self.requestionLocationPermission), for: .touchUpInside)
        settingsButton.addTarget(self, action: #selector(self.openSettings), for: .touchUpInside)

        updateState()

        LocationManager.shared.$status.sink { [weak self] _ in
            self?.updateState()
        }.store(in: &sink)
    }

    private func updateState() {
        switch LocationManager.shared.status {
        case .denied, .restricted:
            permissionWrapper.isHidden = false
            self.settingsButton.isHidden = false
            self.locationButton.isHidden = true
        default:
            permissionWrapper.isHidden = true
            self.settingsButton.isHidden = true
            self.locationButton.isHidden = false
        }
    }

    @objc private func requestionLocationPermission() {
        LocationManager.shared.requestPermission()
    }

    @objc private func openSettings() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    }
}

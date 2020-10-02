//
//  OnboardingViewController.swift
//  aqi-wtf
//
//  Created by Kyle Bashour on 10/1/20.
//

import UIKit
import SwiftLocation

class OnboardingViewController: UIViewController {

    private let button = Button(title: "Let’s do it")

    override func viewDidLoad() {
        super.viewDidLoad()

        view.layoutMargins.bottom = 20
        view.backgroundColor = .systemBackground

        let icon = UIImageView(image: #imageLiteral(resourceName: "in-app-icon"))

        let titleLabel = UILabel(font: .systemFont(ofSize: 38, weight: .bold))
        let welcome = NSAttributedString(string: "Welcome to ")
        let paku = NSAttributedString(string: "Paku", attributes: [.foregroundColor: UIColor.customPurple])
        titleLabel.attributedText = welcome + paku
        titleLabel.numberOfLines = 0

        let descriptionLabel = UILabel(font: .systemFont(ofSize: 17), color: .secondaryLabel)
        descriptionLabel.text = "Paku is a simple app (and widget!) that shows you the AQI from the nearest Purple Air sensor. We need your location to do that - is that alright?"
        descriptionLabel.numberOfLines = 0

        let disclaimerLabel = UILabel(font: .systemFont(ofSize: 14), color: .secondaryLabel, alignment: .center)
        disclaimerLabel.text = "By signing up you agree to our Terms of Service"
        disclaimerLabel.numberOfLines = 0

        let disclaimerWrapper = UIView()
        disclaimerWrapper.addSubview(disclaimerLabel)
        disclaimerLabel.pinEdges([.top, .bottom], to: disclaimerWrapper)
        disclaimerLabel.pinCenter(to: disclaimerWrapper)

        button.addTarget(self, action: #selector(signIn), for: .touchUpInside)

        let topSpacer = UIView()
        let bottomSpacer = UIView()

        let stackView = UIStackView(arrangedSubviews: [topSpacer, icon, titleLabel, descriptionLabel, bottomSpacer, button])
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.spacing = 16

        view.addSubview(stackView)

        stackView.pinEdges(to: view.layoutMarginsGuide)
        button.widthAnchor.pin(to: stackView.widthAnchor)
        topSpacer.heightAnchor.pin(to: bottomSpacer.heightAnchor)
    }

    @objc private func signIn() {
        LocationManager.shared.requireUserAuthorization(.whenInUse)
    }

    private func set(isLoading: Bool) {
        button.isLoading = isLoading
        button.isEnabled = !isLoading
    }
}

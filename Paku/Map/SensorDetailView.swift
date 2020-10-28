//
//  SensorDetailView.swift
//  Paku
//
//  Created by Kyle Bashour on 10/24/20.
//

import UIKit
import ScreenCorners

class SensorDetailView: UIView {

    private let titleLabel = UILabel(font: .systemFont(ofSize: 24, weight: .medium))
    private let descriptionLabel = UILabel(font: .systemFont(ofSize: 17, weight: .regular), color: .secondaryLabel)
    private let button = Button(title: "Favorite")

    init(sensor: Sensor) {
        super.init(frame: .zero)

        titleLabel.text = sensor.info.label
        descriptionLabel.text = "Current air quality is satisfactory, and air pollution poses little or no risk."

        descriptionLabel.numberOfLines = 0

        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            descriptionLabel,
            button,
        ])

        addSubview(stackView)
        stackView.pinEdges(to: safeAreaLayoutGuide, insets: .init(vertical: 20, horizontal: 20))
        stackView.axis = .vertical
        stackView.spacing = 20
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

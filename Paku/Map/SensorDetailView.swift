//
//  SensorDetailView.swift
//  Paku
//
//  Created by Kyle Bashour on 10/24/20.
//

import UIKit

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "E, MMM d, h:mm a"
    return formatter
}()

class SensorDetailView: UIView {

    private let titleLabel = UILabel(font: .systemFont(ofSize: 24, weight: .medium))
    private let detailLabel = UILabel(font: .systemFont(ofSize: 16, weight: .medium), color: .secondaryLabel)
    private let button = UIButton(type: .system)

    init(sensor: Sensor, open: @escaping (Sensor) -> Void) {
        super.init(frame: .zero)

        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.setTitle("Open in PurpleAir.com →", for: .normal)
        button.addAction(.init { _ in open(sensor) }, for: .touchUpInside)

        titleLabel.text = sensor.info.label.localizedCapitalized
        titleLabel.numberOfLines = 0

        let location = sensor.info.isOutdoor ? "Outside" : "Inside"
        let date = dateFormatter.string(from: sensor.age)

        detailLabel.text = "Real time AQI: \(Int(sensor.aqiValue())) (\(location))\non \(date)"
        detailLabel.numberOfLines = 0

        let guidance = sensor.aqiCategory().guidance.map { guidance -> UIView in
            let title = UILabel(font: .systemFont(ofSize: 13, weight: .bold))
            title.numberOfLines = 0
            title.text = guidance.title.localizedUppercase

            let body = UILabel(font: .systemFont(ofSize: 16))
            body.numberOfLines = 0
            body.text = guidance.body

            let stack = UIStackView(arrangedSubviews: [title, body])
            stack.axis = .vertical
            stack.spacing = 5
            return stack
        }

        let stackView = UIStackView(arrangedSubviews: [titleLabel, detailLabel] + guidance + [button])

        addSubview(stackView)
        stackView.pinEdges(to: safeAreaLayoutGuide)
        stackView.axis = .vertical
        stackView.spacing = 15
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

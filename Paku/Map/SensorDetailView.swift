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
    private let more = Button(
        title: "•••",
        background: .secondarySystemBackground,
        textColor: .label
    )

    private let button = Button(
        title: "Open in PurpleAir",
        background: .secondarySystemBackground,
        textColor: .label
    )

    init(sensor: Sensor, open: @escaping (Sensor) -> Void, hide: @escaping (Sensor) -> Void) {
        super.init(frame: .zero)

        more.setContentHuggingPriority(.required, for: .horizontal)
        more.showsMenuAsPrimaryAction = true
        more.menu = UIMenu(
            title: "This will hide it from the map and prevent it from being used in the widget",
            children: [
                UIMenu(
                    title: "Hide Sensor",
                    children: [
                        UIAction(title: "Hide Sensor", attributes: .destructive, handler: { _ in
                            hide(sensor)
                        }),
                        UIAction(title: "Nevermind", handler: { _ in }),
                    ]
                )
            ]
        )

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

        let buttons = UIStackView(arrangedSubviews: [more, button])
        buttons.spacing = 10

        let stackView = UIStackView(arrangedSubviews: [titleLabel, detailLabel] + guidance + [buttons])

        addSubview(stackView)
        stackView.pinEdges(to: safeAreaLayoutGuide)
        stackView.axis = .vertical
        stackView.spacing = 15
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

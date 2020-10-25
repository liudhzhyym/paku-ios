//
//  SensorDetailView.swift
//  Paku
//
//  Created by Kyle Bashour on 10/24/20.
//

import UIKit
import ScreenCorners

class SensorDetailViewController: UIViewController {
    private let detailView = SensorDetailView()

    override func loadView() {
        view = detailView
    }

    var sensor: Sensor? {
        get { detailView.sensor }
        set { detailView.sensor = newValue }
    }

    var onClose: () -> Void {
        get { detailView.onClose }
        set { detailView.onClose = newValue }
    }
}

class SensorDetailView: UIView {

    var sensor: Sensor? {
        didSet {
            guard let sensor = sensor else { return }
            titleLabel.text = sensor.info.label
            descriptionLabel.text = "Current air quality is satisfactory, and air pollution poses little or no risk."
        }
    }

    var onClose: () -> Void = {}

    private let titleLabel = UILabel(font: .systemFont(ofSize: 24, weight: .medium))
    private let descriptionLabel = UILabel(font: .systemFont(ofSize: 17, weight: .regular), color: .secondaryLabel)
    private let button = Button(title: "Favorite")

    override init(frame: CGRect) {
        super.init(frame: frame)

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

        backgroundColor = .systemBackground

        layer.cornerCurve = .continuous
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = .init(width: 0, height: 1)
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 5

        layer.cornerRadius = 20

        let closeButton = UIButton(type: .system, primaryAction: UIAction { [weak self] _ in
            self?.onClose()
        })

        let config = UIImage.SymbolConfiguration(weight: .bold)
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: config), for: .normal)
        closeButton.tintColor = .secondaryLabel
        addSubview(closeButton)
        closeButton.pinSize(to: 50)
        closeButton.pinEdges([.top, .right], to: self)

        let gesture = PanDirectionGestureRecognizer(direction: .vertical)
        gesture.addTarget(self, action: #selector(swipe))
        addGestureRecognizer(gesture)

        traitCollectionDidChange(nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func swipe(sender: PanDirectionGestureRecognizer) {
        switch sender.state {
        case .began, .changed:
            var value = sender.translation(in: self).y

            if value < 0 {
                value = 100 * tanh(value / 200)
            }

            transform = .init(translationX: 0, y: value)
        default:
            UIViewPropertyAnimator {
                self.transform = .identity
            }.startAnimation()

            if sender.velocity(in: self).y > 0 {
                onClose()
            }
        }
    }
}

//
//  MapButton.swift
//  Paku
//
//  Created by Kyle Bashour on 10/10/20.
//

import UIKit

class MapButtonContainer: UIView {

    private let backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
    private let stackView: UIStackView

    init(buttons: [UIView]) {
        stackView = UIStackView(arrangedSubviews: buttons)
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.axis = .vertical

        super.init(frame: .zero)

        let cornerRadius: CGFloat = 9

        layer.cornerRadius = cornerRadius
        layer.cornerCurve = .continuous
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = .init(width: 0, height: 1)
        layer.shadowOpacity = 0.15
        layer.shadowRadius = 6

        tintColor = .mapButton

        addSubview(backgroundView)
        backgroundView.pinEdges(to: self)
        backgroundView.clipsToBounds = true
        backgroundView.layer.cornerRadius = cornerRadius
        backgroundView.layer.cornerCurve = .continuous
        backgroundView.layer.borderWidth = .pixel

        addSubview(stackView)
        stackView.pinEdges(to: self)

        updateColors()

        for view in buttons.dropLast() {
            let separator = UIView()
            separator.backgroundColor = .mapSeparator
            backgroundView.contentView.addSubview(separator)
            separator.widthAnchor.pin(to: widthAnchor)
            separator.bottomAnchor.pin(to: view.bottomAnchor)
            separator.heightAnchor.pin(to: .pixel)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: 45, height: 45 * stackView.arrangedSubviews.count)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateColors()
    }

    private func updateColors() {
        backgroundView.layer.borderColor = UIColor.separator.cgColor
    }
}

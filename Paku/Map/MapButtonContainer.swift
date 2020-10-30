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

    init(buttons: [UIButton]) {
        stackView = UIStackView(arrangedSubviews: buttons)
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.axis = .vertical

        super.init(frame: .zero)

        let cornerRadius: CGFloat = 12

        layer.cornerRadius = cornerRadius
        layer.cornerCurve = .continuous
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = .init(width: 0, height: 1)
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 5

        addSubview(backgroundView)
        backgroundView.pinEdges(to: self)
        backgroundView.clipsToBounds = true
        backgroundView.layer.cornerRadius = 8
        backgroundView.layer.cornerCurve = .continuous
        backgroundView.layer.borderWidth = .pixel

        addSubview(stackView)
        stackView.pinEdges(to: self)

        updateColors()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: 48, height: 48 * stackView.arrangedSubviews.count)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateColors()
    }

    private func updateColors() {
        backgroundView.layer.borderColor = UIColor.separator.cgColor
    }
}

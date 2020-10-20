//
//  MapButton.swift
//  Paku
//
//  Created by Kyle Bashour on 10/10/20.
//

import UIKit

class MapButton: Control {

    private let backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
    private let content: UIView

    convenience init(symbolName: String) {
        let symbol = UIImage(systemName: symbolName)!
        let imageView = UIImageView(image: symbol)

        imageView.tintColor = .systemBlue
        imageView.contentMode = .center

        self.init(content: imageView)
    }

    init(content: UIView) {
        self.content = content

        super.init(frame: .zero)

        let cornerRadius: CGFloat = 12

        layer.cornerRadius = cornerRadius
        layer.cornerCurve = .continuous
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = .init(width: 0, height: 1)
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 15

        addSubview(backgroundView)
        backgroundView.pinEdges(to: self)
        backgroundView.clipsToBounds = true
        backgroundView.layer.cornerRadius = 8
        backgroundView.layer.cornerCurve = .continuous
        backgroundView.layer.borderWidth = 1

        addSubview(content)
        content.pinEdges(to: self)

        updateColors()
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: 44, height: 44)
    }

    override func updateState() {
        super.updateState()
        content.alpha = isHighlighted ? 0.3 : 1
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateColors()
    }

    private func updateColors() {
        backgroundView.layer.borderColor = UIColor.separator.cgColor
    }
}

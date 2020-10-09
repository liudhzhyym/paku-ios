//
//  MapButton.swift
//  Paku
//
//  Created by Kyle Bashour on 10/10/20.
//

import UIKit

class MapButton: UIButton {

    let backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))

    override init(frame: CGRect) {
        super.init(frame: frame)

        insertSubview(backgroundView, at: 0)
        backgroundView.pinEdges(to: self)
        backgroundView.layer.cornerRadius = 5
        backgroundView.layer.cornerCurve = .continuous
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//
//  MapDetailContainer.swift
//  Paku
//
//  Created by Kyle Bashour on 10/25/20.
//

import UIKit

class MapDetailContainer: UIViewController {

    var onClose: () -> Void = {}

    private let containerView = UIView()
    private var detailView: UIView?
    private var detailBottomConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(containerView)
        containerView.clipsToBounds = true
        containerView.pinEdges(to: view)

        view.backgroundColor = .systemBackground

        view.layer.cornerCurve = .continuous
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = .init(width: 0, height: 1)
        view.layer.shadowOpacity = 0.25
        view.layer.shadowRadius = 5
        view.layer.cornerRadius = 24

        let closeButton = UIButton(type: .system, primaryAction: UIAction { [weak self] _ in
            self?.onClose()
        })

        let config = UIImage.SymbolConfiguration(weight: .bold)
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: config), for: .normal)
        closeButton.tintColor = .tertiaryLabel
        view.addSubview(closeButton)
        closeButton.pinSize(to: 50)
        closeButton.pinEdges([.top, .right], to: view)

        let gesture = PanDirectionGestureRecognizer(direction: .vertical)
        gesture.addTarget(self, action: #selector(swipe))
        view.addGestureRecognizer(gesture)
    }

    func display(detail: UIView, animated: Bool) {
        detail.alpha = 0
        containerView.addSubview(detail)
        detail.pinEdges([.left, .right, .top], to: view, insets: .init(all: 20))

        if detailBottomConstraint == nil {
            detailBottomConstraint = detail.bottomAnchor.pin(to: view.bottomAnchor, constant: -20)
        }

        UIView.performWithoutAnimation {
            view.setNeedsLayout()
            view.layoutIfNeeded()
        }

        detailBottomConstraint?.deactivate()
        detailBottomConstraint = detail.bottomAnchor.pin(to: view.bottomAnchor, constant: -20)

        let animations = {
            detail.alpha = 1
            self.detailView?.alpha = 0
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }

        let cleanup = {
            self.detailView?.removeFromSuperview()
            self.detailView = detail
        }

        if animated {
            let animator = UIViewPropertyAnimator(system: animations)
            animator.addCompletion { _ in cleanup() }
            animator.startAnimation()
        } else {
            animations()
            cleanup()
        }
    }

    @objc private func swipe(sender: PanDirectionGestureRecognizer) {
        switch sender.state {
        case .began, .changed:
            var value = sender.translation(in: view).y

            if value < 0 {
                value = 100 * tanh(value / 200)
            }

            view.transform = .init(translationX: 0, y: value)
        default:
            UIViewPropertyAnimator {
                self.view.transform = .identity
            }.startAnimation()

            if sender.velocity(in: view).y > 0 {
                onClose()
            }
        }
    }
}

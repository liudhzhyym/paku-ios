//
//  UIViewController+Extensions.swift
//  aqi-wtf
//
//  Created by Kyle Bashour on 10/1/20.
//

import UIKit
import SwiftUI

extension UIViewController {

    func add<T: View>(view: T) {
        let controller = UIHostingController(rootView: view)
        addChild(controller)
        self.view.addSubview(controller.view)
        controller.view.frame = self.view.bounds
        controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        controller.didMove(toParent: self)
    }

    func add(_ child: UIViewController, addSubview: ((UIView) -> Void)? = nil) {
        addChild(child)

        if let addSubview = addSubview {
            addSubview(child.view)
        } else {
            view.addSubview(child.view)
            child.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            child.view.frame = view.bounds
        }

        child.didMove(toParent: self)
    }

    func remove(animate: ((UIView, @escaping () -> Void) -> Void)? = nil) {
        willMove(toParent: nil)

        if let animate = animate {
            animate(view) {
                self.view.removeFromSuperview()
                self.removeFromParent()
            }
        } else {
            view.removeFromSuperview()
            removeFromParent()
        }
    }

    func placeholder(title: String? = nil, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func parent<T: UIViewController>(ofType: T.Type) -> T? {
        return parent as? T ?? parent?.parent(ofType: ofType)
    }

    func child<T: UIViewController>(ofType: T.Type) -> T? {
        return children.first(where: { $0 is T }) as? T
    }

}

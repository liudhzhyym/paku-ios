//
//  ViewController.swift
//  aqi-wtf
//
//  Created by Kyle Bashour on 10/1/20.
//

import UIKit
import WidgetKit
import SwiftUI

class ViewController: UIViewController {

    let loader = AQILoader()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        display(view: MessageView(message: "Loading..."))
        refresh()

        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    @objc private func refresh() {
        loader.loadClosestAQI { result in
            switch result {
            case .success(let value):
                self.display(view: EntryWrapperView(aqi: value))
                WidgetCenter.shared.reloadAllTimelines()
            case .failure(let error):
                print(error)
                self.display(view: MessageView(message: "I coded this up at 3am so I'm not surprised something didn’t work"))
            }
        }
    }

    func display<T: View>(view: T) {
        if let child = children.first {
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }


        let controller = UIHostingController(rootView: view)
        addChild(controller)
        self.view.addSubview(controller.view)
        controller.view.frame = self.view.bounds
        controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        controller.didMove(toParent: self)
    }
}

struct EntryWrapperView: View {
    var aqi: AQI

    var body: some View {
        AQIEntryView(aqi: aqi)
            .frame(width: 180, height: 180, alignment: .center)
            .cornerRadius(22)
            .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color(.label), lineWidth: 1))
    }
}

struct ViewController_Previews: PreviewProvider {
    static var previews: some View {
        EntryWrapperView(aqi: .init(value: 100, distance: 10, date: Date()))
    }
}

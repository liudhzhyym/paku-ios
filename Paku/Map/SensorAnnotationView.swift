//
//  AQIAnnotationView.swift
//  Paku
//
//  Created by Kyle Bashour on 10/9/20.
//

import UIKit
import MapKit

class SensorAnnotationView: MKAnnotationView {

    private struct ImageKey: Hashable {
        let value: Int
        let interfaceStyle: Int
    }

    private static var imageCache: [ImageKey: UIImage] = [:]

    private class View: UIView {
        private lazy var borderView = UIView()
        private lazy var innerBorderView = UIView()
        private lazy var label = UILabel(font: .systemFont(ofSize: 13, weight: .semibold), alignment: .center)

        override init(frame: CGRect) {
            super.init(frame: frame)

            addSubview(borderView)
//            borderView.layer.shadowColor = UIColor.black.cgColor
//            borderView.layer.shadowOffset = .init(width: 0, height: 1)
//            borderView.layer.shadowOpacity = 0.25
//            borderView.layer.shadowRadius = 5
            borderView.layer.borderWidth = 3
            borderView.backgroundColor = .systemBackground
            borderView.pinEdges(to: self)

            addSubview(innerBorderView)
            innerBorderView.layer.borderColor = UIColor.black.cgColor
            innerBorderView.layer.borderWidth = 2
            innerBorderView.pinEdges(to: borderView, insets: .init(all: -1))

            addSubview(label)
            label.pinCenter(to: borderView)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func display(aqi: Int, isOutdoor: Bool) {
            label.text = "\(aqi)"
            innerBorderView.isHidden = isOutdoor
            borderView.layer.borderColor = AQICategory.epaColor(for: Double(aqi)).cgColor
        }

        override func layoutSubviews() {
            super.layoutSubviews()

            innerBorderView.layer.cornerRadius = innerBorderView.frame.height / 2
            borderView.frame = bounds
            borderView.layer.cornerRadius = frame.height / 2
        }
    }

    private static let snapshotView = View(frame: CGRect(origin: .zero, size: CGSize(width: 35, height: 35)))

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        collisionMode = .circle
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func display(aqi: Double, isOutdoor: Bool) {
        let aqi = Int(aqi)
        let key = ImageKey(value: aqi, interfaceStyle: traitCollection.userInterfaceStyle.rawValue)

        if let image = Self.imageCache[key] {
            self.image = image
        } else {
            UIApplication.shared.windows[0].addSubview(Self.snapshotView)
            Self.snapshotView.display(aqi: aqi, isOutdoor: isOutdoor)
            Self.snapshotView.setNeedsLayout()
            Self.snapshotView.layoutIfNeeded()

            let renderer = UIGraphicsImageRenderer(bounds: Self.snapshotView.bounds.insetBy(dx: -2, dy: -2))
            let image = renderer.image { rendererContext in
                Self.snapshotView.layer.render(in: rendererContext.cgContext)
            }

            Self.snapshotView.removeFromSuperview()
            Self.imageCache[key] = image
            self.image = image
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            prepareForDisplay()
        }
    }
}

class SingleSensorAnnotationView: SensorAnnotationView {
    static let clusteringIdentifier: String? = nil // "single_sensor_cluster_id"

    override var annotation: MKAnnotation? {
        didSet {
            self.clusteringIdentifier = Self.clusteringIdentifier
        }
    }

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.clusteringIdentifier = Self.clusteringIdentifier
    }

    override func prepareForDisplay() {
        super.prepareForDisplay()
        if let annotation = annotation as? SensorAnnotation {
            display(aqi: annotation.sensor.aqiValue(),
                    isOutdoor: annotation.sensor.info.isOutdoor)
        }
    }
}

class ClusteredSensorAnnotationView: SensorAnnotationView {
    override func prepareForDisplay() {
        super.prepareForDisplay()
        if let annotation = annotation as? MKClusterAnnotation {
            let median = annotation.memberAnnotations
                .compactMap { $0 as? SensorAnnotation }
                .map { $0.sensor.aqiValue() }
                .sorted(by: <)
                .median()

            display(aqi: median, isOutdoor: false)
        }
    }
}

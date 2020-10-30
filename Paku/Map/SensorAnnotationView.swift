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
        let isOutdoor: Bool
    }

    private static var imageCache: [ImageKey: UIImage] = [:]

    private class View: UIView {
        private lazy var borderView = UIView()
        private lazy var label = UILabel(font: .systemFont(ofSize: 13, weight: .bold), alignment: .center)

        override init(frame: CGRect) {
            super.init(frame: frame)

            addSubview(borderView)
            borderView.layer.borderWidth = 3
            borderView.layer.borderColor = UIColor.black.cgColor
            borderView.pinEdges(to: self)

            addSubview(label)
            label.pinCenter(to: borderView)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func display(aqi: Int, isOutdoor: Bool) {
            label.text = "\(aqi)"
            borderView.isHidden = isOutdoor

            let color = AQICategory.epaColor(for: Double(aqi))
            backgroundColor = color
            label.textColor = color.isLight ? UIColor.black : UIColor.white
        }

        override func layoutSubviews() {
            super.layoutSubviews()

            layer.cornerRadius = frame.height / 2

            borderView.frame = bounds
            borderView.layer.cornerRadius = frame.height / 2
        }
    }

    private static let snapshotView = View(frame: CGRect(origin: .zero, size: CGSize(width: 35, height: 35)))

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        layer.shadowOffset = .init(width: 0, height: 1)
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 5
        layer.shadowPath = CGPath(ellipseIn: Self.snapshotView.frame, transform: nil)
        layer.shadowColor = UIColor.clear.cgColor

        collisionMode = .circle
        zPriority = .min
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func display(aqi: Double, isOutdoor: Bool) {
        let aqi = Int(aqi)
        let key = ImageKey(value: aqi, isOutdoor: isOutdoor)

        if let image = Self.imageCache[key] {
            self.image = image
        } else {
            UIApplication.shared.windows[0].addSubview(Self.snapshotView)
            Self.snapshotView.display(aqi: aqi, isOutdoor: isOutdoor)
            Self.snapshotView.setNeedsLayout()
            Self.snapshotView.layoutIfNeeded()

            let renderer = UIGraphicsImageRenderer(bounds: Self.snapshotView.bounds)
            let image = renderer.image { rendererContext in
                Self.snapshotView.layer.render(in: rendererContext.cgContext)
            }

            Self.snapshotView.removeFromSuperview()
            Self.imageCache[key] = image
            self.image = image
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        layer.removeAllAnimations()
    }

    override func prepareForDisplay() {
        super.prepareForDisplay()

        let fadeIn = CABasicAnimation(keyPath: "opacity")
        fadeIn.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        fadeIn.duration = 0.1
        fadeIn.fromValue = 0
        fadeIn.toValue = 1
        layer.add(fadeIn, forKey: "fade")

        let scale = CASpringAnimation(keyPath: "transform.scale")
        scale.duration = 0.2
        scale.fromValue = 0.8
        scale.toValue = 1
        layer.add(scale, forKey: "scale")
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

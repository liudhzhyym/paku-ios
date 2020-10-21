//
//  AQIAnnotationView.swift
//  Paku
//
//  Created by Kyle Bashour on 10/9/20.
//

import UIKit
import MapKit

class SensorAnnotationView: MKAnnotationView {

    private static var imageCache: [Int: UIImage] = [:]

    private class View: UIView {
        private lazy var borderView = UIView()
        private lazy var label = UILabel(font: .systemFont(ofSize: 13, weight: .semibold), alignment: .center)

        override init(frame: CGRect) {
            super.init(frame: frame)

            addSubview(borderView)
            borderView.layer.shadowColor = UIColor.black.cgColor
            borderView.layer.shadowOffset = .init(width: 0, height: 1)
            borderView.layer.shadowOpacity = 0.25
            borderView.layer.shadowRadius = 5
            borderView.layer.borderWidth = 3
            borderView.backgroundColor = .systemBackground
            borderView.pinEdges(to: self)

            borderView.addSubview(label)
            label.pinCenter(to: borderView)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func display(aqi: Int) {
            label.text = "\(aqi)"
            borderView.layer.borderColor = AQICategory.epaColor(for: Double(aqi)).cgColor
        }

        override func layoutSubviews() {
            super.layoutSubviews()

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

    func display(aqi: Double) {
        let aqi = Int(aqi)

        if let image = Self.imageCache[aqi] {
            self.image = image
        } else {
            Self.snapshotView.display(aqi: aqi)
            Self.snapshotView.setNeedsLayout()
            Self.snapshotView.layoutIfNeeded()

            let renderer = UIGraphicsImageRenderer(bounds: Self.snapshotView.bounds.insetBy(dx: -10, dy: -10))
            let image = renderer.image { rendererContext in
                Self.snapshotView.layer.render(in: rendererContext.cgContext)
            }

            Self.imageCache[aqi] = image
            self.image = image
        }
    }
}

class SingleSensorAnnotationView: SensorAnnotationView {
    static let clusteringIdentifier = "single_sensor_cluster_id"

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
            display(aqi: annotation.sensor.aqiValue())
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

            display(aqi: median)
        }
    }
}

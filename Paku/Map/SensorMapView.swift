//
//  Sensorswift
//  Paku
//
//  Created by Kyle Bashour on 11/2/20.
//

import UIKit
import MapKit

private let maximumAnnotations = 1000
private let queuedAnnotationDelay: TimeInterval = 0.1

protocol SensorMapViewDelegate: AnyObject {
    func displayDetails(for annotation: SensorAnnotation, animated: Bool) -> CLLocationDegrees
    func hideDetails(animated: Bool)
}

class SensorMapView: MKMapView {
    private var queuedInsertions: [SensorAnnotation] = []
    private var queuedRemovals: [SensorAnnotation] = []
    private var needsAnnotationUpdate = false
    private let loader = SensorLoader()
    private var didCenterOnInitialLocation = false
    private var item: DispatchWorkItem?
    private var _annotations: Set<SensorAnnotation> = []

    private var updateTimer: Timer?

    weak var customDelegate: SensorMapViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        updateTimer = Timer.scheduledTimer(
            withTimeInterval: queuedAnnotationDelay,
            repeats: true) { [weak self] _ in
            self?.updateAnnotationsIfNeeded()
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refresh),
            name: UIApplication.didBecomeActiveNotification,
            object: nil)

        register(SingleSensorAnnotationView.self)
        register(ClusteredSensorAnnotationView.self)
        register(MKUserLocationView.self)
        delegate = self
        showsUserLocation = true
        mapType = .mutedStandard
        showsCompass = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func clear() {
        removeAnnotations(annotations)
        _annotations.removeAll(keepingCapacity: true)
    }

    func remove(sensor: Sensor) {
        if let annotation = _annotations.first(where: { $0.sensor.info.id == sensor.info.id }) {
            _annotations.remove(annotation)
            removeAnnotation(annotation)
        }
    }

    @objc func refresh() {
        item?.cancel()
        item = DispatchWorkItem(block: actuallyRefresh)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: item!)
    }

    func actuallyRefresh() {
        loader.loadAnnotations(in: visibleMapRect) { [weak self] sensor in
            guard let self = self else { return }

            if let existing = self._annotations.first(where: { $0.sensor.info.id == sensor.info.id }) {
                if sensor.aqiValue() != existing.sensor.aqiValue() {
                    self._annotations.remove(existing)
                    let annotation = SensorAnnotation(sensor: sensor)
                    annotation.shouldAnimateDisplay = false
                    self.queuedInsertions.append(annotation)
                    self.queuedRemovals.append(existing)
                }
            } else {
                self.queuedInsertions.append(SensorAnnotation(sensor: sensor))
            }
        }
    }

    private func updateAnnotationsIfNeeded() {
        if queuedInsertions.count > 0 {
            logger.debug("Adding: \(self.queuedInsertions.count) queued sensor annotations")

            addAnnotations(queuedInsertions)
            _annotations.formUnion(queuedInsertions)
            queuedInsertions.removeAll(keepingCapacity: true)

            removeAnnotations(queuedRemovals)
            queuedRemovals.removeAll(keepingCapacity: true)

            trimAnnotations()
        }
    }

    func centerOnCurrentLocation(animated: Bool) {
        let region = MKCoordinateRegion(
            center: userLocation.coordinate,
            latitudinalMeters: 2000,
            longitudinalMeters: 2000
        )

        deselectAnnotation(selectedAnnotations.first, animated: animated)
        setRegion(region, animated: animated)
    }

    private func trimAnnotations() {
        let visibleAnnotations = _annotations.filter {
            let point = MKMapPoint($0.sensor.info.location.coordinate)
            return self.visibleMapRect.contains(point)
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let invisibleSet = self._annotations.subtracting(visibleAnnotations)
            var annotationsToRemove: [SensorAnnotation] = []

            if visibleAnnotations.count > maximumAnnotations {
                annotationsToRemove.append(contentsOf: visibleAnnotations.shuffled()
                                            .dropFirst(maximumAnnotations))
                annotationsToRemove.append(contentsOf: invisibleSet)
            } else {
                let allowedInvisibleAnnotations = maximumAnnotations - visibleAnnotations.count
                annotationsToRemove.append(contentsOf: invisibleSet.shuffled()
                                            .dropFirst(allowedInvisibleAnnotations))
            }

            self._annotations.subtract(annotationsToRemove)

            DispatchQueue.main.async {
                self.removeAnnotations(annotationsToRemove)
                logger.debug("Trimming: removed \(annotationsToRemove.count) annotations")
            }
        }
    }


    private func highlight(view: SensorAnnotationView) {
        UIViewPropertyAnimator(duration: 0.6, dampingRatio: 0.6) {
            view.transform = view.isSelected ? .init(scaleX: 1.3, y: 1.3) : .identity
            view.layer.shadowColor = view.isSelected ? UIColor.black.cgColor : UIColor.clear.cgColor
        }.startAnimation()

        if view.isSelected, let annotation = view.annotation as? SensorAnnotation {
            if let height = customDelegate?.displayDetails(for: annotation, animated: true) {
                var sensorCoordinate = annotation.sensor.info.location.coordinate
                sensorCoordinate.latitude -= height / 2
                setCenter(sensorCoordinate, animated: true)
            }
        } else {
            customDelegate?.hideDetails(animated: true)
        }
    }
}

extension SensorMapView: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if didCenterOnInitialLocation { return }
        didCenterOnInitialLocation = true
        centerOnCurrentLocation(animated: false)
        refresh()
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        refresh()
    }

    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        refresh()
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            let view = dequeue(for: annotation) as MKUserLocationView
            view.zPriority = .max
            return view
        }

        if annotation is MKClusterAnnotation {
            let view = dequeue(for: annotation) as ClusteredSensorAnnotationView
            return view
        }

        if annotation is SensorAnnotation {
            let view = dequeue(for: annotation) as SingleSensorAnnotationView
            return view
        }

        fatalError("Unhandled annotation")
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let view = view as? SensorAnnotationView {
            highlight(view: view)
        }
    }

    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if let view = view as? SensorAnnotationView {
            highlight(view: view)
        }
    }
}


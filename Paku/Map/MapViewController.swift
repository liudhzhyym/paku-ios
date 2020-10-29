//
//  MapViewController.swift
//  Paku
//
//  Created by Kyle Bashour on 10/8/20.
//

import UIKit
import MapKit
import SafariServices

private let maximumAnnotations = 1000
private let queuedAnnotationDelay: TimeInterval = 0.1

class MapViewController: ViewController {

    private var queuedAnnotations: [MKAnnotation] = []
    private var needsAnnotationUpdate = false
    private let loader = SensorLoader()

    private var updateTimer: Timer?

    private var didCenterOnInitialLocation = false
    private var item: DispatchWorkItem?
    private lazy var mapView = MKMapView()

    private lazy var detailContainer = MapDetailContainer()

    private lazy var visibleDetailConstraints = [
        detailContainer.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
    ]

    private lazy var hiddenDetailConstraints = [
        detailContainer.view.topAnchor.constraint(equalTo: view.bottomAnchor)
    ]

    private var annotations: Set<SensorAnnotation> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        updateTimer = Timer.scheduledTimer(
            withTimeInterval: queuedAnnotationDelay,
            repeats: true) { [weak self] _ in
            self?.updateAnnotationsIfNeeded()
        }

        additionalSafeAreaInsets.bottom = 10

        view.addSubview(mapView)
        mapView.pinEdges(to: view)

        let locationButton = MapButton(symbolName: "location")
        locationButton.addAction(UIAction { [weak self] _ in
            self?.centerOnCurrentLocation(animated: true)
        }, for: .touchUpInside)

        view.addSubview(locationButton)
        locationButton.pinEdges([.right, .top],
                                to: view.safeAreaLayoutGuide,
                                insets: .init(all: 10))

        let settingsButton = MapButton(symbolName: "line.horizontal.3")
        settingsButton.addAction(UIAction { [weak self] _ in
            self?.openSettings()
        }, for: .touchUpInside)

        //        view.addSubview(settingsButton)
        //        settingsButton.pinEdges([.left, .bottom], to: view.layoutMarginsGuide, insets: .init(vertical: 40, horizontal: 0))


        let blurEffect = UIBlurEffect(style: .systemChromeMaterial)
        let safeAreaBlurView = UIVisualEffectView(effect: blurEffect)

        view.addSubview(safeAreaBlurView)
        safeAreaBlurView.pinEdges([.top, .right, .left], to: view)
        safeAreaBlurView.bottomAnchor.pin(to: view.safeAreaLayoutGuide.topAnchor)

        mapView.register(SingleSensorAnnotationView.self)
        mapView.register(ClusteredSensorAnnotationView.self)
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.mapType = .mutedStandard

        detailContainer.onClose = { [weak self] in
            guard let self = self else { return }
            for annotation in self.mapView.selectedAnnotations {
                self.mapView.deselectAnnotation(annotation, animated: true)
            }
        }

        add(detailContainer)
        setOverrideTraitCollection(
            UITraitCollection(userInterfaceLevel: .elevated),
            forChild: detailContainer
        )

        view.addSubview(detailContainer.view)
        detailContainer.view.pinEdges([.left, .right],
                                      to: view.safeAreaLayoutGuide,
                                      insets: .init(all: 10))

        setDetailHidden(true, animated: false)
    }

    func refresh() {
        item?.cancel()
        item = DispatchWorkItem(block: actuallyRefresh)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: item!)
    }

    func actuallyRefresh() {
        queuedAnnotations.removeAll()

        loader.loadAnnotations(in: mapView.visibleMapRect) { [weak self] sensor in
            guard let self = self else { return }

            if let existing = self.annotations
                .first(where: { $0.sensor.info.id == sensor.info.id }) {
                if sensor != existing.sensor {
                    existing.sensor = sensor
                    self.mapView.view(for: existing)?.annotation = existing
                }
            } else {
                let annotation = SensorAnnotation(sensor: sensor)
                self.annotations.insert(annotation)
                self.queuedAnnotations.append(annotation)
            }
        }
    }

    private func centerOnCurrentLocation(animated: Bool) {
        let region = MKCoordinateRegion(
            center: mapView.userLocation.coordinate,
            latitudinalMeters: 2000,
            longitudinalMeters: 2000
        )

        mapView.deselectAnnotation(mapView.selectedAnnotations.first, animated: animated)
        mapView.setRegion(region, animated: animated)
    }

    private func trimAnnotations() {
        let visibleAnnotations = annotations.filter {
            let point = MKMapPoint($0.sensor.info.location.coordinate)
            return self.mapView.visibleMapRect.contains(point)
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let invisibleSet = self.annotations.subtracting(visibleAnnotations)
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

            DispatchQueue.main.async {
                self.mapView.removeAnnotations(annotationsToRemove)
                self.annotations = self.annotations.subtracting(annotationsToRemove)
                print("--- removed \(annotationsToRemove.count)")
            }
        }
    }

    private func openSettings() {
        present(UIViewController(), animated: true, completion: nil)
    }

    func display(sensor: Sensor, animated: Bool) {
        let view = SensorDetailView(sensor: sensor) {
            self.openWebsite(for: $0)
        }
        detailContainer.display(detail: view, animated: true)
        setDetailHidden(false, animated: true)
    }

    func display(annotations: [SensorAnnotation], animated: Bool) {
        let view = SensorListView(annotations: annotations, maximumHeight: self.view.frame.height / 2) {
            self.mapView.selectAnnotation($0, animated: true)
        }
        detailContainer.display(detail: view, animated: true)
        setDetailHidden(false, animated: true)
    }

    func setDetailHidden(_ isHidden: Bool, animated: Bool) {
        if isHidden {
            NSLayoutConstraint.deactivate(visibleDetailConstraints)
            NSLayoutConstraint.activate(hiddenDetailConstraints)
        } else {
            NSLayoutConstraint.deactivate(hiddenDetailConstraints)
            NSLayoutConstraint.activate(visibleDetailConstraints)
        }

        if animated {
            UIViewPropertyAnimator {
                self.view.layoutIfNeeded()
            }.startAnimation()
        }
    }

    private func updateAnnotationsIfNeeded() {
        if queuedAnnotations.count > 0 {
            let annotations = queuedAnnotations
            queuedAnnotations.removeAll(keepingCapacity: true)
            print("--- Adding \(annotations.count) annotations")
            mapView.addAnnotations(annotations)
            trimAnnotations()
        }
    }

    private func openWebsite(for sensor: Sensor) {
        let url = URL(string: "https://www.purpleair.com/map?opt=1/i/mAQI/a0/cC5&select=\(sensor.info.id)")!
        let viewController = SFSafariViewController(url: url)
        show(viewController, sender: self)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if didCenterOnInitialLocation { return }
        didCenterOnInitialLocation = true
        centerOnCurrentLocation(animated: false)
        refresh()
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        refresh()
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }

        if annotation is MKClusterAnnotation {
            let view = mapView.dequeue(for: annotation) as ClusteredSensorAnnotationView
            return view
        }

        if annotation is SensorAnnotation {
            let view = mapView.dequeue(for: annotation) as SingleSensorAnnotationView
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

    private func highlight(view: SensorAnnotationView) {
        UIViewPropertyAnimator(duration: 0.6, dampingRatio: 0.6) {
            view.transform = view.isSelected ? .init(scaleX: 1.3, y: 1.3) : .identity
            view.layer.shadowColor = view.isSelected ? UIColor.black.cgColor : UIColor.clear.cgColor
        }.startAnimation()

        if view.isSelected, let annotation = view.annotation as? SensorAnnotation {
            mapView.setCenter(annotation.sensor.info.location.coordinate, animated: true)
            display(sensor: annotation.sensor, animated: true)
        } else if view.isSelected, let annotation = view.annotation as? MKClusterAnnotation {
            let annotations = annotation.memberAnnotations.compactMap { $0 as? SensorAnnotation }
            display(annotations: annotations, animated: true)
        } else {
            setDetailHidden(true, animated: true)
        }
    }
}

//
//  MapViewController.swift
//  Paku
//
//  Created by Kyle Bashour on 10/8/20.
//

import UIKit
import MapKit

class MapViewController: ViewController {

    private var queuedAnnotations: [MKAnnotation] = []
    private var needsAnnotationUpdate = false
    private let loader = SensorLoader()

    private var updateTimer: Timer?

    private var didCenterOnInitialLocation = false
    private var item: DispatchWorkItem?
    private lazy var mapView = MKMapView()

    private lazy var detailViewController = SensorDetailViewController()
    private var detailView: UIView { detailViewController.view }

    private lazy var visibleDetailViewConstraints = [
        detailView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
    ]

    private lazy var hiddenDetailViewConstraints = [
        detailView.topAnchor.constraint(equalTo: view.bottomAnchor)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
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

        detailViewController.onClose = { [weak self] in
            guard let self = self else { return }
            for annotation in self.mapView.selectedAnnotations {
                self.mapView.deselectAnnotation(annotation, animated: true)
            }
        }

        add(detailViewController)
        setOverrideTraitCollection(
            UITraitCollection(userInterfaceLevel: .elevated),
            forChild: detailViewController)

        view.addSubview(detailView)
        detailView.pinEdges([.left, .right],
                            to: view.safeAreaLayoutGuide,
                            insets: .init(all: 10))

        hideSensorDetails(animated: false)
    }

    func refresh() {
        loader.loadAnnotations(in: mapView.visibleMapRect) { [weak self] sensor in
            guard let self = self else { return }

            if let existing = self.mapView.annotations
                .compactMap({ $0 as? SensorAnnotation })
                .first(where: { $0.sensor.info.id == sensor.info.id }) {
                if sensor != existing.sensor {
                    existing.sensor = sensor
                    self.mapView.view(for: existing)?.annotation = existing
                }
            } else {
                let annotation = SensorAnnotation(sensor: sensor)
                self.queuedAnnotations.append(annotation)
            }
        }

        removeAnnotationsOutsideRect()
    }

    private func centerOnCurrentLocation(animated: Bool) {
        let region = MKCoordinateRegion(
            center: mapView.userLocation.coordinate,
            latitudinalMeters: 4000,
            longitudinalMeters: 4000
        )

        mapView.setRegion(region, animated: animated)
    }

    private func removeAnnotationsOutsideRect() {
        let annotations = mapView.annotations
            .compactMap({ $0 as? SensorAnnotation })
            .filter {
                let point = MKMapPoint($0.sensor.info.location.coordinate)
                return !self.mapView.visibleMapRect.contains(point)
            }

        mapView.removeAnnotations(annotations)
    }

    private func openSettings() {
        present(UIViewController(), animated: true, completion: nil)
    }

    func display(sensor: Sensor, animated: Bool) {
        detailViewController.sensor = sensor

        UIView.performWithoutAnimation {
            detailView.setNeedsLayout()
            detailView.layoutIfNeeded()
        }

        NSLayoutConstraint.deactivate(hiddenDetailViewConstraints)
        NSLayoutConstraint.activate(visibleDetailViewConstraints)

        if animated {
            UIViewPropertyAnimator {
                self.view.layoutIfNeeded()
            }.startAnimation()
        }
    }

    func hideSensorDetails(animated: Bool) {
        NSLayoutConstraint.deactivate(visibleDetailViewConstraints)
        NSLayoutConstraint.activate(hiddenDetailViewConstraints)

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
        }
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
        }.startAnimation()

        if view.isSelected, let annotation = view.annotation as? SensorAnnotation {
            self.mapView.setCenter(annotation.sensor.info.location.coordinate, animated: true)
            self.display(sensor: annotation.sensor, animated: true)
        } else {
            self.hideSensorDetails(animated: true)
        }
    }
}

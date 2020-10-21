//
//  MapViewController.swift
//  Paku
//
//  Created by Kyle Bashour on 10/8/20.
//

import UIKit
import MapKit

class MapViewController: ViewController {

    private let loader = AQILoader()

    private var didCenterOnInitialLocation = false
    private var item: DispatchWorkItem?
    private lazy var mapView = MKMapView()

    override func loadView() {
        view = mapView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let locationButton = MapButton(symbolName: "location")
        locationButton.addAction(UIAction { [weak self] _ in
            self?.centerOnCurrentLocation(animated: true)
        }, for: .touchUpInside)

        view.addSubview(locationButton)
        locationButton.pinEdges([.right, .bottom], to: view.layoutMarginsGuide, insets: .init(vertical: 50, horizontal: 0))

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
    }

    func refresh() {
        if let annotation = mapView.annotations.first(where: { $0 is SensorAnnotation }) as? SensorAnnotation,
           Date().timeIntervalSince(annotation.sensor.age) < 60 {
            return
        }

        item?.cancel()
        item = DispatchWorkItem {
            guard let location = self.mapView.userLocation.location else { return }
            self.loader.loadSensor(near: location) { result in
                guard let sensor = try? result.get() else { return }
                self.mapView.removeAnnotations(self.mapView.annotations)
                self.mapView.addAnnotation(SensorAnnotation(sensor: sensor))

            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: item!)
    }

    private func centerOnCurrentLocation(animated: Bool) {
        let region = MKCoordinateRegion(
            center: mapView.userLocation.coordinate,
            latitudinalMeters: 5000,
            longitudinalMeters: 5000
        )

        mapView.setRegion(region, animated: animated)
    }

    private func openSettings() {
        present(UIViewController(), animated: true, completion: nil)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if didCenterOnInitialLocation { return }
        didCenterOnInitialLocation = true
        centerOnCurrentLocation(animated: false)
        refresh()
    }

    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
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
}

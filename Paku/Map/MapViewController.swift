//
//  MapViewController.swift
//  Paku
//
//  Created by Kyle Bashour on 10/8/20.
//

import UIKit
import MapKit

class MapViewController: ViewController {

    private var didCenterOnInitialLocation = false
    private var item: DispatchWorkItem?
    private lazy var mapView = MKMapView()

    override func loadView() {
        view = mapView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let button = UIButton(type: .system, primaryAction: .init { _ in
            self.centerOnCurrentLocation(animated: true)
        })

        let image = UIImage(systemName: "location.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32))

        button.setImage(image, for: .normal)
        button.tintColor = .white

        view.addSubview(button)
        button.pinEdges([.right, .bottom], to: view.layoutMarginsGuide, insets: .init(vertical: 40, horizontal: 0))

        let blurEffect = UIBlurEffect(style: .systemChromeMaterial)
        let safeAreaBlurView = UIVisualEffectView(effect: blurEffect)

        view.addSubview(safeAreaBlurView)
        safeAreaBlurView.pinEdges([.top, .right, .left], to: view)
        safeAreaBlurView.bottomAnchor.pin(to: view.safeAreaLayoutGuide.topAnchor)

        mapView.register(SingleAQIAnnotationView.self)
        mapView.register(ClusteredAQIAnnotationView.self)
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.mapType = .mutedStandard
    }

    func refresh() {
        item?.cancel()
        item = DispatchWorkItem {

            let displayed = Set(self.mapView.annotations
                .compactMap { $0 as? AQIAnnotation }
                .map(\.sensorID))

//            let irrelevant = self.mapView.annotations.filter {
//                !self.mapView.visibleMapRect.contains(MKMapPoint($0.coordinate))
//            }
//
//            self.mapView.removeAnnotations(irrelevant)

            AQILoader().loadSensors { result in
                if let sensors = try? result.get() {
                    let annotations = sensors
                        .filter { !displayed.contains($0.id) }
                        .filter { self.mapView.visibleMapRect.contains(MKMapPoint($0.location.coordinate)) }
                        .map { AQIAnnotation(coordinate: $0.location.coordinate, sensorID: $0.id) }

                    self.mapView.addAnnotations(annotations)
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: item!)
    }

    func centerOnCurrentLocation(animated: Bool) {
        let region = MKCoordinateRegion(
            center: mapView.userLocation.coordinate,
            latitudinalMeters: 5000,
            longitudinalMeters: 5000
        )

        mapView.setRegion(region, animated: animated)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if didCenterOnInitialLocation { return }
        didCenterOnInitialLocation = true
        centerOnCurrentLocation(animated: false)
    }

    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        refresh()
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }

        if annotation is MKClusterAnnotation {
            let view = mapView.dequeue(for: annotation) as ClusteredAQIAnnotationView
            return view
        }

        if annotation is AQIAnnotation {
            let view = mapView.dequeue(for: annotation) as SingleAQIAnnotationView
            return view
        }

        fatalError("Unhandled annotation")
    }
}

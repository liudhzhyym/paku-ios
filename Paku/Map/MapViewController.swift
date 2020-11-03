//
//  MapViewController.swift
//  Paku
//
//  Created by Kyle Bashour on 10/8/20.
//

import UIKit
import MapKit
import SafariServices
import WidgetKit


class MapViewController: ViewController {

    private var settings: Settings?


    private lazy var mapView = SensorMapView()

    private lazy var detailContainer = MapDetailContainer()

    private let conversionButton = UIButton(type: .system)
    private let locationTypeButton = UIButton(type: .system)

    private lazy var visibleDetailConstraints = [
        detailContainer.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
    ]

    private lazy var hiddenDetailConstraints = [
        detailContainer.view.topAnchor.constraint(equalTo: view.bottomAnchor)
    ]


    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.customDelegate = self

        additionalSafeAreaInsets.bottom = 10

        view.addSubview(mapView)
        mapView.pinEdges(to: view)

        let settingsButton = UIButton(type: .system)
        settingsButton.setImage(UIImage(symbol: "gear", size: 16, weight: .medium), for: .normal)
        settingsButton.addAction(UIAction { [weak self] _ in
            self?.openSettings()
        }, for: .touchUpInside)

        let locationButton = UIButton(type: .system)
        locationButton.setImage(UIImage(symbol: "location", size: 16, weight: .medium), for: .normal)
        locationButton.addAction(UIAction { [weak self] _ in
            self?.mapView.centerOnCurrentLocation(animated: true)
        }, for: .touchUpInside)

        locationTypeButton.showsMenuAsPrimaryAction = true

        conversionButton.showsMenuAsPrimaryAction = true
        conversionButton.setImage(UIImage(symbol: "equal.circle", size: 16, weight: .medium), for: .normal)

        let settingsContainer = MapButtonContainer(buttons: [settingsButton])
        view.addSubview(settingsContainer)
        settingsContainer.trailingAnchor.pin(to: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)
        settingsContainer.topAnchor.pin(to: view.safeAreaLayoutGuide.topAnchor, constant: 10)

        let quickSettings = MapButtonContainer(buttons: [conversionButton, locationTypeButton])
        view.addSubview(quickSettings)
        quickSettings.trailingAnchor.pin(to: settingsContainer.trailingAnchor)
        quickSettings.topAnchor.pin(to: settingsContainer.bottomAnchor, constant: 5)

        let locationContainer = MapButtonContainer(buttons: [locationButton])
        view.addSubview(locationContainer)
        locationContainer.trailingAnchor.pin(to: settingsContainer.trailingAnchor)
        locationContainer.topAnchor.pin(to: quickSettings.bottomAnchor, constant: 5)

        let compassButton = MKCompassButton(mapView: mapView)
        view.addSubview(compassButton)
        compassButton.centerXAnchor.pin(to: locationContainer.centerXAnchor)
        compassButton.topAnchor.pin(to: locationContainer.bottomAnchor, constant: 10)

        let blurEffect = UIBlurEffect(style: .systemChromeMaterial)
        let safeAreaBlurView = UIVisualEffectView(effect: blurEffect)

        view.addSubview(safeAreaBlurView)
        safeAreaBlurView.pinEdges([.top, .right, .left], to: view)
        safeAreaBlurView.bottomAnchor.pin(to: view.safeAreaLayoutGuide.topAnchor)

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
        detailContainer.view.leadingAnchor.pin(
            to: view.safeAreaLayoutGuide.leadingAnchor,
            constant: 10,
            priority: .almostRequired)
        detailContainer.view.trailingAnchor.pin(
            to: view.safeAreaLayoutGuide.trailingAnchor,
            constant: -10,
            priority: .almostRequired)

        detailContainer.view.centerXAnchor.pin(to: view.centerXAnchor)
        detailContainer.view.widthAnchor.pin(lessThan: 500)

        setDetailHidden(true, animated: false)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateSettings),
            name: UserDefaults.didChangeNotification,
            object: nil)

        updateSettings()
    }

    @objc private func updateSettings() {
        guard UserDefaults.shared.settings != settings else { return }

        // TODO: Move somewhere else
        WidgetCenter.shared.reloadAllTimelines()

        settings = UserDefaults.shared.settings

        DispatchQueue.main.async {
            self.mapView.clear()
            self.mapView.actuallyRefresh()

            let locationImage = UIImage(symbol: UserDefaults.shared.settings.location.symbolName, size: 16, weight: .medium)
            self.locationTypeButton.setImage(locationImage, for: .normal)

            let conversionImage = UIImage(symbol: UserDefaults.shared.settings.conversion.symbolName, size: 16, weight: .medium)
            self.conversionButton.setImage(conversionImage, for: .normal)

            self.conversionButton.menu = UIMenu(title: "Correction", options: [.displayInline], children: AQIConversion.allCases.map { conversion in
                let current = UserDefaults.shared.settings.conversion
                return UIAction(title: conversion.name, state: current == conversion ? .on : .off) { _ in
                    UserDefaults.shared.settings.conversion = conversion
                }
            })

            self.locationTypeButton.menu = UIMenu(title: "Sensor Location", options: [.displayInline], children: LocationType.allCases.map { location in
                let current = UserDefaults.shared.settings.location
                return UIAction(title: location.name,
                         image: UIImage(systemName: location.symbolName),
                         state: current == location ? .on : .off) { _ in
                    UserDefaults.shared.settings.location = location
                }
            })
        }
    }


    private func openSettings() {
        let viewController = SettingsViewController()
        viewController.navigationItem.title = "Settings"
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .formSheet
        present(navigationController, animated: true, completion: nil)
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

    private func openWebsite(for sensor: Sensor) {
        let url = URL(string: "https://www.purpleair.com/map?opt=1/i/mAQI/a0/cC5&select=\(sensor.info.id)")!
        let viewController = SFSafariViewController(url: url)
        show(viewController, sender: self)
    }
}

extension MapViewController: SensorMapViewDelegate {
    func displayDetails(for annotation: SensorAnnotation, animated: Bool) -> CLLocationDegrees {
        display(sensor: annotation.sensor, animated: animated)
        return mapView.convert(detailContainer.view.bounds, toRegionFrom: nil).span.latitudeDelta
    }

    func hideDetails(animated: Bool) {
        setDetailHidden(true, animated: animated)
    }
}

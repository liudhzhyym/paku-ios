//
//  AnnotationLoader.swift
//  Paku
//
//  Created by Kyle Bashour on 10/25/20.
//

import Foundation
import MapKit

class SensorLoader {

    private let loader = AQILoader()
    private let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        return queue
    }()

    private var sensors: [SensorWrapper] = []

    func cancel() {
        self.queue.cancelAllOperations()
    }

    func loadAnnotations(in area: MKMapRect, didLoadSensor: @escaping (Sensor) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.cancel()

            self.loadSensorsIfNeeded {
                let sensors = self.sensors
                    .filter {
                        let point = MKMapPoint($0.info.location.coordinate)
                        return area.contains(point)
                    }
                    .shuffled()
                    .prefix(300)

                logger.debug("Loading: \(sensors.count) sensors out of \(self.sensors.count)")

                let operations: [Operation] = sensors.map {
                    let operation = SensorOperation(wrapper: $0, loader: self.loader)

                    operation.completionBlock = { [weak operation] in
                        if let sensor = operation?.wrapper.sensor {
                            DispatchQueue.main.async {
                                didLoadSensor(sensor)
                            }
                        }
                    }

                    return operation
                }

                self.queue.addOperations(operations, waitUntilFinished: false)
            }
        }
    }

    private func loadSensorsIfNeeded(completion: @escaping () -> Void) {
        loader.loadSensors { result in
            switch result {
            case .success(let infos):
                switch UserDefaults.shared.settings.location {
                case .outdoors:
                    self.sensors = infos.filter(\.isOutdoor).map(SensorWrapper.init)
                case .indoors:
                    self.sensors = infos.filter { !$0.isOutdoor } .map(SensorWrapper.init)
                case .both:
                    self.sensors = infos.map(SensorWrapper.init)
                }
            case .failure(let error):
                logger.debug("Failed to load sensors for SensorLoader: \(error.localizedDescription)")
            }

            completion()
        }
    }
}

private class SensorWrapper {
    var info: SensorInfo
    var sensor: Sensor?

    var didFail = false

    init(info: SensorInfo) {
        self.info = info
    }
}

private class SensorOperation: Operation {

    private var dataTask: URLSessionDataTask?
    private let loader: AQILoader

    let wrapper: SensorWrapper

    override var isAsynchronous: Bool {
        true
    }

    private var _isExecuting = false
    override var isExecuting: Bool {
        get {
            _isExecuting
        }
        set {
            willChangeValue(for: \.isExecuting)
            _isExecuting = newValue
            didChangeValue(for: \.isExecuting)
        }
    }

    private var _isFinished = false
    override var isFinished: Bool {
        get {
            _isFinished
        }
        set {
            willChangeValue(for: \.isFinished)
            _isFinished = newValue
            didChangeValue(for: \.isFinished)
        }
    }

    init(wrapper: SensorWrapper, loader: AQILoader) {
        self.loader = loader
        self.wrapper = wrapper
    }

    override func start() {
        guard !isCancelled else {
            logger.debug("SensorOperation cancelled")
            isFinished = true
            return
        }

        if let sensor = wrapper.sensor, !sensor.shouldRefresh {
            logger.debug("SensorOperation already loaded")
            isFinished = true
            return
        }

        if wrapper.didFail {
            logger.debug("SensorOperation previously failed")
            isFinished = true
            return
        }

        isExecuting = true

        self.dataTask = loader.loadSensor(from: wrapper.info) { result in
            switch result {
            case .success(let sensor):
                self.wrapper.sensor = sensor
                logger.debug("SensorOperation loaded sensor")
            case .failure(let error):
                self.wrapper.didFail = true
                logger.debug("SensorOperation failed to load sensor \(self.wrapper.info.id): \(error.localizedDescription)")
            }

            self.isExecuting = false
            self.isFinished = true
        }
    }

    override func cancel() {
        if let dataTask = dataTask {
            logger.debug("SensorOperation cancelling data task")
            dataTask.cancel()
        }
    }
}

private extension Sensor {
    var shouldRefresh: Bool {
        let shouldRefresh = Date().timeIntervalSince(age) > 2 * 60
        logger.debug("SensorOperation sensor age: \(Date().timeIntervalSince(age)) should refresh: \(shouldRefresh)")
        return shouldRefresh
    }
}

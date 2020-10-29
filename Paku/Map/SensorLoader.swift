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

    func loadAnnotations(in area: MKMapRect, didLoadSensor: @escaping (Sensor) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.queue.cancelAllOperations()

            self.loadSensorsIfNeeded {
                let sensors = self.sensors
                    .filter {
                        let point = MKMapPoint($0.info.location.coordinate)
                        return area.contains(point)
                    }
                    .shuffled()
                    .prefix(300)

                print("-- Loading \(sensors.count) sensors out of \(self.sensors.count)")

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
        if sensors.isEmpty {
            loader.loadSensors { result in
                switch result {
                case .success(let infos):
                    self.sensors = infos.filter(\.isOutdoor).map(SensorWrapper.init)
                case .failure(let error):
                    print("Failed to load sensor info: \(error)")
                }

                completion()
            }
        } else {
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
            print("-- Operation cancelled")
            isFinished = true
            return
        }

        if let sensor = wrapper.sensor, !sensor.shouldRefresh {
            print("-- Already loaded")
            isFinished = true
            return
        }

        if wrapper.didFail {
            print("-- Already failed")
            isFinished = true
            return
        }

        isExecuting = true

        loader.loadSensor(from: wrapper.info) { result in
            switch result {
            case .success(let sensor):
                self.wrapper.sensor = sensor
                print("-- Loaded sensor")
            case .failure(let error):
                self.wrapper.didFail = true
                print("-- Failed to load")
                print("Failed to load sensor \(self.wrapper.info.id): \(error)")
            }

            self.isExecuting = false
            self.isFinished = true
        }
    }
}

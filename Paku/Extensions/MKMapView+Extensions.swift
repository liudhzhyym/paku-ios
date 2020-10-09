//
//  MKMapView+Extensions.swift
//  Paku
//
//  Created by Kyle Bashour on 10/9/20.
//

import MapKit

extension MKMapView {

    func register<T: MKAnnotationView>(_ annotation: T.Type) {
        register(annotation, forAnnotationViewWithReuseIdentifier: String(describing: T.reuseIdentifier))
    }

    func dequeue<T: MKAnnotationView>(for annotation: MKAnnotation) -> T {
        guard let annotation = dequeueReusableAnnotationView(withIdentifier: String(describing: T.reuseIdentifier), for: annotation) as? T else {
            fatalError("Unable to dequeue annotation of type \(T.self)")
        }

        return annotation
    }
}

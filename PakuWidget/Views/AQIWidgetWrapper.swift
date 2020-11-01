//
//  AQIWidgetWrapper.swift
//  PakuWidget
//
//  Created by Kyle Bashour on 10/6/20.
//

import SwiftUI
import WidgetKit

struct AQIWidgetWrapper<Wrapped: View>: View {
    var entry: SimpleEntry
    var build: (SimpleEntry.Info) -> Wrapped

    var body: some View {
        if let info = entry.info {
            build(info)
        } else {
            WidgetErrorView(missingPermissions: LocationManager.shared.status != .authorizedAlways)
        }
    }
}

//struct AQIWidgetWrapper_Previews: PreviewProvider {
//    static var previews: some View {
//        AQIWidgetWrapper(entry: SimpleEntry(date: Date(), sensor: nil)) { sensor in
//            AQIBarWidgetView(sensor: sensor)
//        }
//        .previewContext(WidgetPreviewContext(family: .systemSmall))
//    }
//}

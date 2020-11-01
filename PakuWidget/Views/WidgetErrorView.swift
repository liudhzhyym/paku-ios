//
//  WidgetErrorView.swift
//  PakuWidget
//
//  Created by Kyle Bashour on 10/31/20.
//

import SwiftUI
import WidgetKit

struct WidgetErrorView: View {

    var missingPermissions: Bool

    private var errorText: String {
        if missingPermissions {
            return "Failed to update. This widget works best with location permissions set to Always."
        } else {
            return "Oh no, we couldn’t reach PurpleAir! Try opening the app to refresh."
        }
    }

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
            HStack {
                VStack(alignment: .leading) {
                    Spacer()

                    Text(errorText)
                        .foregroundColor(Color(UIColor.label))
                        .font(.caption)

                    Spacer()

                    Text("Open Paku →")
                        .font(.caption)
                        .foregroundColor(.blue)

                    Spacer()
                }
                Spacer()
            }.padding()
        }
    }
}

struct WidgetErrorView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetErrorView(missingPermissions: true)
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        WidgetErrorView(missingPermissions: false)
            .environment(\.colorScheme, .dark)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

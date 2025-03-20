//
//  ScrumProgressViewStyle.swift
//  Scrumdinger
//
//  Created by Auwfar on 17/03/25.
//

import SwiftUI

struct ScrumProgressViewStyle: ProgressViewStyle {
    var theme: Theme
    
    func makeBody(configuration: Configuration) -> some View {
        ProgressView(configuration)
            .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            .accentColor(theme.mainColor)
            .background(theme.accentColor)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .cornerRadius(16)
    }
}

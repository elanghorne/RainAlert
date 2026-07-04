//
//  ForecastView.swift
//  RainAlert
//
//  Created by Eric Langhorne on 7/3/26.
//

import SwiftUI

struct ForecastView: View {
    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()
            
            Text("Customize Daily Forecast")
                .font(.system(size: 25, weight: .semibold))
                .foregroundColor(.black)
        }
    }
}

#Preview {
    ForecastView()
}

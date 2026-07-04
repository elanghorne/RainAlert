//
//  LocationView.swift
//  RainAlert
//
//  Created by Eric Langhorne on 7/3/26.
//

import SwiftUI

struct LocationView: View {
    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()
            
            Text("Select Significant Locations")
                .font(.system(size: 25, weight: .semibold))
                .foregroundColor(.black)
        }
    }
}

#Preview {
    LocationView()
}

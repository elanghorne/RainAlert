//
//  ScheduleView.swift
//  RainAlert
//
//  Created by Eric Langhorne on 7/3/26.
//

import SwiftUI

struct ScheduleView: View {
    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()
            
            Text("Customize Notification Schedule")
                .font(.system(size: 25, weight: .semibold))
                .foregroundColor(.black)
        }
    }
}

#Preview {
    ScheduleView()
}

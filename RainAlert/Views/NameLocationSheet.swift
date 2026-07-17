//
//  NameLocationSheet.swift
//  RainAlert
//
//  Created by Eric Langhorne on 7/14/26.
//

import SwiftUI


struct NameLocationSheet: View {
    var locationModel: LocationModel
    @Environment(\.dismiss) var dismiss
    
    @State var name: String = ""
    
    var body: some View {
        NavigationStack {

            VStack {
                Text("Name")
                TextField("Name your location", text: $name)
            }
            .onAppear {
                name = "Location \(locationModel.significantLocations.count + 1)"
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        locationModel.significantLocations[locationModel.significantLocations.count - 1].name = name
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                }
            }
        }
    }
}
    


#Preview {
    NameLocationSheet(locationModel:dummyLocationModel)
}

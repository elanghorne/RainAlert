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
                Text("Enter a name for this location")
                    .foregroundColor(.white)
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Name your location", text: $name)
                        .foregroundColor(.white)
                }
                .padding(.vertical, 12)
                .padding(.horizontal)
                .background {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(.gray)
                        .frame(width: 200, height: 100)
                }
                .padding(.vertical, 10)
            }
            .onAppear {
                name = "Location \(locationModel.significantLocations.count)"
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
            .presentationDetents([.fraction(0.3)])
        }
    }
}
    


#Preview {
    NameLocationSheet(locationModel:dummyLocationModel)
}

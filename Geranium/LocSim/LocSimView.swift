//
//  LocSimView.swift
//  Geranium
//
//  Created by cclerc on 21.12.23.
//

import SwiftUI
import CoreLocation
import AlertKit

struct LocSimView: View {
    @StateObject private var appSettings = AppSettings()
    
    @State private var locationManager = CLLocationManager()
    @State private var lat: Double = 0.0
    @State private var long: Double = 0.0
    @State private var tappedCoordinate: EquatableCoordinate? = nil
    @State private var bookmarkSheetTggle: Bool = false
    var body: some View {
            if #available(iOS 16.0, *) {
                NavigationStack {
                    LocSimMainView()
                }
            } else {
                NavigationView {
                    LocSimMainView()
                }
            }
        }
    @ViewBuilder
        private func LocSimMainView() -> some View {
            VStack {
                CustomMapView(tappedCoordinate: $tappedCoordinate)
                    .onAppear {
                        CLLocationManager().requestAlwaysAuthorization()
                    }
            }
            .ignoresSafeArea(.keyboard)
        .onAppear {
            LocationModel().requestAuthorisation()
        }
        .onChange(of: tappedCoordinate) { newValue in
            if let coordinate = newValue {
                lat = coordinate.coordinate.latitude
                long = coordinate.coordinate.longitude
                LocSimManager.startLocSim(location: .init(latitude: lat, longitude: long))
                AlertKitAPI.present(
                    title: "Started !",
                    icon: .done,
                    style: .iOS17AppleMusic,
                    haptic: .success
                )
            }
        }
        .toolbar{
            ToolbarItem(placement: .navigationBarLeading) {
                Text("LocSim")
                    .font(.title2)
                    .bold()
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    UIApplication.shared.TextFieldAlert(
                        title: "Enter Coordinates",
                        message: "The location will be simulated on device\nPro tip: Press wherever on the map to move there.",
                        textFieldPlaceHolder: "Latitude",
                        secondTextFieldPlaceHolder: "Longitude"
                    ) { latText, longText in
                        if let latDouble = Double(latText ?? ""), let longDouble = Double(longText ?? "") {
                            lat = latDouble
                            long = longDouble
                            LocSimManager.startLocSim(location: .init(latitude: latDouble, longitude: longDouble))
                        } else {
                            UIApplication.shared.alert(body: "Those are invalid coordinates mate !")
                        }
                    }
                }) {
                    Image(systemName: "mappin")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    if appSettings.locSimMultipleAttempts {
                        var countdown = appSettings.locSimAttemptNB
                        DispatchQueue.global().async {
                            while countdown > 0 {
                                LocSimManager.stopLocSim()
                                countdown -= 1
                            }
                        }
                    }
                    else {
                        LocSimManager.stopLocSim()
                    }
                    AlertKitAPI.present(
                        title: "Stopped !",
                        icon: .done,
                        style: .iOS17AppleMusic,
                        haptic: .success
                    )
                }) {
                    Image(systemName: "location.slash")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    bookmarkSheetTggle.toggle()
                }) {
                    Image(systemName: "bookmark")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                }
            }
        }
        .sheet(isPresented: $bookmarkSheetTggle) {
            BookMarkSlider(lat: $lat, long: $long)
        }
    }
}

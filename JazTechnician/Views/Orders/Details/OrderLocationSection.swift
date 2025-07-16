//
//  OrderLocationSection.swift
//  JazTechnician
//
//  Created by Karim OTHMAN on 16.07.2025.
//

import SwiftUI
import MapKit

struct OrderLocationSection: View {
    let address: String
    let lat: Double
    let lng: Double
    @State private var region: MKCoordinateRegion
    @State private var showFullMap = false

    init(address: String, lat: Double, lng: Double) {
        self.address = address
        self.lat = lat
        self.lng = lng
        _region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: lat, longitude: lng),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center) {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(.primary())
                Text("الموقع الجغرافي")
                    .customFont(weight: .medium, size: 14)
                    .foregroundColor(.primaryDark())
                Spacer()
                Button(action: { showFullMap = true }) {
                    HStack(spacing: 3) {
                        Image(systemName: "map")
                        Text("عرض على الخريطة")
                            .customFont(weight: .medium, size: 12)
                    }
                    .foregroundColor(.blue0094FF())
                }
                .buttonStyle(.plain)
            }

            Text(address)
                .customFont(weight: .regular, size: 13)
                .foregroundColor(.grayA1A1A1())
                .lineLimit(2)
                .padding(.bottom, 2)

            Map(coordinateRegion: $region, annotationItems: [OrderMapPin(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng))]) { pin in
                MapMarker(coordinate: pin.coordinate, tint: .dangerNormal())
            }
            .frame(height: 100)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.grayE6E6E6(), lineWidth: 1)
            )
        }
        .padding(12)
        .background(Color.backgroundFEF3DE())
        .cornerRadius(14)
        .sheet(isPresented: $showFullMap) {
            FullScreenMapView(address: address, lat: lat, lng: lng)
        }
    }

    struct OrderMapPin: Identifiable {
        let id = UUID()
        let coordinate: CLLocationCoordinate2D
    }
}

struct FullScreenMapView: View {
    let address: String
    let lat: Double
    let lng: Double
    @Environment(\.dismiss) var dismiss

    @State private var region: MKCoordinateRegion

    init(address: String, lat: Double, lng: Double) {
        self.address = address
        self.lat = lat
        self.lng = lng
        _region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: lat, longitude: lng),
            span: MKCoordinateSpan(latitudeDelta: 0.004, longitudeDelta: 0.004)
        ))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Map(coordinateRegion: $region, annotationItems: [
                    OrderLocationSection.OrderMapPin(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng))
                ]) { pin in
                    MapMarker(coordinate: pin.coordinate, tint: .dangerNormal())
                }
                .edgesIgnoringSafeArea(.all)
                .overlay(
                    VStack {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("العنوان:")
                                    .customFont(weight: .medium, size: 14)
                                    .foregroundColor(.primaryDark())
                                Text(address)
                                    .customFont(weight: .regular, size: 13)
                                    .foregroundColor(.grayA1A1A1())
                                    .lineLimit(2)
                            }
                            Spacer()
                            Button(action: { dismiss() }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.grayA1A1A1())
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(12)
                        .shadow(radius: 2)
                        Spacer()
                    }
                    .padding(.top, 40)
                    .padding(.horizontal, 14)
                )
            }
            .navigationBarHidden(true)
        }
    }
}

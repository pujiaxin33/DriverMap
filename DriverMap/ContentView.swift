//
//  ContentView.swift
//  DriverMap
//
//  Created by Jiaxin Pu on 2024/11/13.
//

import SwiftUI
import GoogleMaps

struct ContentView: View {
    @StateObject private var viewModel = NavigationViewModel()
    
    var body: some View {
        ZStack {
            MapView(viewModel: viewModel)
                .edgesIgnoringSafeArea(.all)
            
            navigationControlArea
            
            planningRouteTips
        }
        .alert("Please select a destination before navigating", isPresented: $viewModel.isAlertPresented) {
            Button("I know") {}
        }
    }
    
    var navigationControlArea: some View {
        VStack {
            Spacer()
            
            if viewModel.isNavigating {
                NavigationInfoView(viewModel: viewModel)
            } else {
                Button(action: {
                    viewModel.startNavigation()
                }) {
                    Text("Start navigation")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
    }
    
    @ViewBuilder
    var planningRouteTips: some View {
        if viewModel.isPlanningRoute {
            ZStack {
                Color.black
                    .opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    ProgressView("The navigation path\n is planning ...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .tint(.red)
                        .foregroundColor(.red)
                        .font(.title3)
                        .scaleEffect(2)
                }
            }
        }
    }
}

struct NavigationInfoView: View {
    @ObservedObject var viewModel: NavigationViewModel
    
    var body: some View {
        VStack {
            Text("Navigating...")
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Duration: \(viewModel.tripDuration)")
                }
                .padding()
                
                Button(action: {
                    viewModel.stopNavigation()
                }) {
                    Text("Finish")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }
            }
            .background(Color.white.opacity(0.9))
            .cornerRadius(15)
        }
    }
}

#Preview {
    ContentView()
}

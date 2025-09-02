import SwiftUI
import AuthenticationServices

struct HomeView<Content>: View where Content: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @StateObject private var locationManager = LocationManager()
    @StateObject private var weatherManager = WeatherManager()
    @StateObject private var closetViewModel = ClosetViewModel()
    
    @ViewBuilder var content: () -> Content
    
    enum Tab {
        case closet, add, profile
    }
    
    @State private var selectedTab: Tab = .closet

    var body: some View {
        ZStack(alignment: .bottom) {
            content()
            
            currentTabView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground))

            tabBar
        }
        .onAppear {
            locationManager.requestLocationPermission()
        }
        .onChange(of: locationManager.location) { oldValue, newValue in
            guard let location = newValue else { return }
            Task {
                await weatherManager.fetchWeather(for: location)
            }
        }
        .onChange(of: weatherManager.currentWeather) { oldValue, newValue in
            // Once we have weather, fetch data for the closet
            if newValue != nil {
                closetViewModel.fetchData(weather: newValue)
            }
        }
        .onChange(of: selectedTab) { oldTab, newTab in
             // If we switch back to the closet and have weather, refresh data
            if newTab == .closet, let weather = weatherManager.currentWeather {
                closetViewModel.fetchData(weather: weather)
            }
        }
    }

    @ViewBuilder
    private var currentTabView: some View {
        switch selectedTab {
        case .closet:
            ClosetView(viewModel: closetViewModel, weatherManager: weatherManager)
        case .add:
            ClothingUploadView()
        case .profile:
            UserProfileView()
        }
    }

    private var tabBar: some View {
        HStack {
            Spacer()
            tabBarButton(tab: .closet, systemImage: "tshirt.fill", text: "Closet")
            Spacer()
            addButton
            Spacer()
            tabBarButton(tab: .profile, systemImage: "person.crop.circle", text: "Profile")
            Spacer()
        }
        .padding(.top, 10)
        .background(Color.white.ignoresSafeArea(edges: .bottom))
        .shadow(color: .gray.opacity(0.2), radius: 5, y: -2)
    }

    private func tabBarButton(tab: Tab, systemImage: String, text: String) -> some View {
        Button(action: { selectedTab = tab }) {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.title2)
                Text(text).font(.caption2)
            }
        }
        .foregroundColor(selectedTab == tab ? .blue : .gray)
    }

    private var addButton: some View {
        Button(action: { selectedTab = .add }) {
            ZStack {
                Circle()
                    .foregroundColor(.blue)
                    .frame(width: 56, height: 56)
                    .shadow(radius: 4)
                Image(systemName: "plus")
                    .foregroundColor(.white)
                    .font(.system(size: 24, weight: .bold))
            }
        }
        .offset(y: -15)
    }
}

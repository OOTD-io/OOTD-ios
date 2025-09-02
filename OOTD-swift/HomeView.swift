import SwiftUI
import AuthenticationServices

struct HomeView<Content>: View where Content: View {
    @StateObject private var viewModel = AuthenticationViewModel()
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
            // Initial data fetch when the view first appears
            closetViewModel.fetchData(weatherManager: weatherManager)
        }
        .onChange(of: selectedTab) { oldTab, newTab in
            // Fetch data only when switching back to the closet tab
            if newTab == .closet && oldTab != .closet {
                closetViewModel.fetchData(weatherManager: weatherManager)
            }
        }
        .onChange(of: locationManager.location) { oldValue, newValue in
            guard let location = newValue else { return }
            Task {
                await weatherManager.fetchWeather(for: location)
            }
        }
    }

    @ViewBuilder
    private var currentTabView: some View {
        switch selectedTab {
        case .closet:
            VStack {
                if let weather = weatherManager.currentWeather {
                    WeatherCard(weather: weather)
                        .padding(.vertical, 8)
                } else if let errorMessage = weatherManager.errorMessage {
                    VStack {
                        Text("Weather Error").font(.headline).foregroundColor(.red)
                        Text(errorMessage).font(.caption).foregroundColor(.red)
                    }
                    .padding()
                } else {
                    Text("Loading weather…").foregroundColor(.gray)
                }
                ClosetView(viewModel: closetViewModel, weatherManager: weatherManager)
            }
        case .add:
            ClothingUploadView()
        case .profile:
            NavigationView {
              UserProfileView()
                .environmentObject(viewModel)
            }
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
        .padding(.vertical, 10)
        .background(Color.white.ignoresSafeArea(edges: .bottom))
        .shadow(color: .gray.opacity(0.2), radius: 5, y: -2)
    }

    private func tabBarButton(tab: Tab, systemImage: String, text: String) -> some View {
        Button(action: { selectedTab = tab }) {
            VStack {
                Image(systemName: systemImage)
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
    }
}

#Preview {
    HomeView {
        Text("Content")
    }
}

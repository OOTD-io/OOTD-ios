import SwiftUI
import AuthenticationServices
import WeatherKit

struct HomeView<Content>: View where Content: View {
    @StateObject private var authViewModel = AuthenticationViewModel()
    @StateObject private var closetViewModel = ClosetViewModel()
    @StateObject private var locationManager = LocationManager()
    @StateObject private var weatherManager = WeatherManager()
    
    @ViewBuilder var content: () -> Content
    
    enum Tab {
        case closet, add, profile
    }
    
    @State private var selectedTab: Tab = .closet

    var body: some View {
        ZStack(alignment: .bottom) {
            content()

            // Main content based on selected tab
            Group {
                switch selectedTab {
                case .closet:
                    ClosetView(viewModel: closetViewModel, weather: weatherManager.currentWeather, weatherError: weatherManager.errorMessage)
                        .onAppear {
                            locationManager.requestLocationPermission()
                            Task {
                                await closetViewModel.fetchClothes()
                            }
                        }
                        .task(id: locationManager.location) { location in
                            // When location changes, fetch the weather.
                            if let location = location {
                                await weatherManager.fetchWeather(for: location)
                            }
                        }
                        .task(id: weatherManager.currentWeather) { weather in
                            // When weather changes, generate outfits.
                            if let weather = weather {
                                let weatherRequest = WeatherRequest(
                                    temperature: weather.temperature.converted(to: .fahrenheit).value,
                                    condition: weather.condition.description
                                )
                                await closetViewModel.generateOutfits(weather: weatherRequest)
                            }
                        }
                    
                case .add:
                    ClothingUploadView()
                case .profile:
                    NavigationView {
                        UserProfileView()
                            .environmentObject(authViewModel)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
            
            // Custom Tab Bar
            HStack {
                Spacer()
                Button(action: { selectedTab = .closet }) {
                    VStack {
                        Image(systemName: "tshirt.fill")
                        Text("Closet").font(.caption2)
                    }
                }
                .foregroundColor(selectedTab == .closet ? .blue : .gray)
                Spacer()
                Button(action: { selectedTab = .add }) {
                    ZStack {
                        Circle().foregroundColor(.blue).frame(width: 56, height: 56).shadow(radius: 4)
                        Image(systemName: "plus").foregroundColor(.white).font(.system(size: 24, weight: .bold))
                    }
                }
                Spacer()
                Button(action: { selectedTab = .profile }) {
                    VStack {
                        Image(systemName: "person.crop.circle")
                        Text("Profile").font(.caption2)
                    }
                }
                .foregroundColor(selectedTab == .profile ? .blue : .gray)
                Spacer()
            }
            .padding(.vertical, 10)
            .background(Color.white.ignoresSafeArea(edges: .bottom))
            .shadow(color: .gray.opacity(0.2), radius: 5, y: -2)
            .offset(y:30)
        }
    }
}

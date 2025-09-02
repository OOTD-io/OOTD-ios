import SwiftUI

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @EnvironmentObject var authViewModel: AuthenticationViewModel

    var body: some View {
        AuthenticatedView {
            AuthenticationView()
        } content: {
            HomeView {
                // This content is not used in the current HomeView implementation
                // but is here to satisfy the generic constraint.
                EmptyView()
            }
            .environmentObject(authViewModel)
        }
        .onAppear {
            locationManager.requestLocationPermission()
        }
        .sheet(isPresented: $authViewModel.needsPasswordReset) {
            ResetPasswordView()
                .environmentObject(authViewModel)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthenticationViewModel())
}

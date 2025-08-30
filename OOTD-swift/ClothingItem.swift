import SwiftUI

// This enum's cases now directly map to the backend's `type` literals.
// The rawValue is what will be displayed in the UI.
enum ClothingCategory: String, CaseIterable {
    case top = "Tops"
    case bottom = "Bottoms"
    case dress = "Dresses"
    case shoes = "Shoes"
    case outerwear = "Outerwear"
    case accessory = "Accessories"
    case unknown = "Other"
}

struct ClothingItem: Identifiable {
    let id: String
    let category: String // This is the raw 'type' string from the API
    let name: String
    let size: String
    let imageURL: URL?
    let sceneImage: String?

    // This computed property now performs a direct mapping.
    var uiCategory: ClothingCategory {
        // We initialize the enum from the raw string from the API.
        // If the string from the API doesn't match a known case, it defaults to .unknown.
        // This is much more robust than a switch statement with hardcoded strings.
        switch category.lowercased() {
            case "top": return .top
            case "bottom": return .bottom
            case "dress": return .dress
            case "shoes": return .shoes
            case "outerwear": return .outerwear
            case "accessory": return .accessory
            default: return .unknown
        }
    }
}

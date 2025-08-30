import SwiftUI

enum ClothingCategory: String, CaseIterable {
    case tops = "Tops"
    case bottoms = "Bottoms"
    case dresses = "Dresses" // Added
    case outerwear = "Outerwear"
    case shoes = "Shoes"
    case accessories = "Accessories"
    case other = "Other"
}

struct ClothingItem: Identifiable {
    let id: String
    let category: String // This comes from the API's 'type' field
    let name: String
    let size: String
    let imageURL: URL?
    let sceneImage: String?

    var uiCategory: ClothingCategory {
        let lowercasedCategory = category.lowercased()

        switch lowercasedCategory {
        // Tops
        case "t-shirt", "shirt", "blouse", "top", "tank top", "polo shirt", "henley", "sweater", "sweatshirt", "hoodie":
            return .tops
        // Bottoms
        case "jeans", "pants", "trousers", "shorts", "skirt", "leggings", "jeggings", "sweatpants":
            return .bottoms
        // Dresses
        case "dress", "sundress", "gown":
            return .dresses
        // Outerwear
        case "jacket", "coat", "vest", "blazer", "windbreaker", "cardigan":
            return .outerwear
        // Shoes
        case "shoes", "sneakers", "boots", "sandals", "heels", "flats", "loafers":
            return .shoes
        // Accessories
        case "hat", "cap", "beanie", "scarf", "gloves", "belt", "tie", "sunglasses", "watch", "jewelry", "bag", "backpack":
            return .accessories
        // Default
        default:
            return .other
        }
    }
}

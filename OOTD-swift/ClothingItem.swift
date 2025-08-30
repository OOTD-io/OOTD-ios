import SwiftUI

enum ClothingCategory: String, CaseIterable {
    case tops = "Tops"
    case bottoms = "Bottoms"
    case shoes = "Shoes"
    case accessories = "Accessories"
    case outerwear = "Outerwear"
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
        switch category.lowercased() {
        case "t-shirt", "shirt", "blouse", "top", "tank top", "polo shirt", "henley", "sweater", "sweatshirt", "hoodie":
            return .tops
        case "jeans", "pants", "trousers", "shorts", "skirt", "leggings", "jeggings", "sweatpants":
            return .bottoms
        case "shoes", "sneakers", "boots", "sandals", "heels", "flats", "loafers":
            return .shoes
        case "hat", "cap", "beanie", "scarf", "gloves", "belt", "tie", "sunglasses", "watch", "jewelry", "bag", "backpack":
            return .accessories
        case "jacket", "coat", "vest", "blazer", "windbreaker", "cardigan":
            return .outerwear
        default:
            return .other
        }
    }
}

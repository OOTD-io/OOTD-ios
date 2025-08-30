import Foundation

// A view model to represent a fully resolved outfit,
// containing the actual ClothingItem objects ready for display.
struct OutfitViewModel: Identifiable {
    let id = UUID()
    let tops: [ClothingItem]
    let bottoms: [ClothingItem]
    let shoes: [ClothingItem]
    let outerwear: [ClothingItem]
    let accessories: [ClothingItem]
}

import Foundation

struct CachedOutfits: Codable {
    let timestamp: Date
    let outfits: [OutfitResponseDTO]
}

class OutfitCacheManager {
    static let shared = OutfitCacheManager()
    private let userDefaults = UserDefaults.standard
    private let cacheKey = "cachedGeneratedOutfits"
    private let cacheDuration: TimeInterval = 6 * 60 * 60 // 6 hours in seconds

    private init() {}

    func saveOutfits(_ outfits: [OutfitResponseDTO]) {
        let cacheEntry = CachedOutfits(timestamp: Date(), outfits: outfits)
        do {
            let data = try JSONEncoder().encode(cacheEntry)
            userDefaults.set(data, forKey: cacheKey)
            print("[OutfitCacheManager] Successfully saved \(outfits.count) outfits to cache.")
        } catch {
            print("[OutfitCacheManager] Failed to encode and save outfits: \(error)")
        }
    }

    func loadOutfits() -> (outfits: [OutfitResponseDTO], isStale: Bool)? {
        guard let data = userDefaults.data(forKey: cacheKey) else {
            print("[OutfitCacheManager] No cached outfits found.")
            return nil
        }

        do {
            let cacheEntry = try JSONDecoder().decode(CachedOutfits.self, from: data)
            let isStale = Date().timeIntervalSince(cacheEntry.timestamp) > cacheDuration
            print("[OutfitCacheManager] Loaded \(cacheEntry.outfits.count) outfits from cache. Stale: \(isStale)")
            return (cacheEntry.outfits, isStale)
        } catch {
            print("[OutfitCacheManager] Failed to decode cached outfits: \(error)")
            // If decoding fails, the cache is corrupt, so remove it.
            userDefaults.removeObject(forKey: cacheKey)
            return nil
        }
    }

    func clearCache() {
        userDefaults.removeObject(forKey: cacheKey)
        print("[OutfitCacheManager] Cache cleared.")
    }
}

import Foundation

extension String {
    func titlecased() -> String {
        return self.replacingOccurrences(of: "_", with: " ").capitalized
    }
}

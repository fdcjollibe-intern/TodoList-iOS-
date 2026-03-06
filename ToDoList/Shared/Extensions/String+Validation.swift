// Shared/Extensions/String+Validation.swift

import Foundation

extension String {
    /// Checks if the string is a valid email format
    var isValidEmail: Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
    
    /// Checks if the string is a valid password (min 6 characters)
    var isValidPassword: Bool {
        return self.count >= 6
    }
    
    /// Checks if the string is not empty after trimming whitespace
    var isNotEmpty: Bool {
        return !self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// Returns trimmed string (removes leading/trailing whitespace)
    var trimmed: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

//
//  String+Validation.swift
//  ToDoList
//
//  Created by Jollibe Dablo - INTERN on 3/6/26.
//
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
    
    /// Checks if the string is a strong password (min 8 chars, 1 uppercase, 1 lowercase, 1 number)
    var isStrongPassword: Bool {
        guard self.count >= 8 else { return false }
        
        let uppercaseRegex = ".*[A-Z]+.*"
        let lowercaseRegex = ".*[a-z]+.*"
        let numberRegex = ".*[0-9]+.*"
        
        let uppercasePredicate = NSPredicate(format: "SELF MATCHES %@", uppercaseRegex)
        let lowercasePredicate = NSPredicate(format: "SELF MATCHES %@", lowercaseRegex)
        let numberPredicate = NSPredicate(format: "SELF MATCHES %@", numberRegex)
        
        return uppercasePredicate.evaluate(with: self) &&
               lowercasePredicate.evaluate(with: self) &&
               numberPredicate.evaluate(with: self)
    }
    
    /// Returns password strength message
    var passwordStrengthMessage: String {
        if self.isEmpty {
            return ""
        } else if self.count < 6 {
            return "Password must be at least 6 characters"
        } else if self.count < 8 {
            return "Password is weak. Consider adding more characters"
        } else if !self.isStrongPassword {
            return "Password should contain uppercase, lowercase, and numbers"
        } else {
            return "Password is strong"
        }
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

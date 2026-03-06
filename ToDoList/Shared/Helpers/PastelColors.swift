//
//  PastelColors.swift
//  ToDoList
//
//  Created by Jollibe Dablo - INTERN on 3/6/26.
//

import Foundation

struct PastelColors {
    static let all = [
        "#DDD6FE", // Pastel Purple
        "#FED7D7", // Pastel Pink
        "#FEF3C7", // Pastel Yellow
        "#DBEAFE", // Pastel Blue
        "#D1FAE5", // Pastel Green
        "#FECACA", // Pastel Red
        "#E0E7FF", // Pastel Indigo
        "#FCE7F3"  // Pastel Rose
    ]
    
    static func random() -> String {
        return all.randomElement() ?? "#DDD6FE"
    }
}

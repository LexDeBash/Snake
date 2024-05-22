//
//  StorageManager.swift
//  Snake
//
//  Created by Alexey Efimov on 21.05.2024.
//

import SwiftUI

final class StorageManager {
    static let shared = StorageManager()
    
    @AppStorage(wrappedValue: 0, "highScore") private var highScore: Int
    
    private init() {}
    
    var getHighScore: Int {
        highScore
    }
    
    func setHighScore(_ value: Int) {
        highScore = value
    }
}

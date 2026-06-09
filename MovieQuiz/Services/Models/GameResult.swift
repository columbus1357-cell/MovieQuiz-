//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Aleksandr on 10.06.2026.
//

import Foundation

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    func isBetterThan(_ another: GameResult) -> Bool {
        return self.correct > another.correct
    }
}

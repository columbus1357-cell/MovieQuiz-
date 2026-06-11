//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Aleksandr on 10.06.2026.
//

import Foundation

protocol StatisticServiceProtocol {
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameResult { get }

    func store(correct count: Int, total amount: Int)
}

//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Aleksandr on 10.06.2026.
//

import Foundation

final class StatisticService: StatisticServiceProtocol {
    
    // Наше приватное хранилище (убрали дублирование UserDefaults.standard)
    private let storage: UserDefaults = .standard
    
    // Перечисление со всеми ключами для UserDefaults
    private enum Keys: String {
        case gamesCount
        case bestGameCorrect
        case bestGameTotal
        case bestGameDate
        case totalCorrectAnswers
        case totalQuestionsAsked
    }
    
    // MARK: - Protocol Properties
    
    // Счетчик сыгранных игр
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    // Лучшая игра за всё время
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            let date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    // Средняя точность в процентах
    var totalAccuracy: Double {
        let totalCorrect = storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        let totalAsked = storage.integer(forKey: Keys.totalQuestionsAsked.rawValue)
        
        guard totalAsked > 0 else { return 0.0 }
        
        // Считаем отношение и переводим в проценты
        return (Double(totalCorrect) / Double(totalAsked)) * 100
    }
    
    // MARK: - Methods
    
    func store(correct count: Int, total amount: Int) {
        // 1. Увеличиваем счетчик сыгранных игр
        gamesCount += 1
        
        // 2. Складываем новые правильные ответы и заданные вопросы к накопительным счетчикам
        let totalCorrect = storage.integer(forKey: Keys.totalCorrectAnswers.rawValue) + count
        let totalAsked = storage.integer(forKey: Keys.totalQuestionsAsked.rawValue) + amount
        
        storage.set(totalCorrect, forKey: Keys.totalCorrectAnswers.rawValue)
        storage.set(totalAsked, forKey: Keys.totalQuestionsAsked.rawValue)
        
        // 3. Проверяем, побит ли рекорд
        let newGameResult = GameResult(correct: count, total: amount, date: Date())
        if newGameResult.isBetterThan(bestGame) {
            bestGame = newGameResult
        }
    }
}

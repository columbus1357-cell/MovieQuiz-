//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Aleksandr on 10.07.2026.
//

import Foundation
protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    func showAnswerResult(isCorrect: Bool)
    func setLoading(_ isLoading: Bool) 
    func showNetworkError(message: String)
}

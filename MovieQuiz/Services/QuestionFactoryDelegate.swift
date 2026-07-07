//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Aleksandr on 02.07.2026.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}

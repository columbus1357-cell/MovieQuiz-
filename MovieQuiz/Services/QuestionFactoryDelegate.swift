//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Aleksandr on 10.06.2026.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}

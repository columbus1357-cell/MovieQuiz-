//
//  Test.swift
//  MovieQuizTests
//
//  Created by Aleksandr on 10.07.2026.
//

import XCTest
@testable import MovieQuiz

// 1. Создаем Мок-объект для тестирования, соответствующий нашему новому протоколу
final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func show(quiz step: QuizStepViewModel) {}
    func show(quiz result: QuizResultsViewModel) {}
    func showAnswerResult(isCorrect: Bool) {}
    func setLoading(_ isLoading: Bool) {}
    func showNetworkError(message: String) {}
}

// 2. Сам класс с тестами
final class MovieQuizPresenterTests: XCTestCase {
    
    func testPresenterConvertModel() throws {
        // Given (Дано)
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock) // sut — System Under Test
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        
        // When (Когда происходит действие)
        let viewModel = sut.convert(model: question)
        
        // Then (Тогда проверяем результат через Assert'ы)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}

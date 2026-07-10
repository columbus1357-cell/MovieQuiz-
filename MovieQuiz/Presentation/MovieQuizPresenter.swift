//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Aleksandr on 10.07.2026.
//

import Foundation

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    // MARK: - Private Properties
    private var questionFactory: QuestionFactoryProtocol?
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    
    // MARK: - Public Properties
    weak var viewController: MovieQuizViewControllerProtocol?
    let statisticService: StatisticServiceProtocol = StatisticService()
    var currentQuestion: QuizQuestion?
    var correctAnswers: Int = 0
    
    // MARK: - Initializer
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        viewController?.setLoading(false)
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.setLoading(false)
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: - Public Methods
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: model.image,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    
    func requestNextQuestion() {
        questionFactory?.requestNextQuestion()
    }
    
    // MARK: - Private Methods
    private func didAnswer(isYes: Bool) {
        guard let  currentQuestion else { return }
        let givenAnswer = isYes
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}

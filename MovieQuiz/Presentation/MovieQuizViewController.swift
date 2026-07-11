//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Aleksandr on 10.07.2026.
//
import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    private var presenter: MovieQuizPresenter!
    private var alertPresenter: ResultAlertPresenter?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(viewController: self)
        setupDependencies()
    }
    
    // MARK: - Public Methods
    
    // Отрисовка данных вопроса на экране
    func show(quiz step: QuizStepViewModel) {
        imageView.image = UIImage(data: step.image) ?? UIImage()
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    // Подсветка ответа кастомными цветами и запуск таймера на 1 секунду
    func showAnswerResult(isCorrect: Bool) {
        
        view.isUserInteractionEnabled = false
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        
        let correctColor = UIColor(resource: .ypGreen).cgColor
        let incorrectColor = UIColor(resource: .ypRed).cgColor
        
        imageView.layer.borderColor = isCorrect ? correctColor : incorrectColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            view.isUserInteractionEnabled = true
                presenter.showNextQuestionOrResults()
        }
    }
    
    // Управление индикатором загрузки
    func setLoading(_ isLoading: Bool) {
        activityIndicator.isHidden = !isLoading
        
        if isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    // Показ ошибки сети
    func showNetworkError(message: String) {
        let alertModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз",
            completion: { [weak self] in
                guard let self else { return }
                presenter.restartGame()
                setLoading(true)
            }
        )
        alertPresenter?.showAlert(model: alertModel)
    }
    
    // MARK: - Private Methods
    
    // Показ алерта с результатами раунда
    func show(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: { [weak self] in
                guard let self else { return }
                presenter.restartGame()
            }
        )
        alertPresenter?.showAlert(model: alertModel)
    }
    
    private func setupDependencies() {
        alertPresenter = ResultAlertPresenter(delegate: self)
    }
    
    // MARK: - IBActions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
}

import UIKit

final class MovieQuizViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: ResultAlertPresenter?
    private var statisticService: StatisticServiceProtocol?
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDependencies()
        
        setLoading(true)
        questionFactory?.loadData()
    }
    
    // MARK: - Private Methods
    
    // 1. Конвертация модели вопроса во ВьюМодель для экрана
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
        return questionStep
    }
    
    // 2. Отрисовка данных вопроса на экране
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    // 3. Показ алерта с результатами раунда
    private func show(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: { [weak self] in
                guard let self = self else { return }
                
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                
                self.questionFactory?.requestNextQuestion()
            }
        )
        
        alertPresenter?.showAlert(model: alertModel)
    }
    
    // 4. Подсветка ответа кастомными цветами и запуск таймера на 1 секунду
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        view.isUserInteractionEnabled = false
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        
        let correctColor = UIColor(resource: .ypGreen).cgColor
        let incorrectColor = UIColor(resource: .ypRed).cgColor
        
        imageView.layer.borderColor = isCorrect ? correctColor : incorrectColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            self.view.isUserInteractionEnabled = true
            self.showNextQuestionOrResults()
        }
    }
    
    // 5. Логика развилки: следующий вопрос или экран результатов
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            guard let statisticService = statisticService else { return }
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            
            let gamesCountText = "Количество сыгранных квизов: \(statisticService.gamesCount)"
            let bestGame = statisticService.bestGame
            let bestGameText = "Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))"
            let accuracyText = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
            
            let text = """
                Ваш result: \(correctAnswers)/\(questionsAmount)
                \(gamesCountText)
                \(bestGameText)
                \(accuracyText)
                """
            
            let resultsViewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз"
            )
            show(quiz: resultsViewModel)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
    // 6. Управление индикатором загрузки
    private func setLoading(_ isLoading: Bool) {
        activityIndicator.isHidden = !isLoading
        
        if isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    private func setupDependencies() {
        statisticService = StatisticService()
        alertPresenter = ResultAlertPresenter(delegate: self)
        questionFactory = QuestionFactory(
            moviesLoader: MoviesLoader(),
            delegate: self)
    }
    
    private func answerQuestion(with answer: Bool) {
        guard let currentQuestion else {return}
        
        showAnswerResult(
            isCorrect: currentQuestion.correctAnswer == answer
        )
    }
    
    // MARK: - IBActions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        answerQuestion(with: true)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        answerQuestion(with: false)
    }
}
// MARK: - QuestionFactoryDelegate
extension MovieQuizViewController: QuestionFactoryDelegate {
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            setLoading(false)
            show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        setLoading(false)
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        setLoading(false)
        
        let alertModel = AlertModel(
            title: "Ошибка",
            message: error.localizedDescription,
            buttonText: "Попробовать еще раз",
            completion: { [weak self] in
                guard let self else { return }
                
                currentQuestionIndex = 0
                correctAnswers = 0
                setLoading(true)
                questionFactory?.loadData()
            }
        )
        
        alertPresenter?.showAlert(model: alertModel)
    }
}

import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    
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
        
        // Настройка фабрики и связь через Делегат
        let factory = QuestionFactory()
        factory.delegate = self
        self.questionFactory = factory
        alertPresenter = ResultAlertPresenter(delegate: self)
        statisticService = StatisticService()
        
        // Запрашиваем первый вопрос
        questionFactory?.requestNextQuestion()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        // Безопасно обновляем UI на главном потоке
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // MARK: - Private Methods
    // 1. Конвертация модели вопроса во ВьюМодель для экрана
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(named: model.imageName) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.view.isUserInteractionEnabled = true
            self.showNextQuestionOrResults()
        }
    }
    
    // 5. Логика развилки: следующий вопрос или экран результатов
    private func showNextQuestionOrResults() {
            if currentQuestionIndex == questionsAmount - 1 {
                // 1. Сначала сохраняем результат текущей игры в сервис статистики
                guard let statisticService = statisticService else { return }
                statisticService.store(correct: correctAnswers, total: questionsAmount)
                
                // 2. Достаем обновленные данные для красивого текста
                let gamesCountText = "Количество сыгранных квизов: \(statisticService.gamesCount)"
                
                let bestGame = statisticService.bestGame
                let bestGameText = "Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))"
                
                let accuracyText = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
                
                // 3. Формируем финальный многострочный текст для алерта (\n — это перенос строки)
                let text = """
                Ваш результат: \(correctAnswers)/\(questionsAmount)
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
    
    // MARK: - IBActions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else { return }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else { return }
        showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
    }
}

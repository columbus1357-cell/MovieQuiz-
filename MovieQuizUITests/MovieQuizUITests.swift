//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Aleksandr on 09.07.2026.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
    
    // Свойство для управления нашим приложением
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        // Создаем обьект приложения
        app = XCUIApplication()
        // Запускаем его перед каждым тестом
        app.launch()
        // Если один тест упал, Xcode сразу остановит всю цепочку
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        // Закрываем приложение после каждого теста и зануляем переменную
        app.terminate()
        app = nil
        
    }
    
    // Тестируем кнопку Да
    func testYesButton() {
        // Ждем 3 секунды, пока загрузится самый первый фильм из интернета
        sleep(3)
        // Находим постер и делаем его скриншот в виде набора байт (Data)
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        // Находим кнопку Да по её ID и тапаем
        app.buttons["Yes"].tap()
        // Ждем еще 3 секунды, пока загрузиться следующий фильм
        sleep(3)
        // Делаем скриншот второго постера
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        // Находим наш лейбл с индексом (2/10)
        let indexLabel = app.staticTexts["Index"]
        // ПРОВЕРКА 1: Картинки должны быть разными
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        // ПРОВЕРКА 2: Текст индекса должен стать 2/10
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    // Тестируем кнопку нет
    func testNoButton() {
        sleep(3)
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    // Проверка финиша игры и содержимого алерта
    func testGameFinish() {
        sleep(2)
       
        // Быстро нажимаем на кнопку Да 10 раз подряд, чтобы завершить игру
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }
        
        // Находим алерт на экране по его уникальному ID
        let alert = app.alerts["Этот раунд окончен!"]
        
        // ПРОВЕРКА 1: Проверяем, что алерт вообще существует на экране
        XCTAssertTrue(alert.exists)
        // ПРОВЕРКА 2: Проверяем текст заголовка алерта
        XCTAssertTrue(alert.label == "Этот раунд окончен!")
        // ПРОВЕРКА 3 : Находим самую первую кнопку на алерте и проверяем, что она действительно "Сыграть еще раз"
        XCTAssertTrue(alert.buttons.firstMatch.label == "Сыграть ещё раз")
    }
    
    // Проверка закрытия алерта и перезапуск игры
    func testAlertDismiss() {
        sleep(2)
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }
        // Находим появившийся алерт
        let alert = app.alerts["Game results"]
        // Кликаем по самой первой кнопке на этом алерте("Сыграть еще раз")
        alert.buttons.firstMatch.tap()
        sleep(2)
        // Находим лейбл с номером вопроса по его ID Index
        let indexLabel = app.staticTexts["Index"]
        // ПРОВЕРКА 1: Проверяем, что алерт исчез с экрана после нажатия на кнопку
        XCTAssertFalse(alert.exists)
        // ПРОВЕРКА 2: Проверяем, что счетчик вопросов сбросился и снова показывает 1/10
        XCTAssertTrue(indexLabel.label == "1/10")
    }
    
}

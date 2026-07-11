//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Aleksandr on 09.07.2026.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        app = XCUIApplication()
        app.launch()
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        app.terminate()
        app = nil
    }
    
    func testYesButton() {
        let firstPoster = app.images["Poster"]
        XCTAssertTrue(firstPoster.waitForExistence(timeout: 5), "Постер не загрузился при старте")
        
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["Yes"].tap()
        
        // Гарантированно ждем, пока текст лейбла поменяется именно на "2/10"
        let indexLabel = app.staticTexts["Index"]
        let predicate = NSPredicate(format: "label == '2/10'")
        let expectation = expectation(for: predicate, evaluatedWith: indexLabel, handler: nil)
        wait(for: [expectation], timeout: 3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterData, secondPosterData, "Постер не изменился после клика на 'Yes'")
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testNoButton() {
        let firstPoster = app.images["Poster"]
        XCTAssertTrue(firstPoster.waitForExistence(timeout: 5), "Постер не загрузился при старте")
        
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        
        // Гарантированно ждем, пока текст лейбла поменяется именно на "2/10"
        let indexLabel = app.staticTexts["Index"]
        let predicate = NSPredicate(format: "label == '2/10'")
        let expectation = expectation(for: predicate, evaluatedWith: indexLabel, handler: nil)
        wait(for: [expectation], timeout: 3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterData, secondPosterData, "Постер не изменился после клика на 'No'")
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testGameFinish() {
        let firstPoster = app.images["Poster"]
        XCTAssertTrue(firstPoster.waitForExistence(timeout: 5), "Постер не загрузился при старте")
        
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }
        
        let alert = app.alerts["Этот раунд окончен!"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5), "Финальный алерт не появился")
        
        XCTAssertTrue(alert.exists)
        XCTAssertEqual(alert.label, "Этот раунд окончен!")
        XCTAssertEqual(alert.buttons.firstMatch.label, "Сыграть ещё раз")
    }
    
    func testAlertDismiss() {
        let firstPoster = app.images["Poster"]
        XCTAssertTrue(firstPoster.waitForExistence(timeout: 5), "Постер не загрузился при старте")
        
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }
        
        let alert = app.alerts["Этот раунд окончен!"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5), "Финальный алерт не появился")
        
        alert.buttons.firstMatch.tap()
        
        // Гарантированно ждем, пока после закрытия алерта счетчик сбросится обратно на "1/10"
        let indexLabel = app.staticTexts["Index"]
        let predicate = NSPredicate(format: "label == '1/10'")
        let expectation = expectation(for: predicate, evaluatedWith: indexLabel, handler: nil)
        wait(for: [expectation], timeout: 4)
        
        XCTAssertFalse(alert.exists, "Алерт не исчез с экрана после тапа")
        XCTAssertEqual(indexLabel.label, "1/10")
    }
}

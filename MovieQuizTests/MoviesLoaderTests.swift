//
//  MoviesLoaderTests.swift
//  MovieQuizTests
//
//  Created by Aleksandr on 09.07.2026.
//

import XCTest
@testable import MovieQuiz // Позволяет тестам видеть код из основного проекта MovieQuiz
// MARK: - StubNetworkClient
// Это дублер. Он заменяет реальный интернет
struct StubNetworkClient: NetworkRouting {
    // Перечесление с текстовой ошибкой, чтобы было чем "плюнуть" в загрузчик
    enum TestError: Error {
        case test
    }
        //  Тумблер: true - выключить ошибку, false -  выдать успешный ответ
    let emulateError: Bool
        // Главный метод, который притворяется сетевым запросом
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        if emulateError {
            // Если тумблер включен - сразу возвращяем ошибку
            handler(.failure(TestError.test))
                // Если выключен - возвращяем готовую JSON - строку в виде Data (набор байт)
        } else {
            handler(.success(expectedResponse))
        }
    }
    // Переменная - заготовка, хранящая текст с данными двух фильмов
    private var expectedResponse: Data {
                """
                {
                   "errorMessage" : "",
                   "items" : [
                      {
                         "crew" : "Dan Trachtenberg (dir.), Amber Midthunder, Dakota Beavers",
                         "fullTitle" : "Prey (2022)",
                         "id" : "tt11866324",
                         "imDbRating" : "7.2",
                         "imDbRatingCount" : "93332",
                         "image" : "https://m.media-amazon.com/images/M/MV5BMDBlMDYxMDktOTUxMS00MjcxLWE2YjQtNjNhMjNmN2Y3ZDA1XkEyXkFqcGdeQXVyMTM1MTE1NDMx._V1_Ratio0.6716_AL_.jpg",
                         "rank" : "1",
                         "rankUpDown" : "+23",
                         "title" : "Prey",
                         "year" : "2022"
                      },
                      {
                         "crew" : "Anthony Russo (dir.), Ryan Gosling, Chris Evans",
                         "fullTitle" : "The Gray Man (2022)",
                         "id" : "tt1649418",
                         "imDbRating" : "6.5",
                         "imDbRatingCount" : "132890",
                         "image" : "https://m.media-amazon.com/images/M/MV5BOWY4MmFiY2QtMzE1YS00NTg1LWIwOTQtYTI4ZGUzNWIxNTVmXkEyXkFqcGdeQXVyODk4OTc3MTY@._V1_Ratio0.6716_AL_.jpg",
                         "rank" : "2",
                         "rankUpDown" : "-1",
                         "title" : "The Gray Man",
                         "year" : "2022"
                      }
                    ]
                  }
                """.data(using: .utf8) ?? Data() // Переводим тест в байты (Data)
    }
}
// MARK: - MoviesLoaderTests
class MoviesLoaderTests: XCTestCase {
    // ТЕСТ 1: Проверяем, что загручик успешно обрабатывает правильный ответ сети
    func testSuccessLoading() throws {
        // Given
        // Создаем фейковый интернет и выключаем тумблер ошибки
        let stubNetworkClient = StubNetworkClient(emulateError: false)
        
        // Создаем реальный загрузчик, но посовываем ему наш фейковый интеренет
        let loader = MoviesLoader(networkClient: stubNetworkClient)
        
        // When
        // Создаем виртуальный будильник, потому что сеть работает асинхроно
        let expectation = expectation(description: "Loading expectation")
        
        // Выщываем функцию загрузки фильмов. Ответ(result) прилетит не сразу, а в замыкание
        loader.loadMovies { result in
            
            // Then
            // Разбираем то, что вернул нам загрузчик в переменной result
            switch result {
            case.success(let movies):
                // Проверяем: в нашем фейковом JSON было ровно 2 фильма.
                // Если movies.items.count  равен 2, значит загрузчик все правильно распрасил!
                XCTAssertEqual(movies.items.count, 2)
                // Выключаем будильник, тест завершается успехом
                expectation.fulfill()
                
            case.failure(_):
                // Если вдруг пришла ошибка, хотя мы её не ждали - принудительно валим текст
                XCTFail("Unexpected failure")
            }
        }
        // Говорим Xcode: Замри на этом месте и жди команду fulfill()  не больше 1 секунды
        waitForExpectations(timeout: 1)
    }
    
    // ТЕСТ 2: Проверяем, как загрузчик ведет себя, если интернет сломался
    func testFailureLoading() throws {
        // Given
        // Создаем фейковый интернет, но на этот раз ВКЛЮЧАЕМ тумблер ошибки
        let stubNetworkClient = StubNetworkClient(emulateError: true)
        let loader = MoviesLoader(networkClient: stubNetworkClient)
        
        // When
        // Снова заводим будильник для асинхронного кода
        let expectation = expectation(description: "Loading expectation")
        
        loader.loadMovies { result in
            
            // Then
            switch result {
            case.failure(let error):
                // Проверяем, что ошибка реально долетела до загрузчика и она существует (not nil)
                XCTAssertNotNil(error)
                
                // Раз ошибка пришла - значит код отработал сбой правильно. Выключаем будильник!
                expectation.fulfill()
                
            case.success(_):
                // Если вдруг сеть вернула успех, хотя тумблер был на ошибке - это баг, валим тест
                XCTFail("Unexpected failure")
            }
        }
        waitForExpectations(timeout: 1)
    }
}

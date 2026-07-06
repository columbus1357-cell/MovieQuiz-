import Foundation

struct NetworkClient {

    // 1. Создаем ошибку на случай, если сервер вернет плохой статус-код
    private enum NetworkError: Error {
        case codeError
    }
    
    // 2. Главная функция для загрузки данных
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Проверяем, пришла ли физическая ошибка (например, нет интернета)
            if let error = error {
                handler(.failure(error))
                return
            }
            
            // Проверяем код ответа от сервера (должен быть в диапазоне 200-299)
            if let response = response as? HTTPURLResponse,
                response.statusCode < 200 || response.statusCode >= 300 {
                handler(.failure(NetworkError.codeError))
                return
            }
            
            // Если всё отлично, распаковываем данные и передаем их в успех
            guard let data = data else { return }
            handler(.success(data))
        }
        
        // Запускаем сетевой запрос
        task.resume()
    }
}

//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Aleksandr on 10.06.2026.
//
import UIKit

final class ResultAlertPresenter {
    
    private weak var delegate: UIViewController?
    
    init(delegate: UIViewController) {
        self.delegate = delegate
    }
    
    func showAlert(model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion()
        }
        
        alert.addAction(action)
        delegate?.present(alert, animated: true, completion: nil)
    }
}

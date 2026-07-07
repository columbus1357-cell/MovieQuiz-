//
//  MostPopularMovies..swift
//  MovieQuiz
//
//  Created by Aleksandr on 06.07.2026.
//

import Foundation

struct MostPopularMovies: Codable {
    let errorMessage: String
    let items: [MostPopularMovie]
}
    // MARK: - Properties
struct MostPopularMovie: Codable {
    let title: String
    let rating: String
    let imageURL: URL
    
    // MARK: - Computed Properies
    var resizedImageURL: URL {
        let urlString = imageURL.absoluteString
        let imageUrlString = urlString.components(separatedBy: "._")[0] + "._V0_UX600_.jpg"
        
        guard let newURL = URL(string: imageUrlString) else {
            return imageURL
        }
        return newURL
    }
    // MARK: - CodingKeys
    private enum CodingKeys: String, CodingKey {
        case title = "fullTitle"
        case rating = "imDbRating"
        case imageURL = "image"
    }
}

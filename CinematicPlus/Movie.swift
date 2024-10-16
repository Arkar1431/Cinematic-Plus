//
//  Movie.swift
//  movieRecommand
//
//  Created by Mac on 9/9/24.
//

import Foundation

struct Movie: Codable {
    let id: Int
    let title: String
    let backdropPath: String?
    let posterPath: String?
    let voteAverage: Double?
    let voteCount: Int?
    let releaseDate: String?
    let overview: String?
    let runtime: Int?
    let genres: [Genre]?
    

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case backdropPath = "backdrop_path"
        case posterPath = "poster_path"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case releaseDate = "release_date"
        case overview
        case runtime
        case genres
        
    }
}

struct Genre: Codable {
    let name: String
}

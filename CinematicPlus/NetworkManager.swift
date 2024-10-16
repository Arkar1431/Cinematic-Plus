//
//  NetworkManager.swift
//  movieRecommand
//
//  Created by Mac on 9/9/24.
//
//


import Alamofire
import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    private let apiKey = "4a29a346229d7d47c05c203c02cd3342"
    private let baseURL = "https://api.themoviedb.org/3"
    
    // Fetch movies for a specific category
    func fetchMovies(forCategory category: String, completion: @escaping ([Movie]?) -> Void) {
        let endpoint: String
        
        switch category {
        case "popular":
            endpoint = "/movie/popular"
        case "now_playing":
            endpoint = "/movie/now_playing"
        case "top_rated":
            endpoint = "/movie/top_rated"
        case "upcoming":
            endpoint = "/movie/upcoming"
        case "trending_day":
            endpoint = "/trending/movie/day"
        case "trending_week":
            endpoint = "/trending/movie/week"
        default:
            endpoint = "/movie/popular"  // Default 
        }
        
        let url = "\(baseURL)\(endpoint)?api_key=\(apiKey)"
        
        AF.request(url).responseDecodable(of: MovieResponse.self) { response in
            switch response.result {
            case .success(let movieResponse):
                completion(movieResponse.results)
            case .failure(let error):
                print("Error fetching movies: \(error)")
                completion(nil)
            }
        }
    }

    // Fetch movie trailers for a specific movie
    func fetchMovieTrailers(movieId: Int, completion: @escaping ([Trailer]?) -> Void) {
        let url = "\(baseURL)/movie/\(movieId)/videos?api_key=\(apiKey)"
        
        AF.request(url).responseDecodable(of: TrailerResponse.self) { response in
            switch response.result {
            case .success(let trailerResponse):
                completion(trailerResponse.results)
            case .failure(let error):
                print("Error fetching movie trailers: \(error)")
                completion(nil)
            }
        }
    }
}

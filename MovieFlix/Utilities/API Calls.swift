//
//  API Calls.swift
//  MovieFlix
//
//  Created by George on 28/4/24.
//

import Foundation
import UIKit

let apiKey = "0f22c7b00c57ea967fa189dafd963076"
let endpointPrefix = "https://api.themoviedb.org"

import Foundation

/// Fetches the movies data
///
/// currentViewController: The controller in which the function is called
/// page: The page we want to load
/// query: The search query
func fetchMoviesData(currentViewController: UIViewController, page: Int, query: String, completion: @escaping (Result<MoviesList, Error>) -> Void) {
    let searchParameter = "search/movie"
    let popularParameter = "movie/popular"
    
    let searchQueryItems = [
        URLQueryItem(name: "query", value: query),
        URLQueryItem(name: "api_key", value: apiKey)
    ]
    
    let defaultQueryItems = [
        URLQueryItem(name: "language", value: "en-US"),
        URLQueryItem(name: "page", value: String(page)),
        URLQueryItem(name: "api_key", value: apiKey)
    ]
    
    let urlString = "\(endpointPrefix)/3/\(!query.isEmpty ? searchParameter : popularParameter)"
    var components = URLComponents(string: urlString)!
    
    components.queryItems = !query.isEmpty ? searchQueryItems : defaultQueryItems
        
    guard let url = components.url else {
        completion(.failure(NSError(domain: NSLocalizedString("message_invalid_url", comment: ""), code: 0, userInfo: nil)))
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.timeoutInterval = 10
    request.allHTTPHeaderFields = ["accept": "application/json"]
    
    checkInternetConnection { isConnected in
        if isConnected {
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NSError(domain: NSLocalizedString("message_no_data_received", comment: ""), code: 0, userInfo: nil)))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let movieList = try decoder.decode(MoviesList.self, from: data)
                    completion(.success(movieList))
                } catch {
                    completion(.failure(error))
                    showMessageSheet(in: currentViewController, title: NSLocalizedString("error", comment: ""), message: error.localizedDescription)
                }
            }.resume()
        } else {
            showMessageSheet(in: currentViewController, title: NSLocalizedString("warning", comment: ""), message: NSLocalizedString("message_no_internet_connection", comment: ""))
        }
    }
}


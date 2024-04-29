//
//  MoviesListModel.swift
//  MovieFlix
//
//  Created by George on 26/4/24.
//

import Foundation

// Define your model objects
struct MoviesList: Decodable {
    let page: Int
    let results: [MovieModel]
    let totalPages: Int
    let totalResults: Int
}

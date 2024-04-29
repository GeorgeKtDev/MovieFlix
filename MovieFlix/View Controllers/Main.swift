//
//  ViewController.swift
//  MovieFlix
//
//  Created by George on 24/4/24.
//

import UIKit
import Kingfisher
import SkeletonView
import SwiftUI

protocol CoordinatorDelegate: AnyObject {
    func showMovieDetails(withData data: MovieModel)
}

class Coordinator: CoordinatorDelegate, ObservableObject {
    @Published var selectedItem: MovieModel?
    
    func showMovieDetails(withData data: MovieModel) {
        selectedItem = data
    }
}

class Main: UIViewController {
    @IBOutlet weak var moviesSearchBar: UISearchBar!
    @IBOutlet weak var moviesTableView: UICollectionView!
    
    var moviesList: Array<MovieModel> = Array()
    var currentPage = 1
    
    var isLastPage = false
    var isFetching = false
    
    var searchQuery = ""
    var searchWorkItem: DispatchWorkItem?
    
    var coordinator = Coordinator()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        moviesSearchBar.delegate = self
        
        moviesTableView?.register(MovieCell.nib(), forCellWithReuseIdentifier: MovieCell.identifier)
        moviesTableView.allowsMultipleSelection = false
        moviesTableView?.delegate = self
        moviesTableView?.dataSource = self
        
        if let flow = self.moviesTableView.collectionViewLayout as? UICollectionViewFlowLayout {
            flow.itemSize.width = self.moviesTableView.frame.size.width
        }
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.refreshData), for: .valueChanged)
        
        SkeletonAppearance.default.renderSingleLineAsView = true
        moviesTableView.showAnimatedSkeleton(usingColor: .systemGray5, animation: nil, transition: .crossDissolve(0.1))
        
        fetchMoviesData(currentViewController: self, page: 1, query: searchQuery) { result in
            switch result {
            case .success(let movies):
                self.moviesList = movies.results
                
            case .failure(let error):
                showMessageSheet(in: self, title: NSLocalizedString("error", comment: ""), message: error.localizedDescription)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.moviesTableView.reloadData()
                self.moviesTableView.refreshControl = refreshControl
                
                self.moviesTableView.stopSkeletonAnimation()
                self.moviesTableView.hideSkeleton()
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    /// Refreshes the data on Pull To Refresh
    @objc func refreshData() {
        currentPage = 1
        
        SkeletonAppearance.default.renderSingleLineAsView = true
        moviesTableView.showAnimatedSkeleton(usingColor: .systemGray5, animation: nil, transition: .crossDissolve(0.1))
        
        fetchMoviesData(currentViewController: self, page: 1, query: searchQuery) { result in
            switch result {
            case .success(let movies):
                DispatchQueue.main.async {
                    self.moviesList = movies.results
                    self.moviesTableView.reloadData()
                }
            case .failure(let error):
                showMessageSheet(in: self, title: NSLocalizedString("error", comment: ""), message: error.localizedDescription)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.moviesTableView.refreshControl?.endRefreshing()
                
                self.moviesTableView.stopSkeletonAnimation()
                self.moviesTableView.hideSkeleton()
            }
        }
    }
    
    /// Loads the image and takes care of caching with Kingfisher Package
    func loadImageWithKingFisher(imageView: UIImageView, imagePath: String) {
        if let imageURL = URL(string: imagePath) {
            imageView.kf.setImage(with: imageURL)
        }
    }
    
    /// Handles the stars UI styling depending on the averageVotes
    func determineMovieRating(averageVotes: Float, ratingStackView: UIStackView) {
        let ratingStars = ratingStackView.subviews
        var rating = Int(averageVotes / 2)
        
        if averageVotes.truncatingRemainder(dividingBy: 2) > 0.5 {
            rating += 1
        }
        
        for star in ratingStars {
            (star.subviews[0] as! UIImageView).image = UIImage(systemName: "star")
        }
        
        for index in 0..<rating {
            let imageName = index == rating - 1 ? "star.leadinghalf.filled" : "star.fill"
            (ratingStars[index].subviews[0] as! UIImageView).image = UIImage(systemName: imageName)
        }
    }
}

extension Main: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return moviesList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {        
        coordinator.showMovieDetails(withData: moviesList[indexPath.row])
        
        DispatchQueue.main.async {
            let swiftUIView = MovieDetails(dismissAction: {
                self.dismiss(animated: true, completion: nil)
            }).environmentObject(self.coordinator)

            let hostingController = UIHostingController(rootView: swiftUIView)
            self.present(hostingController, animated: true, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Preferred to set the contentMode as .aspectFill and keep the image centered, I felt it looked better.
        // I didn't quite like the image starting from the top of the view. That's ofcourse personal preference.
        
        let cell = moviesTableView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath) as! MovieCell
        let movie = moviesList[indexPath.row]
        
        cell.setMovieData(withData: movie)
        
        if let posterPath = movie.posterPath {
            let pathPrefix = "https://image.tmdb.org/t/p/original/"
            loadImageWithKingFisher(imageView:cell.moviePosterImage, imagePath: pathPrefix + posterPath)
        } else {
            loadImageWithKingFisher(imageView:cell.moviePosterImage, imagePath: "https://picsum.photos/144/288")
        }
        
        if let releaseDate = movie.releaseDate {
            cell.movieReleseDateLabel.text = dateFormatted(dateUnformatted:releaseDate)
        }
        
        cell.movieTitleLabel.text = movie.originalTitle
        
        if let voteAverage = movie.voteAverage {
            determineMovieRating(averageVotes: Float(voteAverage), ratingStackView: cell.ratingStackView)
        }
        
        if let favorite = moviesList[indexPath.row].favorite {
            cell.isFavorite.image = favorite ? UIImage(named: "heart") : UIImage(named: "heart.fill")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let lastItem = moviesList.count - 1
        
        if indexPath.item == lastItem && !isFetching && !isLastPage {
            isFetching = true
            
            currentPage += 1
            
            fetchMoviesData(currentViewController: self, page: currentPage, query: searchQuery) { result in
                self.isFetching = false
                
                switch result {
                case .success(let movies):
                    if movies.results.isEmpty {
                        self.isLastPage = true
                    } else {
                        self.moviesList.append(contentsOf: movies.results)
                        
                        DispatchQueue.main.async {
                            self.moviesTableView.reloadData()
                        }
                    }
                case .failure(let error):
                    showMessageSheet(in: self, title: NSLocalizedString("error", comment: ""), message: error.localizedDescription)
                }
            }
        }
    }
}

extension Main: SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
        return MovieCell.identifier
    }
}

extension Main: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchQuery = searchText
        searchWorkItem?.cancel()
        
        SkeletonAppearance.default.renderSingleLineAsView = true
        moviesTableView.showAnimatedSkeleton(usingColor: .systemGray5, animation: nil, transition: .crossDissolve(0.1))
        
        let newWorkItem = DispatchWorkItem { [weak self] in
            if let currentViewController = self {
                fetchMoviesData(currentViewController: currentViewController,
                                page: currentViewController.currentPage,
                                query: currentViewController.searchQuery) { result in
                    switch result {
                    case .success(let movies):
                        DispatchQueue.main.async {
                            currentViewController.moviesList = movies.results
                            currentViewController.moviesTableView.reloadData()
                        }
                    case .failure(let error):
                        showMessageSheet(in: currentViewController, title: NSLocalizedString("error", comment: ""), message: error.localizedDescription)
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        currentViewController.moviesTableView.refreshControl?.endRefreshing()
                        
                        currentViewController.moviesTableView.stopSkeletonAnimation()
                        currentViewController.moviesTableView.hideSkeleton()
                    }
                }
            }
        }
        
        searchWorkItem = newWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: newWorkItem)
        
        if searchText.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                searchBar.resignFirstResponder()
                self.refreshData()
            }
        }
    }
}

extension UIColor {
    class func appLight() -> UIColor {
        return UIColor(red: 250.0/255.0, green: 250.0/255.0, blue: 250.0/255.0, alpha:1.0)
    }
}

extension UIImage {
    func resizeTopAlignedToFill(newWidth: CGFloat) -> UIImage? {
        let newHeight = size.height * newWidth / size.width
        
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, UIScreen.main.scale)
        draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

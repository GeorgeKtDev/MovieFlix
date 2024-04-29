//
//  MovieCell.swift
//  MovieFlix
//
//  Created by George on 24/4/24.
//

import UIKit

class MovieCell: UICollectionViewCell {
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var gradientBackgroundImage: UIView!

    @IBOutlet weak var moviePosterImage: UIImageView!
    @IBOutlet weak var isFavorite: UIImageView!

    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieReleseDateLabel: UILabel!
    
    @IBOutlet weak var ratingStackView: UIStackView!

    static let identifier = "MovieCell"

    weak var coordinatorDelegate: CoordinatorDelegate?
    
    var movieData: MovieModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
                
        self.layer.cornerRadius = 8
        
        cellView.clipsToBounds = true
        
        cellView.layer.cornerRadius = 8
        cellView.layer.borderWidth = 4
        cellView.layer.borderColor = UIColor.systemYellow.cgColor
        
        cellView.layer.shadowColor = UIColor.black.cgColor
        cellView.layer.shadowOpacity = 0.5
        cellView.layer.shadowOffset = CGSize(width: 2, height: 2)
        cellView.layer.shadowRadius = 4
        
        DispatchQueue.main.async {
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
            gradientLayer.locations = [0.0, 1.0]
            
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
            gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.0)
            
            gradientLayer.frame = self.gradientBackgroundImage.frame
            
            self.gradientBackgroundImage.layer.insertSublayer(gradientLayer, at: 0)
        }
    }
    
    
    func setMovieData(withData data: MovieModel) {
        self.movieData = data
    }
    
    func showMovieDetails() {
        if let movieData = movieData {
            coordinatorDelegate?.showMovieDetails(withData: movieData)
        }
    }
    
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
}


import UIKit
import SDWebImage

protocol MovieDetailViewControllerDelegate: AnyObject {
    func didUpdateFavorites()
}

class MovieDetailViewController: UIViewController {

    @IBOutlet weak var movieNameLabel: UILabel!
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var voteLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var voteCountLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var runtimeLabel: UILabel!
    @IBOutlet weak var overviewLabel1: UILabel!
    @IBOutlet weak var trailerButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!

    var movie: Movie?
    weak var delegate: MovieDetailViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        self.navigationItem.title = "Movie Details"
        setupUI()
        setupFavoriteButton()
    }

    private func setupUI() {
        guard let movie = movie else {
            print("Movie data is not available")
            return
        }
        
        // Movie Name Label Setup
        movieNameLabel.text = movie.title
        movieNameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        movieNameLabel.textAlignment = .center
        movieNameLabel.textColor = .white
        movieNameLabel.numberOfLines = 0
        movieNameLabel.adjustsFontSizeToFitWidth = true
        movieNameLabel.shadowColor = UIColor.black.withAlphaComponent(0.5)
        movieNameLabel.shadowOffset = CGSize(width: 1, height: 1)

        // Movie Image View Setup
        movieImageView.layer.cornerRadius = 10
        movieImageView.clipsToBounds = true
        movieImageView.contentMode = .scaleAspectFill
        movieImageView.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        movieImageView.layer.borderWidth = 2
        if let backdropPath = movie.backdropPath {
            let backdropURL = URL(string: "https://image.tmdb.org/t/p/w500\(backdropPath)")
            movieImageView.sd_setImage(with: backdropURL)
        }

        // Other Labels Setup
        voteLabel.text = "Vote Average: \(movie.voteAverage?.description ?? "N/A")"
        voteLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        voteLabel.textColor = .white

        voteCountLabel.text = "Vote Count: \(movie.voteCount ?? 0)"
        voteCountLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        voteCountLabel.textColor = .white

        releaseDateLabel.text = "Release Date: \(movie.releaseDate ?? "N/A")"
        releaseDateLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        releaseDateLabel.textColor = .white

        runtimeLabel.text = "Runtime: \(movie.runtime ?? 0) min"
        runtimeLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        runtimeLabel.textColor = .white

        overviewLabel1.text = "Overview"
        overviewLabel1.font = UIFont.boldSystemFont(ofSize: 18)
        overviewLabel1.textColor = .white
        overviewLabel1.backgroundColor = UIColor.darkGray.withAlphaComponent(0.7)
        overviewLabel1.textAlignment = .center
        overviewLabel1.numberOfLines = 1

        overviewLabel.text = movie.overview
        overviewLabel.numberOfLines = 0
        overviewLabel.font = UIFont.systemFont(ofSize: 18)
        overviewLabel.textColor = .white

        // Trailer Button Setup
        trailerButton.setTitle("Watch Trailer", for: .normal)
        trailerButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        trailerButton.setTitleColor(.white, for: .normal)
        trailerButton.backgroundColor = .purple // Set to purple
        trailerButton.layer.cornerRadius = 10
        trailerButton.addTarget(self, action: #selector(trailerButtonTapped), for: .touchUpInside)
    }

    private func setupFavoriteButton() {
        guard let movie = movie else { return }

        let isFavorite = FavoritesManager.shared.isFavorite(movie: movie)
        
        favoriteButton.setTitle(isFavorite ? "Added to Favorites" : "Add to Favorite", for: .normal)
        favoriteButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        favoriteButton.setTitleColor(.white, for: .normal)
        
        favoriteButton.backgroundColor = isFavorite ? .purple : .darkGray
        
        favoriteButton.layer.cornerRadius = 10
        favoriteButton.removeTarget(nil, action: nil, for: .allEvents)
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
    }


    @objc private func favoriteButtonTapped() {
        guard let movie = movie else { return }

        if FavoritesManager.shared.isFavorite(movie: movie) {
            FavoritesManager.shared.removeFavorite(movie: movie)
            favoriteButton.backgroundColor = .darkGray
            favoriteButton.setTitle("Add to Favorite", for: .normal)
        } else {
            FavoritesManager.shared.addFavorite(movie: movie)
            favoriteButton.backgroundColor = .purple
            favoriteButton.setTitle("Added to Favorites", for: .normal)
        }

        // Notify delegate (Favorites tab) of update
        delegate?.didUpdateFavorites()
    }

    @objc private func trailerButtonTapped() {
        guard let movie = movie else { return }
        
        NetworkManager.shared.fetchMovieTrailers(movieId: movie.id) { trailers in
            guard let trailer = trailers?.first(where: { $0.site == "YouTube" }) else {
                print("No trailer found")
                return
            }

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let trailerViewController = storyboard.instantiateViewController(withIdentifier: "TrailerViewController") as? TrailerViewController {
                trailerViewController.trailerURL = "https://www.youtube.com/embed/\(trailer.key)"
                self.navigationController?.pushViewController(trailerViewController, animated: true)
            }
        }
    }
}

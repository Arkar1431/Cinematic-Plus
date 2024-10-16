import UIKit
 
class FavoritesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
 
    @IBOutlet weak var tableView: UITableView!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNotificationObserver()
    }
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
 
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
    }
 
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(favoritesChanged), name: .favoritesChanged, object: nil)
    }
 
    @objc private func favoritesChanged() {
        tableView.reloadData()
    }
 
    // MARK: - TableView DataSource
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FavoritesManager.shared.favoriteMovies.count
    }
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteMovieCell", for: indexPath) as? MovieTableViewCell else {
            fatalError("Unable to dequeue MovieTableViewCell")
        }
 
        let movie = FavoritesManager.shared.favoriteMovies[indexPath.row]
        configureCell(cell, with: movie, at: indexPath)
        return cell
    }
 
    private func configureCell(_ cell: MovieTableViewCell, with movie: Movie, at indexPath: IndexPath) {
        cell.voteAverage.text = "Vote Average: \(movie.voteAverage?.description ?? "N/A")"
        
        // Replace release date with movie name, set bigger font, and yellow text color
        cell.releaseDate.text = movie.title
        cell.releaseDate.font = UIFont.systemFont(ofSize: 18, weight: .bold) // Bigger font
        cell.releaseDate.textColor = UIColor.systemYellow // Yellow text color
     
        if let posterPath = movie.posterPath {
            let posterURL = URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
            cell.posterImage.sd_setImage(with: posterURL, placeholderImage: UIImage(named: "placeholder"))
        } else {
            cell.posterImage.image = UIImage(named: "placeholder")
        }
     
        cell.removeFromFavoritesButton.tag = indexPath.row
        cell.removeFromFavoritesButton.addTarget(self, action: #selector(removeFromFavorites(_:)), for: .touchUpInside)
    }

 
    // MARK: - TableView Delegate
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let movie = FavoritesManager.shared.favoriteMovies[indexPath.row]
        navigateToMovieDetail(for: movie)
    }
 
    // MARK: - Navigation
 
    private func navigateToMovieDetail(for movie: Movie) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailVC = storyboard.instantiateViewController(withIdentifier: "MovieDetailViewController") as? MovieDetailViewController {
            detailVC.movie = movie
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
 
    // MARK: - Button Actions
 
    @objc private func removeFromFavorites(_ sender: UIButton) {
        let movie = FavoritesManager.shared.favoriteMovies[sender.tag]
        FavoritesManager.shared.removeFavorite(movie: movie)
        tableView.reloadData()
    }
 
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
 

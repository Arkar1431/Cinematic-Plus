import UIKit
import SDWebImage

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var appNameLabel: UILabel!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var label: UILabel!  // Label to show selected category
    
    // Categories
    let categories = ["popular", "now_playing", "top_rated", "upcoming", "trending_day", "trending_week"]
    var selectedCategory = "popular"
    
    var movies: [Movie] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupNotificationObserver()
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.itemSize = CGSize(width: 120, height: 200)
        flowLayout.minimumLineSpacing = 15
        flowLayout.minimumInteritemSpacing = 10
        collectionView.collectionViewLayout = flowLayout
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Fetch movies with the default category ("popular")
        fetchMovies(withCategory: selectedCategory)
    }
    
    private func setupUI() {

        view.backgroundColor = UIColor(red: 12/255, green: 17/255, blue: 40/255, alpha: 1)
        collectionView.backgroundColor = UIColor(red: 10/255, green: 15/255, blue: 35/255, alpha: 1)
        

        appNameLabel.text = "Cinematic Plus"
        appNameLabel.font = UIFont.systemFont(ofSize: 25, weight: .semibold)
        appNameLabel.textColor = UIColor.purple
        

        label.textColor = .systemYellow
        label.font = UIFont.systemFont(ofSize: 25, weight: .regular)
        label.text = "MOVIE:\(selectedCategory)".uppercased()

        filterButton.setTitleColor(.black, for: .normal)
        filterButton.setTitle("Filter Search", for: .normal)
        filterButton.backgroundColor = UIColor.purple
        filterButton.layer.cornerRadius = 10
        filterButton.layer.borderWidth = 1
        filterButton.layer.borderColor = UIColor.black.cgColor
        

        if let navigationController = navigationController {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = .white
            appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
            
            navigationController.navigationBar.standardAppearance = appearance
            navigationController.navigationBar.scrollEdgeAppearance = appearance
            navigationController.navigationBar.tintColor = .black 
            navigationController.navigationBar.isTranslucent = false
        }
        
        // Set Tab Bar color to white with black icons
        if let tabBarController = tabBarController {
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.backgroundColor = .white
            tabBarAppearance.stackedLayoutAppearance.normal.iconColor = .black
            tabBarAppearance.stackedLayoutAppearance.selected.iconColor = .black
            
            tabBarController.tabBar.standardAppearance = tabBarAppearance
            tabBarController.tabBar.scrollEdgeAppearance = tabBarAppearance
            tabBarController.tabBar.tintColor = .black // Black selected icons
            tabBarController.tabBar.isTranslucent = false
        }
    }

    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(applyFilter(_:)), name: NSNotification.Name("FilterSelected"), object: nil)
    }

    // Apply the selected filter when a notification is received
    @objc private func applyFilter(_ notification: Notification) {
        
        print("Received Notification: \(notification)")
        if let selectedCategory = notification.object as? String {
            print("Filter applied: \(selectedCategory)")
            self.selectedCategory = selectedCategory
            label.text = " \(selectedCategory)"
            fetchMovies(withCategory: selectedCategory)
        }
    }
    
    // Fetch movies based on the selected category
    func fetchMovies(withCategory category: String) {
        NetworkManager.shared.fetchMovies(forCategory: category) { [weak self] movies in
            guard let self = self, let movies = movies else { return }
            self.movies = movies
            DispatchQueue.main.async {
                self.collectionView.reloadData()  // Reload collection view with new movies
            }
        }
    }

    // Collection View DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath) as! MovieCollectionViewCell
        let movie = movies[indexPath.item]
        cell.titleLabel.text = movie.title
        cell.titleLabel.textAlignment = .center
        cell.titleLabel.textColor = .purple
        
        if let posterPath = movie.posterPath {
            let posterURL = URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
            cell.imageView.sd_setImage(with: posterURL, completed: nil)
        }
        return cell
    }
    
    // Collection View Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedMovie = movies[indexPath.item]
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let movieDetailVC = storyboard.instantiateViewController(withIdentifier: "MovieDetailViewController") as? MovieDetailViewController {
            movieDetailVC.movie = selectedMovie
            navigationController?.pushViewController(movieDetailVC, animated: true)
        }
    }
    
    // Action for the filter button
    @IBAction func filterButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let filterVC = storyboard.instantiateViewController(withIdentifier: "FilterViewController") as? FilterViewController {
            self.present(filterVC, animated: true, completion: nil)
        }
    }
}


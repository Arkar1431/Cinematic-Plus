import UIKit

class FilterViewController: UIViewController {

    var selectedFilter: String?
    
    // Define buttons for each category
    @IBOutlet weak var popularButton: UIButton!
    @IBOutlet weak var nowPlayingButton: UIButton!
    @IBOutlet weak var topRatedButton: UIButton!
    @IBOutlet weak var upcomingButton: UIButton!
    @IBOutlet weak var trendingButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgroundUI()
        setupButtonsUI()
        setupButtonNames()
    }
    

    private func setupBackgroundUI() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [
            UIColor(red: 0.05, green: 0.05, blue: 0.15, alpha: 1).cgColor, // Dark blue-black
            UIColor(red: 0.1, green: 0.1, blue: 0.25, alpha: 1).cgColor    // Darker blue gradient
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    // Style the buttons to match the purple movie theme
    private func setupButtonsUI() {
        let buttons = [popularButton, nowPlayingButton, topRatedButton, upcomingButton, trendingButton]
        
        for button in buttons {
            // Button UI
            button?.layer.cornerRadius = 12  // Rounded corners for modern look
            button?.backgroundColor = UIColor.purple  // Purple button background
            
            // Text Styling
            button?.setTitleColor(.white, for: .normal)  // White text for contrast
            button?.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold) // Bold, readable font
            
            // Subtle shadow for depth
            button?.layer.shadowColor = UIColor.black.cgColor
            button?.layer.shadowOpacity = 0.3
            button?.layer.shadowOffset = CGSize(width: 2, height: 2)
            button?.layer.shadowRadius = 4
            
            // Padding for X-axis to make buttons wider
            button?.contentEdgeInsets = UIEdgeInsets(top: 10, left: 40, bottom: 10, right: 40)
        }
    }
    
    // Set button titles to match categories
    private func setupButtonNames() {
        popularButton.setTitle("Popular", for: .normal)
        nowPlayingButton.setTitle("Now Playing", for: .normal)
        topRatedButton.setTitle("Top Rated", for: .normal)
        upcomingButton.setTitle("Upcoming", for: .normal)
        trendingButton.setTitle("Trending Today", for: .normal)
//        genresButton.setTitle("Genres", for: .normal)
    }
    
    // Button Actions to select category and send notification
    @IBAction func popularSelected(_ sender: UIButton) {
        postFilterNotification("popular")
    }
    
    @IBAction func nowPlayingSelected(_ sender: UIButton) {
        postFilterNotification("now_playing")
    }
    
    @IBAction func topRatedSelected(_ sender: UIButton) {
        postFilterNotification("top_rated")
    }
    
    @IBAction func upcomingSelected(_ sender: UIButton) {
        postFilterNotification("upcoming")
    }
    
    @IBAction func trendingSelected(_ sender: UIButton) {
        postFilterNotification("trending_day")
    }
    
    @IBAction func genresSelected(_ sender: UIButton) {
        postFilterNotification("genres")
    }
    
    @IBAction func recommendationsSelected(_ sender: UIButton) {
        postFilterNotification("recommendations")
    }
    
    @IBAction func similarMoviesSelected(_ sender: UIButton) {
        postFilterNotification("similar_movies")
    }
    
    // Helper function to post notification with selected filter
    private func postFilterNotification(_ filter: String) {
        NotificationCenter.default.post(name: NSNotification.Name("FilterSelected"), object: filter)
        self.dismiss(animated: true, completion: nil)
    }
}

import UIKit
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn

class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Sign In"
//        setupBackgroundImage()
    }

//    private func setupBackgroundImage() {
//        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
//        backgroundImage.image = UIImage(named: "signposter")
//        backgroundImage.contentMode = .scaleAspectFill
//        self.view.insertSubview(backgroundImage, at: 0)
//    }

    @IBAction func signInTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert("Error", "Please enter email and password")
            return
        }

        // Firebase Authentication: Sign in user
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.showAlert("Error", error.localizedDescription)
                return
            }

            // Ensure email is verified before proceeding
            guard let user = authResult?.user, user.isEmailVerified else {
                self.showAlert("Error", "Please verify your email before signing in.")
                return
            }

            // Set the current user in FavoritesManager
            FavoritesManager.shared.setCurrentUser(userID: user.uid)

            // Fetch user-specific data from Firestore
            self.fetchUserData(uid: user.uid)
        }
    }

    // Fetch user data based on their unique UID
    private func fetchUserData(uid: String) {
        let userDocRef = db.collection("users").document(uid)

        userDocRef.getDocument { document, error in
            if let error = error {
                self.showAlert("Error", error.localizedDescription)
                return
            }

            if let document = document, document.exists {
                // Retrieve user-specific data (e.g., username, favorites)
                let data = document.data() ?? [:]
                let username = data["username"] as? String ?? "Unknown"
                let favorites = data["favorites"] as? [String] ?? []
                
                print("Fetched user data: Username: \(username), Favorites: \(favorites)")

                // Load favorites into FavoritesManager
                self.loadFavorites(favorites)

                // Navigate to Tab Bar Controller after successful sign-in and data fetch
                self.navigateToTabBarController()
            } else {
                // No data exists for the user, handle accordingly
                self.showAlert("Error", "No data found for this user.")
            }
        }
    }

    // Load favorites into FavoritesManager
    private func loadFavorites(_ favorites: [String]) {
        // Assuming favorites are stored as movie IDs
        // You might need to fetch full movie details for each ID
        for movieID in favorites {
            // Fetch movie details from your API or local database
            // For example:
            // MovieAPI.getMovie(id: movieID) { movie in
            //     if let movie = movie {
            //         FavoritesManager.shared.addFavorite(movie: movie)
            //     }
            // }
        }
    }

    // Navigate to the Tab Bar Controller after successful login
    private func navigateToTabBarController() {
        self.showAlert("Success", "Signed in successfully!") {
            if let tabBarController = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController {
                UIApplication.shared.windows.first?.rootViewController = tabBarController
                UIApplication.shared.windows.first?.makeKeyAndVisible()
            }
        }
    }

    // Helper function to show alert
    private func showAlert(_ title: String, _ message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion?()
        }))
        present(alert, animated: true, completion: nil)
    }
}

import UIKit
import GoogleSignIn
import FirebaseAuth
import FirebaseCore

class ViewController: UIViewController {

    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var googleSignInButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        styleButtons()
        configureGoogleSignIn()
        checkIfUserIsSignedIn()  // Check if user is already signed in
    }

    func styleButtons() {
        // Styling for Sign In Button
        signInButton.layer.cornerRadius = 10
        signInButton.layer.borderWidth = 1
        signInButton.layer.borderColor = UIColor.blue.cgColor
        
        // Styling for Google Sign-In Button
        googleSignInButton.setTitle("Sign in with Google", for: .normal)
        googleSignInButton.setTitleColor(.black, for: .normal)
        googleSignInButton.backgroundColor = .white
        googleSignInButton.layer.cornerRadius = 10
        googleSignInButton.layer.borderWidth = 1
        googleSignInButton.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    func configureGoogleSignIn() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
    }
    
    @IBAction func createAccountTapped(_ sender: UIButton) {
        if let createAccountVC = storyboard?.instantiateViewController(withIdentifier: "CreateAccountVC") as? CreateAccountViewController {
            navigationController?.pushViewController(createAccountVC, animated: true)
        }
    }

    @IBAction func signInTapped(_ sender: UIButton) {
        if let signInVC = storyboard?.instantiateViewController(withIdentifier: "SignInVC") as? SignInViewController {
            navigationController?.pushViewController(signInVC, animated: true)
        }
    }

    @IBAction func googleSignInTapped(_ sender: Any) {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            guard let self = self else { return }

            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                self.showAlert(title: "Error", message: "Failed to get user ID token")
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    self.showAlert(title: "Error", message: error.localizedDescription)
                    return
                }

                // User is signed in
                print("User signed in with Google")
                self.handleSuccessfulSignIn()
            }
        }
    }

    // Handle successful sign-in and navigate to TabBarController
    func handleSuccessfulSignIn() {
        if let tabBarController = storyboard?.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController {
            UIApplication.shared.windows.first?.rootViewController = tabBarController
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
    }

    // Show alert with a custom message
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // Automatically check if the user is signed in on app launch
    func checkIfUserIsSignedIn() {
        if Auth.auth().currentUser != nil {
            print("User is already signed in")
            handleSuccessfulSignIn()  // Navigate to the main screen
        } else {
            print("No user is signed in")
        }
    }
}

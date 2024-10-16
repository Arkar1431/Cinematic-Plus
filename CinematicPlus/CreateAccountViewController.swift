import UIKit
import FirebaseAuth
import FirebaseFirestore

class CreateAccountViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Create Account"
        setupBackgroundImage()
    }

    private func setupBackgroundImage() {
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)

        backgroundImage.contentMode = .scaleAspectFill
        self.view.insertSubview(backgroundImage, at: 0)
    }

    @IBAction func createAccountTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let username = usernameTextField.text, !username.isEmpty else {
            showAlert("Error", "All fields are required")
            return
        }

        // Firebase Authentication: Create user account
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.showAlert("Error", error.localizedDescription)
                return
            }

            // Send verification email
            authResult?.user.sendEmailVerification(completion: { error in
                if let error = error {
                    self.showAlert("Error", error.localizedDescription)
                    return
                }

                if let user = authResult?.user {
                    self.createUserDocument(uid: user.uid, username: username)
                }

                self.showAlert("Success", "Account created successfully. Please check your email to verify your account.")
            })
        }
    }

    // Store new user data in Firestore
    private func createUserDocument(uid: String, username: String) {
        let userDocRef = db.collection("users").document(uid)
        let userData: [String: Any] = [
            "username": username,
            "favorites": [] // Empty list of favorites initially
        ]

        userDocRef.setData(userData) { error in
            if let error = error {
                self.showAlert("Error", error.localizedDescription)
                return
            }
            print("User document created successfully")
        }
    }

    // Helper function to show alert
    private func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

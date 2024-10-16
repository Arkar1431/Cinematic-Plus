//
//  AccountViewController.swift
//  CinematicPlus
//
//  Created by Mac on 9/14/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class AccountViewController: UIViewController {

    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var signOutMessageLabel: UILabel!
    @IBOutlet weak var signOutButton: UIButton!

    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUserData()
    }

    private func setupUI() {
        // Set a dark gradient background color
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor.black.cgColor, UIColor.darkGray.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        // Style the labels
        emailLabel.textColor = UIColor.white
        emailLabel.font = UIFont.boldSystemFont(ofSize: 22)
        
        usernameLabel.textColor = UIColor.white
        usernameLabel.font = UIFont.boldSystemFont(ofSize: 22)
        
        signOutMessageLabel.text = "Oh no! Are sure You going to leave me alone!"
        signOutMessageLabel.textColor = UIColor.white
        signOutMessageLabel.font = UIFont.systemFont(ofSize: 16)
        
        // Style the sign out button
        signOutButton.setTitle("Sign Out", for: .normal)
        signOutButton.setTitleColor(.white, for: .normal)
        signOutButton.backgroundColor = UIColor.red.withAlphaComponent(0.8)
        signOutButton.layer.cornerRadius = 10
        signOutButton.layer.shadowColor = UIColor.black.cgColor
        signOutButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        signOutButton.layer.shadowOpacity = 0.5
        signOutButton.layer.shadowRadius = 4
        signOutButton.addTarget(self, action: #selector(signOutTapped), for: .touchUpInside)
    }

    private func loadUserData() {
        // Ensure the labels are reset before fetching data
        emailLabel.text = ""
        usernameLabel.text = ""

        guard let currentUser = Auth.auth().currentUser else {
            print("No user is currently signed in")
            return
        }
        emailLabel.text = "Email: \(currentUser.email ?? "N/A")"

        let defaultUsername = currentUser.email?.components(separatedBy: "@").first ?? "N/A"
        usernameLabel.text = " \(defaultUsername)" 
        let userDocRef = db.collection("users").document(currentUser.uid)
        userDocRef.getDocument { [weak self] (document, error) in
            guard let self = self else { return }

            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                return
            }

            if let document = document, document.exists {
                let data = document.data() ?? [:]
                let username = data["username"] as? String ?? defaultUsername // Use email prefix if no username found
                self.usernameLabel.text = "Username: \(username)"
            } else {
                print("No user data found in Firestore")
                self.usernameLabel.text = "Username: \(defaultUsername)"
            }
        }
    }


    @objc private func signOutTapped() {
        let alert = UIAlertController(title: "Sign Out", message: "Are you sure you want to sign out?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { [weak self] _ in
            self?.signOut()
        }))
        
        present(alert, animated: true, completion: nil)
    }

    private func signOut() {
        do {
            try Auth.auth().signOut()
            FavoritesManager.shared.clearCurrentUserData()
            navigateToViewController()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            showAlert("Error", "Failed to sign out. Please try again.")
        }
    }

    private func navigateToViewController() {
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as? ViewController {
            let navController = UINavigationController(rootViewController: viewController)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true, completion: nil)
        }
    }

    private func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

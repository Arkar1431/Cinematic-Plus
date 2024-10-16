import Foundation
import FirebaseAuth
 
extension Notification.Name {
    static let favoritesChanged = Notification.Name("favoritesChanged")
}
 
class FavoritesManager {
    static let shared = FavoritesManager()
    private(set) var favoriteMovies: [Movie] = []
    private var currentUserID: String?
 
    private init() {
        Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            if let user = user {
                self?.setCurrentUser(userID: user.uid)
            } else {
                self?.clearCurrentUserData()
            }
        }
    }
 
    func setCurrentUser(userID: String) {
        self.currentUserID = userID
        loadFavorites()
    }
 
    func addFavorite(movie: Movie) {
        guard let userID = currentUserID else { return }
        if !favoriteMovies.contains(where: { $0.id == movie.id }) {
            favoriteMovies.append(movie)
            saveFavorites()
            NotificationCenter.default.post(name: .favoritesChanged, object: nil)
        }
    }
 
    func removeFavorite(movie: Movie) {
        guard let userID = currentUserID else { return }
        favoriteMovies.removeAll { $0.id == movie.id }
        saveFavorites()
        NotificationCenter.default.post(name: .favoritesChanged, object: nil)
    }
 
    func isFavorite(movie: Movie) -> Bool {
        return favoriteMovies.contains(where: { $0.id == movie.id })
    }
 
    private func saveFavorites() {
        guard let userID = currentUserID else { return }
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(favoriteMovies) {
            UserDefaults.standard.set(encoded, forKey: "favoriteMovies_\(userID)")
        }
    }
 
    private func loadFavorites() {
        guard let userID = currentUserID else { return }
        if let savedFavorites = UserDefaults.standard.object(forKey: "favoriteMovies_\(userID)") as? Data {
            let decoder = JSONDecoder()
            if let loadedFavorites = try? decoder.decode([Movie].self, from: savedFavorites) {
                favoriteMovies = loadedFavorites
                NotificationCenter.default.post(name: .favoritesChanged, object: nil)
            }
        } else {
            favoriteMovies = []
        }
    }
 
    func clearCurrentUserData() {
        currentUserID = nil
        favoriteMovies = []
        NotificationCenter.default.post(name: .favoritesChanged, object: nil)
    }
}
 

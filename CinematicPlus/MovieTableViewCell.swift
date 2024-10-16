import UIKit

class MovieTableViewCell: UITableViewCell {
    
    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var voteAverage: UILabel!
    @IBOutlet weak var releaseDate: UILabel!
    @IBOutlet weak var removeFromFavoritesButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
        // Configure the poster image to display in full size
        posterImage.layer.cornerRadius = 8
        posterImage.clipsToBounds = true
        posterImage.contentMode = .scaleAspectFill
        posterImage.layer.borderColor = UIColor.lightGray.cgColor
        posterImage.layer.borderWidth = 1

        // Remove specific size constraints to let it expand to full size
        posterImage.translatesAutoresizingMaskIntoConstraints = false
        posterImage.widthAnchor.constraint(equalTo: posterImage.heightAnchor, multiplier: 2/3).isActive = true  // Keep aspect ratio 2:3 if needed, else remove this line

        // Configure the vote average with smaller font
        voteAverage.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        voteAverage.textColor = UIColor.systemGray
            
        // Configure the release date with smaller font
        releaseDate.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        releaseDate.textColor = UIColor.systemYellow

        // Configure the remove from favorites button
        removeFromFavoritesButton.setTitle("Remove", for: .normal)
        removeFromFavoritesButton.setTitleColor(UIColor.white, for: .normal)
        removeFromFavoritesButton.backgroundColor = UIColor.purple
        removeFromFavoritesButton.layer.cornerRadius = 8
        removeFromFavoritesButton.layer.shadowColor = UIColor.black.cgColor
        removeFromFavoritesButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        removeFromFavoritesButton.layer.shadowOpacity = 0.3
        removeFromFavoritesButton.layer.shadowRadius = 4
        removeFromFavoritesButton.clipsToBounds = false
        removeFromFavoritesButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)

        // Set background color
        self.backgroundColor = UIColor(red: 12/255, green: 17/255, blue: 40/255, alpha: 1)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        contentView.backgroundColor = selected ? UIColor(white: 0.2, alpha: 1) : UIColor(white: 0.1, alpha: 1)
    }
}

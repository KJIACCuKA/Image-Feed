import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    
    weak var delegate: ImagesListCellDelegate?
    private var photoId: String?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
        cellImage.image = nil
    }
    
    @IBAction private func likeButtonTapped(_ sender: UIButton) {
        
        guard let photoId = photoId else { return }
        delegate?.imageListCellDidTapLike(self)
    }
    
    func configure(with photo: Photo, dateFormatter: DateFormatter) {
        // Используйте форматтер для преобразования даты в строку
        let formattedDate = dateFormatter.string(from: photo.createdAt ?? Date())
        dateLabel.text = formattedDate
        
        dateLabel.font = UIFont(name: "SFProText-Regular", size: 16)
        
        let isLiked = photo.isLiked
        let likeImage = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        likeButton.setImage(likeImage, for: .normal)
        
        cellImage.kf.indicatorType = .activity
        let placeholderImage = UIImage(named: "Card")
        if let url = URL(string: photo.thumbImageURL) {
            cellImage.kf.setImage(with: url, placeholder: placeholderImage, options: nil, completionHandler: { result in
                switch result {
                case .success(_):
                    // Do something on success if needed
                    break
                case .failure(let error):
                    print("Error: \(error)")
                }
            })
        }
        
        self.photoId = photo.id
    }
    
    func setIsLiked(_ isLiked: Bool) {
        let likeImage = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        likeButton.setImage(likeImage, for: .normal)
    }
}

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

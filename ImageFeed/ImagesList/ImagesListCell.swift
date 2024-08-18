import UIKit

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    weak var delegate: ImagesListCellDelegate?
    private var animationLayers = Set<CALayer>()
    
    lazy var rectangle: UIImageView = {
        let element = UIImageView()
        element.image = UIImage(named: "Rectangle")
        element.translatesAutoresizingMaskIntoConstraints = false
        return element
    }()
    
    lazy var dateLabel: UILabel = {
        let element = UILabel()
        let date = Date()
        element.text = date.dateTimeString
        element.textAlignment = .left
        element.textColor = .white
        element.font = .systemFont(ofSize: 13)
        element.translatesAutoresizingMaskIntoConstraints = false
        return element
    }()
    
    lazy var imageCell: UIImageView = {
        let element = UIImageView()
        element.layer.cornerRadius = 16
        element.backgroundColor = .ypWhiteAlpha50
        element.layer.masksToBounds = true
        element.contentMode = .scaleAspectFill
        element.isUserInteractionEnabled = true
        element.translatesAutoresizingMaskIntoConstraints = false
        return element
    }()
    
    lazy var likeButton: UIButton = {
        let element = UIButton(type: .custom)
        element.translatesAutoresizingMaskIntoConstraints = false
        element.addTarget(self, action: #selector(likeButtonClicked), for: .touchUpInside)
        return element
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .ypBlack
        self.setView()
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setView() {
        contentView.addSubview(imageCell)
        imageCell.addSubview(rectangle)
        imageCell.addSubview(likeButton)
        imageCell.addSubview(dateLabel)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageCell.kf.cancelDownloadTask()
        for layer in animationLayers {
            layer.removeFromSuperlayer()
        }
        animationLayers.removeAll()
    }
    
    func startLoadingAnimation() {
        let gradient = CAGradientLayer()
        gradient.frame = self.imageCell.bounds
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.duration = 1.0
        animation.fromValue = [0, 0.1, 0.3]
        animation.toValue = [0.7, 0.9, 1]
        animation.repeatCount = .infinity
        
        gradient.add(animation, forKey: "locationsChange")
        animationLayers.insert(gradient)
        self.imageCell.layer.addSublayer(gradient)
    }
    
    func stopLoadingAnimation() {
        animationLayers.forEach { $0.removeFromSuperlayer() }
        animationLayers.removeAll()
    }
    
    private func addGradientLayer(to view: UIView, cornerRadius: CGFloat = 0) {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = cornerRadius
        
        let gradientAnimation = CABasicAnimation(keyPath: "locations")
        gradientAnimation.fromValue = [0, 0.1, 0.3]
        gradientAnimation.toValue = [0, 0.8, 1]
        gradientAnimation.duration = 1.0
        gradientAnimation.repeatCount = .infinity
        
        gradient.add(gradientAnimation, forKey: "locationsChange")
        view.layer.addSublayer(gradient)
        animationLayers.insert(gradient)
    }
    
    @objc func likeButtonClicked() {
        UIBlockingProgressHUD.show()
        delegate?.imageListCellDidTapLike(self)
        UIBlockingProgressHUD.dismiss()
    }
    
    func setIsLiked(_ isLiked: Bool) {
        let likeImage = isLiked ? UIImage(named: "LikeActive") : UIImage(named: "LikeNoActive")
        likeButton.setImage(likeImage, for: .normal)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageCell.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            imageCell.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            imageCell.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            imageCell.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            rectangle.bottomAnchor.constraint(equalTo: imageCell.bottomAnchor),
            rectangle.leadingAnchor.constraint(equalTo: imageCell.leadingAnchor),
            rectangle.trailingAnchor.constraint(equalTo: imageCell.trailingAnchor),
            
            dateLabel.leadingAnchor.constraint(equalTo: imageCell.leadingAnchor, constant: 8),
            dateLabel.bottomAnchor.constraint(equalTo: imageCell.bottomAnchor, constant: -8),
            
            likeButton.trailingAnchor.constraint(equalTo: imageCell.trailingAnchor),
            likeButton.topAnchor.constraint(equalTo: imageCell.topAnchor)
        ])
    }
}

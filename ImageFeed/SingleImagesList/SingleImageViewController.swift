import UIKit
import Kingfisher

protocol SingleImageViewControllerDelegate: AnyObject {
    func singleImageViewController(_ controller: SingleImageViewController, didUpdatePhoto photo: Photo)
}

final class SingleImageViewController: UIViewController {
    
    weak var delegate: SingleImageViewControllerDelegate?
    var photo: Photo?
    private let imagesListService = ImagesListService.shared
    
    private lazy var scrollView: UIScrollView = {
        let element = UIScrollView()
        element.translatesAutoresizingMaskIntoConstraints = false
        element.minimumZoomScale = 0.1
        element.maximumZoomScale = 1.25
        element.delegate = self
        return element
    }()
    
    private lazy var imageView: UIImageView = {
        let element = UIImageView()
        element.contentMode = .scaleAspectFill
        element.translatesAutoresizingMaskIntoConstraints = false
        return element
    }()
    
    private lazy var singleImageButtonsStackView: UIStackView = {
        let element = UIStackView()
        element.axis = .horizontal
        element.distribution = .equalSpacing
        element.translatesAutoresizingMaskIntoConstraints = false
        return element
    }()
    
    private lazy var likeButton: UIButton = {
        let element = UIButton()
        element.setImage(UIImage(named: "LikeСircleNoActive"), for: .normal)
        element.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
        element.translatesAutoresizingMaskIntoConstraints = false
        return element
    }()
    
    private lazy var sharingButton: UIButton = {
        let element = UIButton()
        element.setImage(UIImage(named: "Sharing"), for: .normal)
        element.addTarget(self, action: #selector(didTapSharingButton), for: .touchUpInside)
        element.translatesAutoresizingMaskIntoConstraints = false
        return element
    }()
    
    private lazy var backButton: UIButton = {
        let element = UIButton(type: .system)
        element.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        element.tintColor = .ypWhite
        element.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        element.translatesAutoresizingMaskIntoConstraints = false
        return element
    }()
    
    private lazy var stubImageView: UIImageView = {
        let element = UIImageView()
        element.image = UIImage(named: "Stub")
        element.contentMode = .scaleAspectFit
        element.translatesAutoresizingMaskIntoConstraints = false
        return element
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        
        setView()
        setupConstraints()
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        if let photo = photo {
            updateLikeButton(for: photo.isLiked)
            if let url = URL(string: photo.largeImageURL) {
                setImage(url: url)
            }
        }
    }
    
    private func setView() {
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        view.addSubview(singleImageButtonsStackView)
        singleImageButtonsStackView.addArrangedSubview(likeButton)
        singleImageButtonsStackView.addArrangedSubview(sharingButton)
        view.addSubview(backButton)
        view.addSubview(stubImageView)
    }
    
    @objc private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapSharingButton() {
        guard let image = imageView.image else { return }
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
    }
    
    @objc private func didTapLikeButton() {
        guard let photo = photo else { return }
        
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                switch result {
                case .success:
                    self?.photo?.isLiked.toggle()
                    if let updatedPhoto = self?.photo {
                        self?.delegate?.singleImageViewController(self!, didUpdatePhoto: updatedPhoto)
                        self?.updateLikeButton(for: updatedPhoto.isLiked)
                    }
                case .failure(let error):
                    print("Ошибка изменения состояния лайка: \(error.localizedDescription)")
                }
            }
        }
    }

    func setImage(url: URL) {
        stubImageView.isHidden = false
        imageView.image = nil
        scrollView.zoomScale = 1.0
        scrollView.contentSize = .zero
        
        let options: KingfisherOptionsInfo = [
            .transition(.fade(0.3)),
            .cacheOriginalImage
        ]
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(with: url, placeholder: nil, options: options) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            DispatchQueue.main.async {
                self?.stubImageView.isHidden = true
                switch result {
                case .success(let value):
                    self?.rescaleAndCenterImageInScrollView(image: value.image)
                case .failure(let error):
                    print("Ошибка загрузки полноразмерного изображения: \(error)")
                }
            }
        }
    }
    
    private func updateLikeButton(for isLiked: Bool) {
        let likeImage = isLiked ? UIImage(named: "LikeСircleActive") : UIImage(named: "LikeСircleNoActive")
        likeButton.setImage(likeImage, for: .normal)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            imageView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            likeButton.heightAnchor.constraint(equalToConstant: 51),
            likeButton.widthAnchor.constraint(equalToConstant: 51),
            
            sharingButton.heightAnchor.constraint(equalToConstant: 51),
            sharingButton.widthAnchor.constraint(equalToConstant: 51),
            
            singleImageButtonsStackView.heightAnchor.constraint(equalToConstant: 51),
            singleImageButtonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 68),
            singleImageButtonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -68),
            singleImageButtonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            stubImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stubImageView.widthAnchor.constraint(equalToConstant: 83),
            stubImageView.heightAnchor.constraint(equalToConstant: 75)
        ])
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let imageViewSize = scrollView.bounds.size
        let imageSize = image.size
        let widthScale = imageViewSize.width / imageSize.width
        let heightScale = imageViewSize.height / imageSize.height
        let scale = max(widthScale, heightScale)
        
        scrollView.minimumZoomScale = scale
        scrollView.zoomScale = scale
        
        let newContentSize = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
        scrollView.contentSize = newContentSize
        
        let xOffset = max(0, (newContentSize.width - imageViewSize.width) / 2)
        let yOffset = max(0, (newContentSize.height - imageViewSize.height) / 2)
        scrollView.contentOffset = CGPoint(x: xOffset, y: yOffset)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

import UIKit

final class ProfileViewController: UIViewController {
    let nameLabel = UILabel()
    let mailLabel = UILabel()
    let commentLabel = UILabel()
    let exitButton = UIButton()
    let profileImage = UIImage(named: "avatar")
    let imageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "IFDarkGray")
        profileImageSettings()
        nameLabelSettings()
        mailLabelSettings()
        commentLabelSettings()
        exitButtonSettings()
    }
    
    private func profileImageSettings() {
        imageView.image = profileImage
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
    }
    
    private func nameLabelSettings() {
        nameLabel.text = "Екатерина Новикова"
        view.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.textColor = .white
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
    }
    
    
    private func mailLabelSettings() {
        mailLabel.text = "@ekaterina_nov"
        mailLabel.textColor = UIColor(named: "IFgray")
        view.addSubview(mailLabel)
        mailLabel.translatesAutoresizingMaskIntoConstraints = false
        mailLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        mailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        mailLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
    }
    
    private func commentLabelSettings() {
        commentLabel.text = "Hello, World!"
        commentLabel.textColor = .white
        view.addSubview(commentLabel)
        commentLabel.translatesAutoresizingMaskIntoConstraints = false
        commentLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        commentLabel.topAnchor.constraint(equalTo: mailLabel.bottomAnchor, constant: 8).isActive = true
        commentLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
    }
    
    private func exitButtonSettings() {
        exitButton.setImage(UIImage(named: "logout_button"), for: .normal)
        exitButton.tintColor = .red
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exitButton)
        exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        exitButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        exitButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        exitButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
}

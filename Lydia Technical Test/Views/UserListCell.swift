//
//  UserListCell.swift
//  Lydia Technical Test
//
//  Created by Billy Cauchy-Tharin on 03/06/2023.
//

import UIKit

class UserListCell: UITableViewCell {
    
    let placeholderImage = UIImage(systemName: "person.crop.circle.fill")?.withTintColor(.gray, renderingMode: .alwaysOriginal)
    let userImageHeight = 40.0
    
    private let apiCaller = APICaller()
    
    var imageUrl: String? {
        didSet {
            userImageView.image = placeholderImage
            
            if let imageUrl {
                apiCaller.fetchImage(urlString: imageUrl) { [weak self]  result in
                    if let self {
                        switch result {
                        case .success(let image):
                            DispatchQueue.main.async {
                                self.userImageView.image = image
                            }
                        case.failure(let error):
                            print("Error while fetch image (\(imageUrl)) : \(error)")
                        }
                    }
                }
            }
        }
    }
    
    lazy var userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: "person.crop.circle.fill")
        imageView.layer.cornerRadius = userImageHeight / 2
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let userNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .systemBackground
        setupViews()
    }
    
    func setupViews() {
        addSubview(userImageView)
        addSubview(userNameLabel)
        
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(userImageView.heightAnchor.constraint(equalToConstant: userImageHeight))
        constraints.append(userImageView.widthAnchor.constraint(equalTo: userImageView.heightAnchor))
        constraints.append(userImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16))
        constraints.append(userImageView.topAnchor.constraint(equalTo: topAnchor, constant: 4))
        constraints.append(userImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4))
        
        constraints.append(userNameLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 16))
        constraints.append(userNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16))
        constraints.append(userNameLabel.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

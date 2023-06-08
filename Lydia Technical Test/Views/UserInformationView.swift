//
//  UserInformationView.swift
//  Lydia Technical Test
//
//  Created by Billy Cauchy-Tharin on 06/06/2023.
//

import UIKit

class UserInformationView: UIView {
    
    lazy var informationIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var informationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true
        label.font = .preferredFont(forTextStyle: .body)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var lineView: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .label
        view.layer.opacity = 0.13
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    convenience init(userInformation: UserModel.ViewModel.User.UserInformation) {
        self.init(frame: .zero)
        
        informationLabel.text = userInformation.text
        informationIcon.image = userInformation.icon?.withTintColor(.gray, renderingMode: .alwaysOriginal)
        
        if userInformation.linkType == .phoneNumber {
            informationLabel.textColor = .link
            let tap = UITapGestureRecognizer(target: self, action: #selector(phoneNumberTapped))
            informationLabel.addGestureRecognizer(tap)
        } else if userInformation.linkType == .email {
            informationLabel.textColor = .link
            let tap = UITapGestureRecognizer(target: self, action: #selector(emailTapped))
            informationLabel.addGestureRecognizer(tap)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(informationIcon)
        addSubview(informationLabel)
        addSubview(lineView)
        
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(informationIcon.leadingAnchor.constraint(equalTo: leadingAnchor))
        constraints.append(informationIcon.heightAnchor.constraint(equalToConstant: 20))
        constraints.append(informationIcon.widthAnchor.constraint(equalTo: informationIcon.heightAnchor))
        
        constraints.append(informationLabel.centerYAnchor.constraint(equalTo: informationIcon.centerYAnchor))
        constraints.append(informationLabel.leadingAnchor.constraint(equalTo: informationIcon.trailingAnchor, constant: 8))
        constraints.append(informationLabel.trailingAnchor.constraint(equalTo: trailingAnchor))
        constraints.append(informationLabel.topAnchor.constraint(equalTo: topAnchor))
        
        constraints.append(lineView.heightAnchor.constraint(equalToConstant: 1))
        constraints.append(lineView.leadingAnchor.constraint(equalTo: informationLabel.leadingAnchor))
        constraints.append(lineView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16))
        constraints.append(lineView.topAnchor.constraint(equalTo: informationLabel.bottomAnchor, constant: 4))
        constraints.append(lineView.bottomAnchor.constraint(equalTo: bottomAnchor))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc func emailTapped() {
        if let email = informationLabel.text,
           let url = URL(string: "mailto:\(email)"),
           UIApplication.shared.canOpenURL(url) {
            
            UIApplication.shared.open(url)
        }
    }
    
    @objc func phoneNumberTapped() {
        if let number = informationLabel.text,
           let url = URL(string: "tel:\(number)"),
           UIApplication.shared.canOpenURL(url) {
            
            UIApplication.shared.open(url)
        }
    }
}

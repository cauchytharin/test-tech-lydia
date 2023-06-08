//
//  UserDetailViewController.swift
//  Lydia Technical Test
//
//  Created by Billy Cauchy-Tharin on 03/06/2023.
//

import UIKit
import Contacts
import MapKit

class UserDetailViewController: UIViewController {
    
    let userImageHeight = 120.0
    let sidePadding = 16.0
    let placeholderImage = UIImage(systemName: "person.crop.circle.fill")?.withTintColor(.gray, renderingMode: .alwaysOriginal)
    
    let user: UserModel.ViewModel.User
    
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
    
    lazy var scrollView : UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var contentView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .title1)
        label.text = user.fullNameWithGender ?? user.fullName
        return label
    }()
    
    lazy var userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: "person.crop.circle.fill")
        imageView.layer.cornerRadius = userImageHeight / 2
        imageView.clipsToBounds = true
        imageView.tintColor = .gray
        return imageView
    }()
    
    lazy var informationStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        return stackView
    }()
    
    let mapView: MKMapView = {
        let view = MKMapView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 6
        view.isScrollEnabled = false
        return view
    }()
    
    init(user: UserModel.ViewModel.User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        setupViews()
        
        imageUrl = user.largeImageUrl
    }
    
    func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(informationStackView)
        
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor))
        constraints.append(scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor))
        constraints.append(scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor))
        constraints.append(scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor))
        
        constraints.append(contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor))
        constraints.append(contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor))
        constraints.append(contentView.topAnchor.constraint(equalTo: scrollView.topAnchor))
        constraints.append(contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor))
        
        constraints.append(userImageView.heightAnchor.constraint(equalToConstant: userImageHeight))
        constraints.append(userImageView.widthAnchor.constraint(equalTo: userImageView.heightAnchor))
        constraints.append(userImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor))
        constraints.append(userImageView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor))
        
        constraints.append(userNameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor))
        constraints.append(userNameLabel.topAnchor.constraint(equalTo: userImageView.bottomAnchor, constant: 8))
        
        constraints.append(informationStackView.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: sidePadding))
        constraints.append(informationStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: sidePadding))
        constraints.append(informationStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -sidePadding))
        
        constraints.append(informationStackView.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: sidePadding))
        constraints.append(informationStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: sidePadding))
        constraints.append(informationStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -sidePadding))
    
        NSLayoutConstraint.activate(constraints)
        
        setupInformationViews()
        setupMapView()
    }
    
    func setupInformationViews() {
        for userInformation in user.userInformation {
            let informationView = UserInformationView(userInformation: userInformation)
            informationStackView.addArrangedSubview(informationView)
        }
    }
    
    func setupMapView() {
        if let coordinates = user.coordinates {
            
            let point = MKPointAnnotation()
            point.title = "Position"
            point.coordinate = coordinates
            mapView.addAnnotation(point)
            
            contentView.addSubview(mapView)
            
            var constraints = [NSLayoutConstraint]()
            
            constraints.append(mapView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: sidePadding))
            constraints.append(mapView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -sidePadding))
            constraints.append(mapView.topAnchor.constraint(equalTo: informationStackView.bottomAnchor, constant: sidePadding))
            constraints.append(mapView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -sidePadding))
            constraints.append(mapView.heightAnchor.constraint(equalTo: mapView.widthAnchor))

            NSLayoutConstraint.activate(constraints)
            
            mapView.setCenter(coordinates, animated: false)
        }
    }
    
    func getFlag(country: String) -> String? {
        let base : UInt32 = 127397
        var flagString = ""
        for character in country.unicodeScalars {
            if let newCharacter = UnicodeScalar(base + character.value) {
                flagString.unicodeScalars.append(newCharacter)
            } else {
                return nil
            }
        }
        return String(flagString)
    }
}

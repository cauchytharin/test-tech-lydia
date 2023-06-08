//
//  UserListViewController.swift
//  Lydia Technical Test
//
//  Created by Billy Cauchy-Tharin on 03/06/2023.
//

import UIKit

protocol UserDisplayLogic: AnyObject {
    
    func presentError(viewModel: UserModel.ViewModel)
    func appendUsers(viewModel: UserModel.ViewModel)
    func loadNewUsers(viewModel: UserModel.ViewModel)
}

class UserListViewController: UIViewController {
    
    private let cellReuseIdentifier = "userListCellId"
            
    private var users = [UserModel.ViewModel.User]()
        
    var interactor: UserInteractor?
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        refreshControl.layer.zPosition = -1
        return refreshControl
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UserListCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = refreshControl
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Contacts"
        
        setupTableView()
        setupVipCycle()
        fetchData()
    }
    
    func setupVipCycle() {
        let presenter = UserPresenter()
        self.interactor = UserInteractor()
        interactor?.presenter = presenter
        presenter.viewController = self
    }

    func fetchData(isRefresh: Bool = false) {
        setupFooterView()
        interactor?.fetchItems(request: .init(isRefresh: isRefresh))
    }
    
    func showAlert(errorMessage: String) {
        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func setupTableView() {
        view.addSubview(tableView)
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor))
        constraints.append(tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor))
        constraints.append(tableView.topAnchor.constraint(equalTo: view.topAnchor))
        constraints.append(tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor))

        NSLayoutConstraint.activate(constraints)
    }
    
    func setupFooterView() {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100))
        let spinner = UIActivityIndicatorView()
        spinner.center = footerView.center
        footerView.addSubview(spinner)
        spinner.startAnimating()

        DispatchQueue.main.async {
            self.tableView.tableFooterView = footerView
        }
    }
    
    func refresh() {
        refreshControl.beginRefreshing()
        users = []
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
        
        fetchData(isRefresh: true)
    }
    
    @objc func onRefresh() {
        // Do not refresh if user is still dragging
        if !tableView.isDragging {
            refresh()
        }
    }
}

extension UserListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = users[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as? UserListCell {
            cell.userNameLabel.text = user.fullName
            cell.imageUrl = user.mediumImageUrl
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
            cell.textLabel?.text = user.fullName
            return cell
        }
    }
}

extension UserListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // if user scrolls to last element
        if indexPath.row == users.count - 1 {
            fetchData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 4 + 4 + 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let userDetailVC = UserDetailViewController(user: users[indexPath.row])
        self.navigationController?.pushViewController(userDetailVC, animated: true)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // To refresh only when user let go of finger
        if refreshControl.isRefreshing {
            refresh()
        }
    }
}

extension UserListViewController: UserDisplayLogic {
    
    func presentError(viewModel: UserModel.ViewModel) {
        DispatchQueue.main.async {
            self.tableView.tableFooterView = nil
        }
        
        if let errorMessage = viewModel.errorMessage {
            self.showAlert(errorMessage: errorMessage)
            if self.users.isEmpty {
                if !viewModel.users.isEmpty {
                    self.users = viewModel.users
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } else {
                    // TODO: handle no data to show
                }
            }
        }
    }
    
    func appendUsers(viewModel: UserModel.ViewModel) {
        DispatchQueue.main.async {
            self.tableView.tableFooterView = nil
        }

        let currentUsersCount = self.users.count
        let indexPaths = (currentUsersCount ..< currentUsersCount + viewModel.users.count).map { IndexPath(row: $0, section: 0) }
        self.users.append(contentsOf: viewModel.users)
        DispatchQueue.main.async {
            UIView.performWithoutAnimation {
                self.tableView.insertRows(at: indexPaths, with: .none)
            }
        }
    }
    
    func loadNewUsers(viewModel: UserModel.ViewModel) {
        self.users = viewModel.users
        DispatchQueue.main.async {
            self.tableView.tableFooterView = nil
            self.tableView.reloadData()
        }
    }
}

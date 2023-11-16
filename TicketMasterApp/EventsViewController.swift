//
//  EventsViewController.swift
//  TicketMasterApp
//
//  Created by Jorge Angel Sanchez Martinez on 15/11/23.
//

import UIKit

class EventsViewController: UIViewController {
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(EventTableViewCell.self,
                           forCellReuseIdentifier: EventTableViewCell.identifier)
        tableView.register(EventErrorTableViewCell.self,
                           forCellReuseIdentifier: EventErrorTableViewCell.identifier)
        return tableView
    }()
    private var container: DependencyContainerProtocol
    private var datasource: EventsViewControllerDataSourceProtocol?

    init(container: DependencyContainerProtocol) {
        self.container = container
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = LanguageString.titleNavBar.localized
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.backgroundColor = .purple
        datasource = EventsViewControllerDataSource(tableView: tableView,
                                                    container: container)
        tableView.dataSource = datasource
        tableView.delegate = self
        searchBar.delegate = self
        setupView()
        datasource?.loadData()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        let safeArea = view.layoutMarginsGuide
        view.addSubview(searchBar)
        view.addSubview(tableView)
        searchBar.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
        searchBar.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10).isActive = true
        tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
    }
}

extension EventsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return EventTableViewCell.cellHeight
    }
}

extension EventsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        var searchText = searchBar.text ?? ""
        searchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        datasource?.filterCurrentValueSubject.send(searchText)
    }
}

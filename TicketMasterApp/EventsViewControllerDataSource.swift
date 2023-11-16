//
//  EventsViewControllerDataSource.swift
//  TicketMasterApp
//
//  Created by Jorge Angel Sanchez Martinez on 15/11/23.
//

import Foundation
import UIKit
import Combine
 
protocol EventsViewControllerDataSourceProtocol: UITableViewDataSource {
    var filterCurrentValueSubject: CurrentValueSubject<String, Never> { get }

    func loadData()
}

class EventsViewControllerDataSource: NSObject, EventsViewControllerDataSourceProtocol {
    private var tableView: UITableView
    private let container: DependencyContainerProtocol
    private var eventListViewModel = EventListViewModel()
    private var cancellable = Set<AnyCancellable>()
    private lazy var eventServiceAPI: EventsServiceAPI? = {
        container.resolve(type: EventsServiceAPI.self)
    }()
    private var errorLoading = false
    var filterCurrentValueSubject = CurrentValueSubject<String, Never>("")

    init(tableView: UITableView,
         container: DependencyContainerProtocol) {
        self.tableView = tableView
        self.container = container
        super.init()
        setupBinding()
    }
    
    func setupBinding() {
        filterCurrentValueSubject
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] in
                self?.eventListViewModel.filter(text: $0)
                self?.tableView.reloadData()
            }.store(in: &cancellable)
    }

    func loadData() {
        eventServiceAPI?.fetchEvents()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                if case .failure = completion, !self.errorLoading {
                    self.errorLoading = true
                    self.tableView.isScrollEnabled = false
                    self.tableView.reloadData()
                }
            }, receiveValue: { [weak self] events in
                guard let self = self else { return }
                self.errorLoading = false
                self.eventListViewModel = EventListViewModel(events: events)
                self.tableView.reloadData()
            }).store(in: &cancellable)
    }
}

extension EventsViewControllerDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return  errorLoading ? 1 : eventListViewModel.visibleEvents.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if errorLoading {
            let errorCell: EventErrorTableViewCell = tableView.reuse()
            errorCell.configure(with: "Network Error")
            errorCell.reloadPublisher.sink { [weak self] in
                self?.loadData()
            }.store(in: &cancellable)
            return errorCell
        } else {
            let cell: EventTableViewCell = tableView.reuse()
            cell.configure(with: eventListViewModel.visibleEvents[indexPath.row])
            return cell
        }
    }
}

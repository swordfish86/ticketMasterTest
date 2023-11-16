//
//  TicketMasterAppTests.swift
//  TicketMasterAppTests
//
//  Created by Jorge Angel Sanchez Martinez on 15/11/23.
//

import Combine
import XCTest
@testable import TicketMasterApp

final class TicketMasterAppTests: XCTestCase {
    private var cancellable = Set<AnyCancellable>()

    func testEvent() throws {
        let model: Event = .mock()
        XCTAssertEqual(model.name, "Master Event", "Error in the init property changed")
        XCTAssertTrue(!model.classifications.isEmpty, "Error in the init property changed")
        XCTAssertTrue(!model.images.isEmpty, "Error in the init property changed")
        let classification = try XCTUnwrap(model.classifications.first)
        XCTAssertEqual(classification.segment.name, "sport", "Error in the init property changed")
        let image = try XCTUnwrap(model.images.first)
        XCTAssertEqual(image.url, Mocks.defaultImage, "Error in the init property changed")
        XCTAssertEqual(image.width, 100, "Error in the init property changed")
        XCTAssertEqual(image.height, 100, "Error in the init property changed")
    }

    func testVewModel() throws {
        let eventListViewModel: EventListViewModel = .mock()
        XCTAssertEqual(eventListViewModel.visibleEvents.count, 1, "Error in the init property changed")
        let eventViewModel = try XCTUnwrap(eventListViewModel.visibleEvents.first)
        XCTAssertEqual(eventViewModel.name, "Master Event", "Error in the init property changed")
        XCTAssertEqual(eventViewModel.description, "sport", "Error in the init property changed")
        XCTAssertEqual(eventViewModel.imageUrl, Mocks.defaultImage, "Error in the init property changed")
        XCTAssertEqual(eventViewModel.aspectRatio, 1, "Error in the init property changed")
    }

    func testFilterText() {
        let eventListViewModel: EventListViewModel = .mockEventList()
        XCTAssertEqual(eventListViewModel.visibleEvents.count, 3, "Error with initial visible events")
        eventListViewModel.filter(text: "Event")
        XCTAssertEqual(eventListViewModel.visibleEvents.count, 3, "Error filtering events")
        eventListViewModel.filter(text: "event")
        XCTAssertEqual(eventListViewModel.visibleEvents.count, 3, "Error filtering events should be case insensitive")
        eventListViewModel.filter(text: "master")
        XCTAssertEqual(eventListViewModel.visibleEvents.count, 1, "Error filtering events")
        eventListViewModel.filter(text: "")
        XCTAssertEqual(eventListViewModel.visibleEvents.count, 3, "Error filtering events empty search should show all events")
    }

    func testLoadImage() throws {
        var eventListViewModel: EventListViewModel = .mock()
        var eventViewModel = try XCTUnwrap(eventListViewModel.visibleEvents.first)
        var expectation = self.expectation(description: "Download image error")
        eventViewModel.loadImage()
            .sink(receiveCompletion: { _ in
            }, receiveValue: { _ in
                expectation.fulfill()
            }).store(in: &cancellable)
        waitForExpectations(timeout: 5)
        
        expectation = self.expectation(description: "Download should fail")
        eventListViewModel = .mock(with: "")
        eventViewModel = try XCTUnwrap(eventListViewModel.visibleEvents.first)
        eventViewModel.loadImage()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion,
                    error == .urlError {
                    expectation.fulfill()
                }
            }, receiveValue: { _ in
            }).store(in: &cancellable)
        waitForExpectations(timeout: 5)
    }
    
    func testContainer() throws {
        let container = DependencyContainer.mainContainer
        container.register(type: EventsServiceAPI.self, dependency: EventsService())
        let dependency = container.resolve(type: EventsServiceAPI.self)
        XCTAssertNotNil(dependency, "Dependency injection failed")
        let dependencyNotRegistered = container.resolve(type: MockServiceProtocol.self)
        XCTAssertNil(dependencyNotRegistered, "Dependency injection failed")
    }
    
    func testDataSource() throws {
        let container = DependencyContainer.mainContainer
        container.register(type: EventsServiceAPI.self, dependency: EventsService())
        let tableView = UITableView()
        let dataSource = EventsViewControllerDataSource(tableView: tableView,
                                                        container: container)
        tableView.dataSource = dataSource
        dataSource.loadData()
        let expectation = self.expectation(description: "Fetch call failed")
        let timeout: TimeInterval = 10
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if dataSource.testHook.eventListViewModel.visibleEvents.count > 0 {
                expectation.fulfill()
                timer.invalidate()
            }
        }
        wait(for: [expectation], timeout: timeout)
        
        let filterExpectation = self.expectation(description: "Filter failed")
        dataSource.filterCurrentValueSubject.send("Mia")
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if dataSource.testHook.eventListViewModel.visibleEvents.count == 2 {
                filterExpectation.fulfill()
                timer.invalidate()
            }
        }
        wait(for: [filterExpectation], timeout: timeout)
        
        let eventCell = try XCTUnwrap(tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? EventTableViewCell)
        
        XCTAssertTrue(eventCell.testHook.nameLabel.text?.contains("Miami Heat") ?? false,
                      "Error in EventTableViewCell")
        XCTAssertTrue(eventCell.testHook.descriptionLabel.text == "Sports",
                      "Error in EventTableViewCell")
        XCTAssertNotNil(eventCell.testHook.eventImageView.image)
    }
    
    func testDataSourceFailure() throws {
        let container = DependencyContainer.mainContainer
        let mockService = MockService()
        container.register(type: EventsServiceAPI.self, dependency: mockService)
        let tableView = UITableView()
        let dataSource = EventsViewControllerDataSource(tableView: tableView,
                                                        container: container)
        tableView.dataSource = dataSource
        dataSource.loadData()
        mockService.fetchError(error: .networkError)
        let expectation = expectation(description: "Fetch call succeed")
        let timeout: TimeInterval = 10
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if dataSource.testHook.errorLoading {
                expectation.fulfill()
                timer.invalidate()
            }
        }
        wait(for: [expectation], timeout: timeout)
        tableView.reloadData()

        let errorCell = try XCTUnwrap(tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? EventErrorTableViewCell)
        
        XCTAssertTrue(errorCell.testHook.descriptionErrorLabel.text?.contains(LanguageString.networkError.localized) ?? false,
                      "Error in EventErrorTableViewCell")
        XCTAssertEqual(errorCell.testHook.reloadButton.title(for: .normal),
                       LanguageString.retry.localized,
                       "Error in EventErrorTableViewCell")
        
        let reloadExpectation = self.expectation(description: "Reload events error")
        errorCell.reloadPublisher.sink {
            reloadExpectation.fulfill()
        }.store(in: &cancellable)
        
        errorCell.testHook.reloadButton.sendActions(for: .touchUpInside)
        wait(for: [reloadExpectation], timeout: timeout)
    }
}

private protocol MockServiceProtocol {}

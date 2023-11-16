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
}

private protocol MockServiceProtocol {}

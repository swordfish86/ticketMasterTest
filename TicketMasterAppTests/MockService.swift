//
//  MockService.swift
//  TicketMasterAppTests
//
//  Created by Jorge Angel Sanchez Martinez on 16/11/23.
//

import Combine
import Foundation
@testable import TicketMasterApp

class MockService: EventsServiceAPI {
    private var fetchedResultPublisher = PassthroughSubject<[Event], Error>()

    func fetchEvents() -> AnyPublisher<[Event], Error> {
        return fetchedResultPublisher.eraseToAnyPublisher()
    }

    func fetchError(error: EventError) {
        fetchedResultPublisher.send(completion: .failure(error))
    }
    
    func fetchSuccess() {
        fetchedResultPublisher.send([.mock()])
    }
}

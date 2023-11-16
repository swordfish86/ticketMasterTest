//
//  EventViewModel.swift
//  TicketMasterApp
//
//  Created by Jorge Angel Sanchez Martinez on 15/11/23.
//

import Foundation
import Combine

enum EventError: Error {
    case urlError
    case networkError
}

class EventListViewModel {
    private var events: [EventViewModel]
    var visibleEvents: [EventViewModel] = []

    init(events: [Event] = []) {
        self.events = events.map { EventViewModel(event: $0) }
        self.visibleEvents =  self.events
    }

    func filter(text: String) {
        guard !text.isEmpty else {
            visibleEvents = events
            return
        }
        visibleEvents = events.filter { $0.name.lowercased().contains(text.lowercased()) }
    }
}

class EventViewModel {
    private let event: Event

    fileprivate init(event: Event) {
        self.event = event
    }

    var name: String {
        return event.name
    }

    var imageUrl: String {
        return event.images.first?.url ?? ""
    }
    
    var aspectRatio: Float {
        let width = event.images.first?.width ?? 1
        let height = event.images.first?.height ?? 0
        return Float(width/height)
    }

    var description: String {
        return event.classifications.first?.segment.name ?? ""
    }
    
    func loadImage() -> AnyPublisher<Data, EventError> {
        guard let url = URL(string: imageUrl) else {
            return Fail(error: EventError.urlError).eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .mapError { _ in
                EventError.networkError
            }
            .eraseToAnyPublisher()
    }
}

//
//  EventService.swift
//  TicketMasterApp
//
//  Created by Jorge Angel Sanchez Martinez on 15/11/23.
//

import Foundation
import Combine

protocol EventsServiceAPI {
    func fetchEvents() -> AnyPublisher<[Event], Error>
}

class EventsService: EventsServiceAPI {
    static let shared = EventsService()
    private let baseURL = "https://app.ticketmaster.com/discovery/v2/events.json?"
    
    func fetchEvents() -> AnyPublisher<[Event], Error> {
        guard let url = URL(string: baseURL) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        let apiKey = LocalStorage.shared.value(for: .apiKey)
        let completeUrl = url.appending(queryItems: [URLQueryItem(name: StorageKey.apiKey.rawValue,
                                                                  value: apiKey)])
        return URLSession.shared.dataTaskPublisher(for: completeUrl)
            .map(\.data)
            .decode(type: ReponseEvents.self, decoder: JSONDecoder())
            .map(\._embedded.events)
            .eraseToAnyPublisher()
    }
}

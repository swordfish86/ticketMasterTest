//
//  Mocks.swift
//  TicketMasterAppTests
//
//  Created by Jorge Angel Sanchez Martinez on 16/11/23.
//

import Foundation
@testable import TicketMasterApp

class Mocks {
    static let defaultImage = "https://s1.ticketm.net/dam/a/a01/dc895acf-863e-4f90-9316-98302e99fa01_1761311_RETINA_PORTRAIT_3_2.jpg"
}

extension Event {
    static func mock(name: String = "Master Event",
                     imageUrl: String = Mocks.defaultImage,
                     width: Int = 100,
                     height: Int = 100,
                     segment: String = "sport") -> Event {
        Event(name: name,
              images: [Image(url: imageUrl, width: width, height: height)],
              classifications: [Classification(segment: Segment(name: segment))])
    }
}

extension EventListViewModel {
    static func mock() -> EventListViewModel {
        EventListViewModel(events: [.mock()])
    }
    
    static func mock(with imageUrl: String = "") -> EventListViewModel {
        EventListViewModel(events: [.mock(imageUrl: imageUrl)])
    }
    
    static func mockEventList() -> EventListViewModel {
        EventListViewModel(events: [.mock(),
                                    .mock(name: "Secondary Event"),
                                    .mock(name: "Closing Event")])
    }
}

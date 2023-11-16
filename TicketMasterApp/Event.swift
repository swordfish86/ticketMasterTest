//
//  Event.swift
//  TicketMasterApp
//
//  Created by Jorge Angel Sanchez Martinez on 15/11/23.
//

import Foundation

struct ReponseEvents: Codable {
    let _embedded: Embedded
}

struct Embedded: Codable {
    let events: [Event]
}

struct Event: Codable {
    let name: String
    let images: [Image]
    let classifications: [Classification]
}

struct Image: Codable {
    let url: String
    let width: Int
    let height: Int
}

struct Classification: Codable {
    let segment: Segment
}

struct Segment: Codable {
    let name: String
}

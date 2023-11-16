//
//  LanguageString.swift
//  TicketMasterApp
//
//  Created by Jorge Angel Sanchez Martinez on 16/11/23.
//

import Foundation

enum LanguageString: String {
    case titleNavBar
    case networkError
    case retry
    
    var localized: String {
        return self.rawValue.localized()
    }
}

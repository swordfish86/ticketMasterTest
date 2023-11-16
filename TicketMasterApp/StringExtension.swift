//
//  StringExtension.swift
//  TicketMasterApp
//
//  Created by Jorge Angel Sanchez Martinez on 16/11/23.
//

import Foundation

extension String {

    func localized() ->  String{
        return NSLocalizedString(self, comment: "")
    }
    
    func localized(format: CVarArg...) ->  String{
        return String(format: NSLocalizedString(self, comment: ""), format)
    }
}

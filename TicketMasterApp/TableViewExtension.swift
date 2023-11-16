//
//  TableViewExtension.swift
//  TicketMasterApp
//
//  Created by Jorge Angel Sanchez Martinez on 15/11/23.
//

import Foundation
import UIKit

public extension UITableView {
    func reuse<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        guard let cell = dequeueReusableCell(withIdentifier: identifier) as? T else {
            return T()
        }
        return cell
    }
}

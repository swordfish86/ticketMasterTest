//
//  DependencyContainer.swift
//  TicketMasterApp
//
//  Created by Jorge Angel Sanchez Martinez on 15/11/23.
//

import Foundation

protocol DependencyContainerProtocol {
    func register<Dependency>(type: Dependency.Type, dependency: Any)
    func resolve<Dependency>(type: Dependency.Type) -> Dependency?
}

class DependencyContainer: DependencyContainerProtocol {
    private var registeredDependency: [String: Any] = [:]
    static let mainContainer = DependencyContainer()
    
    private init() {}
    
    func register<Dependency>(type: Dependency.Type, dependency: Any) {
        registeredDependency["\(type)"] = dependency
    }
    
    func resolve<Dependency>(type: Dependency.Type) -> Dependency? {
        registeredDependency["\(type)"] as? Dependency
    }
}

//
//  TicketMasterAppApp.swift
//  TicketMasterApp
//
//  Created by Jorge Angel Sanchez Martinez on 15/11/23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let container = DependencyContainer.mainContainer
        container.register(type: EventsServiceAPI.self, dependency: EventsService())
        let rootController = EventsViewController(container: container)
        window?.rootViewController = rootController
        window?.makeKeyAndVisible()
        return true
    }
}

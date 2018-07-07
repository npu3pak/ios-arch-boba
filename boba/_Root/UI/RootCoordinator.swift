//
//  RootCoordinator.swift
//  boba
//
//  Created by Евгений Сафронов on 07.07.2018.
//  Copyright © 2018 Evgeniy Safronov. All rights reserved.
//

import UIKit

class RootCoordinator {

    private weak var window: UIWindow?
    private let rootViewController: RootViewController

    private var authCoordinator: AuthCoordinator?
    private var menuCoordinator: MenuCoordinator?

    init(window: UIWindow) {
        self.window = window

        let storyboard = UIStoryboard(name: "Root", bundle: Bundle(for: RootCoordinator.self))
        rootViewController = storyboard.instantiateInitialViewController() as! RootViewController
        rootViewController.facade = RootFacade()
        rootViewController.onShowAuth = { [unowned self] in self.showAuth(completion: $0) }
        rootViewController.onShowMenu = { [unowned self] in self.showMenu() }
    }

    func start() {
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
    }

    private func showAuth(completion: @escaping () -> Void) {
        let navigationController = CustomNavigationController()
        authCoordinator = AuthCoordinator(rootNavigationController: navigationController)

        rootViewController.show(controller: navigationController, animated: true)
        authCoordinator?.start(completion: completion)

        // Удаляем ненужный стек контроллеров
        menuCoordinator = nil
    }

    private func showMenu() {
        menuCoordinator = MenuCoordinator()
        rootViewController.show(controller: menuCoordinator!.mainViewController, animated: true)
        menuCoordinator?.start()

        // Удаляем ненужный стек контроллеров
        authCoordinator = nil
    }
}

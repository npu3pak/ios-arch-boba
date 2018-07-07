//
//  MenuCoordinator.swift
//  boba
//
//  Created by Евгений Сафронов on 05.07.2018.
//  Copyright © 2018 Evgeniy Safronov. All rights reserved.
//

import UIKit
import SegueCoordinator

class MenuCoordinator {

    let mainViewController: MenuMainViewController

    private let rootViewController: MenuRootViewController
    private let sideViewController: MenuSideViewController

    private var taskCoordinators = [String: SegueCoordinator]()
    private var sectionCoordinators = [String: SegueCoordinator]()

    init() {
        let storyboard = UIStoryboard(name: "Menu", bundle: Bundle(for: MenuCoordinator.self))

        mainViewController = storyboard.instantiateViewController(withIdentifier: "Main") as! MenuMainViewController
        rootViewController = storyboard.instantiateViewController(withIdentifier: "Root") as! MenuRootViewController
        sideViewController = storyboard.instantiateViewController(withIdentifier: "Side") as! MenuSideViewController

        sideViewController.facade = MenuSideFacade(navigationDelegate: self)

        mainViewController.rootViewController = self.rootViewController
        mainViewController.leftViewController = self.sideViewController
    }

    func start() {
        showExample()
    }
}

extension MenuCoordinator: MenuSideFacadeNavigationDelegate {

    func showExample() {
        showSection("Example") {
            let coordinator = ExampleCoordinator(rootNavigationController: $0)
            coordinator.start(clearStack: true)
            return coordinator
        }
    }
}

extension MenuCoordinator: MenuNavigationControllerDelegate {
    func showSideMenu() {
        mainViewController.showLeftViewAnimated()
    }

    func disableSideMenu() {
        mainViewController.isLeftViewDisabled = true
    }

    func enableSideMenu() {
        mainViewController.isLeftViewDisabled = false
    }
}

extension MenuCoordinator {

    /**
     Показать раздел приложения. При переходе в другой раздел, старый раздел сохранится

     - Parameter overwrite: Если раньше уже был показан раздел приложения, то он будет перезаписан.
     */
    private func showSection(_ id: String, overwrite: Bool = false, action: (UINavigationController) -> SegueCoordinator) {
        // Скрываем боковое меню
        mainViewController.hideLeftViewAnimated()

        // Очищаем координаторы заданий
        taskCoordinators.removeAll()

        // Если не включена перезапись, достаем сохраненный координатор, если он есть
        if !overwrite, let coordinator = sectionCoordinators[id] {
            let navigationController = coordinator.rootNavigationController
            // Оставляем только первый контроллер
            if let firstViewController = navigationController.viewControllers.first {
                navigationController.setViewControllers([firstViewController], animated: false)
            }
            rootViewController.show(controller: navigationController, animated: false)
            return
        }

        // Если координатора нет - создаем его и показываем
        let navigationController = MenuNavigationController()
        navigationController.menuDelegate = self
        rootViewController.show(controller: navigationController, animated: false)
        // Сохраняем координатор
        sectionCoordinators[id] = action(navigationController)
    }
}

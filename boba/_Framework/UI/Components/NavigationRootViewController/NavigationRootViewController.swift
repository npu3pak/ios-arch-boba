//
//  NavigationRootViewController.swift
//  boba
//
//  Created by Евгений Сафронов on 07.07.2018.
//  Copyright © 2018 Evgeniy Safronov. All rights reserved.
//

import UIKit

class NavigationRootViewController: UIViewController {

    private let animationDutation = 0.4

    var childViewController: UIViewController? {
        return childViewControllers.first
    }

    func show(controller: UIViewController, animated: Bool) {
        // Если контроллер уже показан - удаляем все остальные контроллеры
        if childViewControllers.contains(controller) {
            let controllersToRemove = childViewControllers.filter({ $0 !== controller })
            removeChildControllers(controllersToRemove)
            return
        }

        // Помечаем контроллеры для удаления
        let controllersToRemove = childViewControllers

        // Сначала показываем новый стек
        addChildController(controller, animated: animated)

        // После окончания анимации удаляем старый стек
        let timeout = animated ? animationDutation : 0
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
            self.removeChildControllers(controllersToRemove)
        }
    }

    private func addChildController(_ controller: UIViewController, animated: Bool) {
        addChildViewController(controller)
        controller.view.frame = view.frame
        view.addSubview(controller.view)
        controller.didMove(toParentViewController: self)

        if animated {
            controller.view.alpha = 0
            UIView.animate(withDuration: animationDutation) {
                controller.view.alpha = 1
            }
        }
    }

    private func removeChildControllers(_ controllersToRemove: [UIViewController]) {
        for controller in controllersToRemove {
            controller.willMove(toParentViewController: nil)
            controller.view.removeFromSuperview()
            controller.removeFromParentViewController()
        }
    }
}

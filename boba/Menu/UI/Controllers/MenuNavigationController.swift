//
//  MenuNavigationController.swift
//  boba
//
//  Created by Евгений Сафронов on 05.07.2018.
//  Copyright © 2018 Evgeniy Safronov. All rights reserved.
//

import UIKit

protocol MenuNavigationControllerDelegate: class {
    func showSideMenu()
    func disableSideMenu()
    func enableSideMenu()
}

class MenuNavigationController: CustomNavigationController {
    
    weak var menuDelegate: MenuNavigationControllerDelegate?
    
    override func initialize() {
        super.initialize()
        configureControllers()
    }
    
    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        super.setViewControllers(viewControllers, animated: animated)
        configureControllers()
    }
    
    func configureControllers() {
        guard let rootController = viewControllers.first else {
            return
        }
        
        rootController.navigationItem.leftBarButtonItem = UIBarButtonItem(image: Images.Navigation.showMenu, style: .plain, target: self, action: #selector(showSideMenu))
    }
    
    @objc private func showSideMenu() {
        menuDelegate?.showSideMenu()
    }
    
    override func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        super.navigationController(navigationController, didShow: viewController, animated: animated)
        
        let isRoot = viewController === viewControllers.first
        if isRoot {
            menuDelegate?.enableSideMenu()
        } else {
            menuDelegate?.disableSideMenu()
        }
    }
}

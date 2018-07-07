//
//  ExampleCoordinator.swift
//  boba
//
//  Created by Евгений Сафронов on 05.07.2018.
//  Copyright © 2018 Evgeniy Safronov. All rights reserved.
//

import Foundation
import SegueCoordinator

class ExampleCoordinator: SegueCoordinator {

    init(rootNavigationController: UINavigationController) {
        super.init(storyboardName: "Example", bundle: Bundle(for: ExampleCoordinator.self), rootNavigationController: rootNavigationController)
    }

    func start(clearStack: Bool = false) {
        push("Example", type: ExampleViewController.self, clearStack: clearStack) { _ in
            
        }
    }
}

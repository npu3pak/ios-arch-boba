//
//  AuthCoordinator.swift
//  boba
//
//  Created by Евгений Сафронов on 04.07.2018.
//  Copyright © 2018 Evgeniy Safronov. All rights reserved.
//

import SegueCoordinator

class AuthCoordinator: SegueCoordinator {

    init(rootNavigationController: UINavigationController) {
        super.init(storyboardName: "Auth", bundle: Bundle(for: AuthCoordinator.self), rootNavigationController: rootNavigationController)
    }

    func start(clearStack: Bool = false, completion: @escaping () -> Void) {
        push("Auth", type: AuthViewController.self, clearStack: clearStack) {
            $0.facade = AuthFacade()
            $0.onShowConfirmation = { [unowned self] in
                self.showConfirmation($0, completion: completion)
            }
        }
    }

    private func showConfirmation(_ facade: AuthConfirmationFacade, completion: @escaping () -> Void) {
        segue("ShowConfirmation", type: AuthConfirmationViewController.self) {
            $0.facade = facade
            $0.onChangePhone = { [unowned self] in self.pop() }
            $0.onAuthSuccess = completion
        }
    }
}

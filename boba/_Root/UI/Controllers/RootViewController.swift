//
//  RootViewController.swift
//  boba
//
//  Created by Евгений Сафронов on 07.07.2018.
//  Copyright © 2018 Evgeniy Safronov. All rights reserved.
//

import UIKit

class RootViewController: NavigationRootViewController {

    var onShowAuth: ((@escaping () -> Void) -> Void)?
    var onShowMenu: (() -> Void)?

    var facade: RootFacade!

    override func viewDidLoad() {
        super.viewDidLoad()

        facade.delegate = self
        facade.start()
    }
}

extension RootViewController: PRootFacadeDelegate {

    func showAuth(completion: @escaping () -> Void) {
        onShowAuth?(completion)
    }

    func showMenu() {
        onShowMenu?()
    }
}

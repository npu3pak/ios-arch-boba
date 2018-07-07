//
//  MenuSideFacade.swift
//  boba
//
//  Created by Евгений Сафронов on 05.07.2018.
//  Copyright © 2018 Evgeniy Safronov. All rights reserved.
//

import Foundation

protocol MenuSideFacadeUIDelegate: class {
    func updateSelectedItem()
}

protocol MenuSideFacadeNavigationDelegate: class {
    func showExample()
}

class MenuSideFacade {

    weak var uiDelegate: MenuSideFacadeUIDelegate?

    private weak var navigationDelegate: MenuSideFacadeNavigationDelegate?

    private let menuItems: [MenuItem]
    private var selectedIndex: Int = 0

    init(navigationDelegate: MenuSideFacadeNavigationDelegate) {
        self.navigationDelegate = navigationDelegate

        menuItems = [
            MenuItem(title: Strings.Menu.Items.example) { [weak navigationDelegate] in navigationDelegate?.showExample() },
            MenuItem(title: Strings.Menu.Items.logout) { NotificationCenter.default.post(name: Notifications.logoutRequired, object: nil) }
        ]
    }

    var itemsCount: Int {
        return menuItems.count
    }

    subscript(index: Int) -> MenuSideItemFacade {
        let item = menuItems[index]
        let isSelected = selectedIndex == index
        return MenuSideItemFacade(item: item, isSelected: isSelected)
    }

    func selectItem(index: Int) {
        if selectedIndex != index {
            selectedIndex = index
            uiDelegate?.updateSelectedItem()
        }

        let item = menuItems[index]
        item.action?()
    }
}

//
//  MenuSideItemFacade.swift
//  boba
//
//  Created by Евгений Сафронов on 05.07.2018.
//  Copyright © 2018 Evgeniy Safronov. All rights reserved.
//

import Foundation

class MenuSideItemFacade {

    private let item: MenuItem

    init(item: MenuItem, isSelected: Bool) {
        self.item = item
        self.isSelected = isSelected
    }

    let isSelected: Bool

    var title: String {
        return item.title
    }
}

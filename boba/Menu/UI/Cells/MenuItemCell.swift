//
//  MenuItemCell.swift
//  boba
//
//  Created by Евгений Сафронов on 03.07.2018.
//  Copyright © 2018 Evgeniy Safronov. All rights reserved.
//

import UIKit

class MenuItemCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!

    func configure(facade: MenuSideItemFacade) {
        titleLabel.text = facade.title

        if facade.isSelected {
            titleLabel.textColor = Colors.Menu.titleSelected
            backgroundColor = Colors.Menu.backgroundSelected
        } else {
            titleLabel.textColor = Colors.Menu.titleRegular
            backgroundColor = Colors.Menu.backgroundRegular
        }
    }
}

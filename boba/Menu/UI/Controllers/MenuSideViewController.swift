//
//  MenuSideViewController.swift
//  boba
//
//  Created by Евгений Сафронов on 03.07.2018.
//  Copyright © 2018 Evgeniy Safronov. All rights reserved.
//

import UIKit

class MenuSideViewController: UITableViewController, MenuSideFacadeUIDelegate {

    var facade: MenuSideFacade!

    override func viewDidLoad() {
        super.viewDidLoad()

        facade.uiDelegate = self
    }

    func updateSelectedItem() {
        tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return facade.itemsCount
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Item") as! MenuItemCell
        cell.configure(facade: facade[indexPath.row])
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        facade.selectItem(index: indexPath.row)
    }
}

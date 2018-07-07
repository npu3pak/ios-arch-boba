//
//  UITableView+Extensions.swift
//  boba
//
//  Created by Евгений Сафронов on 03.07.2018.
//  Copyright © 2018 Evgeniy Safronov. All rights reserved.
//

import UIKit

public extension UITableView {
    public func scrollToTop() {
        // Без задержки не всегда работает, если контент в таблице перерисовывается
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
        }
    }
    
    public func scrollToBottom() {
        let height = contentSize.height - frame.height + contentInset.bottom
        if height > 0 {
            setContentOffset(CGPoint(x: 0, y: height), animated: true)
        }
    }
}

public extension UITableView {
    public func hideEmptyRows() {
        tableFooterView = UIView()
    }
}

public extension UITableView {
    public func removeTableHeaderView() {
        DispatchQueue.main.async {
            self.tableHeaderView = nil
            //Вручную исправляем отступ после удаления заголовка
            self.contentInset.top = 0
            //Обязательно обновляем
            self.reloadData()
        }
    } 
}

public extension UITableView {
    struct StoredLabel {
        static var label = UILabel()
    }
    
    public func showBackgroundText(_ text: String, textColor: UIColor? = nil, font: UIFont? = nil) {
        if let backgroundView = backgroundView {
            // удаляем, на всякий случай
            StoredLabel.label.removeFromSuperview()
            // кастомизируем
            let margin: CGFloat = 50.0
            StoredLabel.label.frame = CGRect(x: margin, y: 0, width: bounds.width - margin * 2, height: bounds.height)
            StoredLabel.label.textAlignment = .center
            StoredLabel.label.numberOfLines = 0
            StoredLabel.label.lineBreakMode = .byWordWrapping
            StoredLabel.label.text = text
            if let color = textColor {
                StoredLabel.label.textColor = color
            }
            if let font = font {
                StoredLabel.label.font = font
            }
            // добаляем
            backgroundView.addSubview(StoredLabel.label)
        }
    }
    
    public func hideBackgroundText() {
        StoredLabel.label.removeFromSuperview()
    }
}

public extension UITableView {
    public func enableRowAutoHeight(estimated: CGFloat) {
        rowHeight = UITableViewAutomaticDimension
        estimatedRowHeight = estimated
    }
}

public extension UITableView {
    public func setBackgroundImage(named: String) {
        backgroundView = UIImageView(image: UIImage(named: named))
    }
}

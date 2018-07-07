//
//  UITableViewControllerExtensions.swift
//  boba
//
//  Created by Евгений Сафронов on 03.07.2018.
//  Copyright © 2018 Evgeniy Safronov. All rights reserved.
//

import UIKit

public protocol Overlay {
    
}

public extension UIViewController {
    public func showLoadingOverlay(transparent: Bool = false, inside containerView: UIView? = nil) {
        hideOverlay(inside: containerView)
        
        let bundle = Bundle(for: TableLoadingOverlay.self)
        let view = bundle.loadNibNamed("Overlays", owner: self, options: nil)![0] as! TableLoadingOverlay
        
        if transparent {
            view.backgroundColor = UIColor.clear
        }
        
        showProgressIndicator(in: view)
        showOverlay(view, inside: containerView)
    }
    
    public func showLoadingErrorOverlay(transparent: Bool = false, inside containerView: UIView? = nil, retryAction: @escaping (() -> Void)) {
        showMessageOverlay(transparent: transparent, title: "Не удалось загрузить данные", buttonTitle: "ПОВТОРИТЬ", inside: containerView, buttonAction: retryAction)
    }
    
    public func showMessageOverlay(transparent: Bool = false, title: String, buttonTitle: String, inside containerView: UIView? = nil, buttonAction: @escaping (() -> Void)) {
        hideOverlay(inside: containerView)
        
        let bundle = Bundle(for: TableMessageWithButtonOverlay.self)
        let view = bundle.loadNibNamed("Overlays", owner: self, options: nil)![1] as! TableMessageWithButtonOverlay
        if transparent {
            view.backgroundColor = UIColor.clear
        }
        view.configure(title: title, buttonTitle: buttonTitle, buttonAction: buttonAction)
        showOverlay(view, inside: containerView)
    }
    
    public func showMessageOverlay(transparent: Bool = false, title: String, inside containerView: UIView? = nil) {
        hideOverlay(inside: containerView)
        
        let bundle = Bundle(for: TableMessageOverlay.self)
        let view = bundle.loadNibNamed("Overlays", owner: self, options: nil)![2] as! TableMessageOverlay
        if transparent {
            view.backgroundColor = UIColor.clear
        }
        view.configure(title: title)
        showOverlay(view, inside: containerView)
    }
    
    public func showOverlay(_ overlayView: UIView, inside containerView: UIView? = nil) {
        hideOverlay(inside: containerView)
        
        guard overlayView is Overlay else {
            return
        }
        
        overlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        if let containerView = containerView {
            overlayView.frame = containerView.bounds
            containerView.isUserInteractionEnabled = false
            //Помещаем не внутри, а над контейнером.
            containerView.superview?.addSubview(overlayView)
        } else if let tableViewController = self as? UITableViewController {
            let tableView = tableViewController.tableView!
            // Показываем оверлей чуть выше ячеек таблицы
            overlayView.layer.zPosition = 1
            // Поскольку таблица может быть сдвинута в момент показа оверлея, мы не можем положиться ни на копирование bounds ни на копирование frame
            overlayView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: tableView.frame.height)
            // Отключаем скроллинг, чтобы оверлей не болтался вместе с содержимым таблицы
            tableView.isScrollEnabled = false
            tableView.addSubview(overlayView)
        } else {
            overlayView.frame = self.view.bounds
            self.view.addSubview(overlayView)
        }
        
        if isFirtsResponderVisible {
            let dy = getFirstResponderHeight()
            overlayView.frame = overlayView.frame.offsetBy(dx: 0, dy: -dy*2)
        }
    }
    
    var isFirtsResponderVisible: Bool {
        return view.subviews.first(where: { $0.isFirstResponder })?.isFirstResponder ?? false
    }
    
    func getFirstResponderHeight() -> CGFloat {
        return view.subviews.first(where: { $0.isFirstResponder })?.bounds.size.height ?? 0
    }
    
    public func hideOverlay(inside containerView: UIView? = nil) {
        if let container = containerView {
            container.isUserInteractionEnabled = true
            container.superview?.subviews
                .filter({$0 is Overlay})
                .forEach({
                    hideProgressIndicator(in: $0)
                    $0.removeFromSuperview()
                })
        } else if let tableViewController = self as? UITableViewController {
            tableViewController.tableView.isScrollEnabled = true
            tableViewController.tableView.subviews
                .filter({$0 is Overlay })
                .forEach({
                    hideProgressIndicator(in: $0)
                    $0.removeFromSuperview()
                })
        } else {
            self.view.subviews
                .filter({$0 is Overlay})
                .forEach({
                    hideProgressIndicator(in: $0)
                    $0.removeFromSuperview()
                })
        }
        
    }
}

public class TableLoadingOverlay: UIView, Overlay {
}

public class TableMessageOverlay: UIView, Overlay {
    @IBOutlet weak var messageLabel: UILabel!
    
    func configure(title: String) {
        messageLabel.text = title
    }
}

public class TableMessageWithButtonOverlay: UIView, Overlay {
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    private var buttonAction: (() -> Void)?
    
    func configure(title: String, buttonTitle: String, buttonAction: @escaping (() -> Void)) {
        self.buttonAction = buttonAction
        messageLabel.text = title
        button.setTitle(buttonTitle.uppercased(), for: UIControlState())
        button.addTarget(self, action: #selector(onButtonClick), for: .touchUpInside)
    }
    
    @objc private func onButtonClick() {
        buttonAction?()
    }
}

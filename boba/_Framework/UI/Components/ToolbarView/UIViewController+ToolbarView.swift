//
//  UIViewController+ToolbarView.swift
//  boba
//
//  Created by Евгений Сафронов on 03.07.2018.
//  Copyright © 2018 Evgeniy Safronov. All rights reserved.
//

import UIKit

public extension UIViewController {
    public func showToolbarButton(title: String, color: UIColor, enabled: Bool = true, target: Any?, action: Selector) {
        let button = UIButton(type: .system)
        button.setTitle(title, for: UIControlState())
        button.isEnabled = enabled
        button.tintColor = enabled ? UIColor.white : UIColor.darkGray
        button.addTarget(target, action: action, for: .touchUpInside)
        
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        container.backgroundColor = enabled ? color : UIColor.clear
        container.addSubview(button)
        button.frame = container.bounds
        button.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        showToolbarView(contentView: container)
    }
    
    public func showToolbarView(contentView: UIView) {
        // Убеждаемся, что контроллер виден на экране
        guard navigationController?.topViewController === self else {
            return
        }
        
        if let toolbar = navigationController?.toolbar {
            navigationController?.toolbar.subviews.first(where: {$0 is ToolbarView})?.removeFromSuperview()
            navigationController?.setToolbarHidden(false, animated: false)
            
            // Для iOS 11 нужно обновить subview, чтобы contentView тулбара встал на свое место
            toolbar.layoutIfNeeded()
            
            let customToolbar = ToolbarView(toolbar: toolbar, contentView: contentView)
            toolbar.addSubview(customToolbar)
        }
    }
    
    public func hideToolbarView() {
        navigationController?.toolbar.subviews.first(where: {$0 is ToolbarView})?.removeFromSuperview()
        navigationController?.setToolbarHidden(true, animated: false)
    }
}

private class ToolbarView: UIView {
    
    weak var toolbar: UIToolbar?
    
    init(toolbar: UIToolbar, contentView: UIView) {
        super.init(frame: toolbar.bounds)
        self.toolbar = toolbar
        toolbar.addObserver(self, forKeyPath: #keyPath(bounds), options: .new, context: nil)
        
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        toolbar?.removeObserver(self, forKeyPath: #keyPath(bounds))
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(bounds) {
            if let bounds = toolbar?.bounds {
                frame = bounds
            }
        }
    }
}

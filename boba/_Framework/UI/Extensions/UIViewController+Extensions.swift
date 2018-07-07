//
//  UIViewController+Extensions.swift
//  boba
//
//  Created by Евгений Сафронов on 03.07.2018.
//  Copyright © 2018 Evgeniy Safronov. All rights reserved.
//

import UIKit
import MBProgressHUD

// MARK: Индикаторы загрузки

public extension UIViewController {
    public func showProgressIndicator() {
        guard let view = navigationController?.view else {
            return
        }
        showProgressIndicator(in: view)
    }
    
    public func hideProgressIndicator() {
        guard let view = navigationController?.view else {
            return
        }
        hideProgressIndicator(in: view)
    }
    
    public func showProgressIndicator(in view: UIView) {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.bezelView.color = UIColor.black
        hud.contentColor = UIColor.white
    }
    
    public func hideProgressIndicator(in view: UIView) {
        MBProgressHUD.hide(for: view, animated: true)
    }
}

// MARK: Диалоговые окна
public extension UIViewController {
    
    /*
     showQuestionAlert("Вы уверены?", answers: [("Да", {}), ("Нет", nil)])
    */
    public func showQuestionAlert(_ text: String, title: String = "", answers: [(String, UIAlertActionStyle, (() -> Void)?)]) {
        let alertController = UIAlertController(title: title, message: text, preferredStyle: .alert)
        for (title, style, action) in answers {
            alertController.addAction(UIAlertAction(title: title, style: style) { _ in
                DispatchQueue.main.async {
                    action?()
                }
            })
        }
        present(alertController, animated: true, completion: nil)
    }
    
    /*
     showYesNoQuestionAlert("Вы готовы?") {  print("Был ответ Да")  }
    */
    public func showYesNoQuestionAlert(_ text: String, title: String = "", negativeAction: (() -> Void)? = nil, positiveAction: (() -> Void)?) {
        showQuestionAlert(text, title: title, answers: [("Да", .default, positiveAction), ("Нет", .cancel, negativeAction)])
    }
    
    public func showAlert(title: String, text: String, closeAction: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: text, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            DispatchQueue.main.async {
                closeAction?()
            }
        })
        present(alertController, animated: true, completion: completion)
    }
    
    /*
     showAlert("Сообщение", closeAction: {print("Нажата кнопка ОК")}) {print("Окно закончило анимацию отображения")}
    */
    public func showAlert(_ text: String, closeAction: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: "", message: text, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel) { _ in
            DispatchQueue.main.async {
                closeAction?()
            }
        })
        present(alertController, animated: true, completion: completion)
    }
    
    /*
     Показываем или переопределяем кнопку "Назад"
    */
    public func setBackButton(action: Selector, target: AnyObject?) {
        if let item = navigationItem.backBarButtonItem {
            item.target = target
            item.action = action
        } else {
            let item = UIBarButtonItem(image: UIImage(named: "navigation_back"), style: .plain, target: target, action: action)
            navigationItem.leftBarButtonItem = item
        }
    }
}

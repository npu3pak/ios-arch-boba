//
//  WebViewUIDelegate.swift
//  boba
//
//  Created by Евгений Сафронов on 03.07.2018.
//  Copyright © 2018 Evgeniy Safronov. All rights reserved.
//

import Foundation
import WebKit

public class WebViewUIDelegate: NSObject, WKUIDelegate {
    
    private weak var controller: UIViewController?
    
    public init(controller: UIViewController) {
        super.init()
        
        self.controller = controller
    }
    
    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            DispatchQueue.main.async {
                completionHandler()
            }
        }
        alertController.addAction(okAction)
        
        DispatchQueue.main.async {
            self.controller?.present(alertController, animated: true, completion: nil)
        }
    }
    
    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .default) { _ in
            DispatchQueue.main.async {
                completionHandler(false)
            }
        }
        alertController.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "Продолжить", style: .default) { _ in
            DispatchQueue.main.async {
                completionHandler(true)
            }
        }
        alertController.addAction(okAction)
        
        DispatchQueue.main.async {
            self.controller?.present(alertController, animated: true, completion: nil)
        }
    }
    
    public func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alertController = UIAlertController(title: "", message: prompt, preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.text = defaultText
        }
        
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            let textField = alertController.textFields![0]
            DispatchQueue.main.async {
                completionHandler(textField.text)
            }
        }
        alertController.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { _ in
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
        alertController.addAction(cancelAction)
        
        DispatchQueue.main.async {
            self.controller?.present(alertController, animated: true, completion: nil)
        }
    }
}

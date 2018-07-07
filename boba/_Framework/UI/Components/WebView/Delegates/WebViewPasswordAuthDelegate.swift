//
//  WebViewPasswordAuthDelegate.swift
//  boba
//
//  Created by Евгений Сафронов on 03.07.2018.
//  Copyright © 2018 Evgeniy Safronov. All rights reserved.
//

import Foundation
import WebKit

public class WebViewPasswordAuthDelegate: NSObject, WebViewAuthDelegate {
    
    private weak var controller: UIViewController?
    
    var defaultUser: String?
    var defaultPassword: String?
    
    public init(controller: UIViewController, defaultUser: String? = nil, defaultPassword: String? = nil) {
        super.init()
        
        self.controller = controller
        self.defaultUser = defaultUser
        self.defaultPassword = defaultPassword
    }
    
    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let host = webView.url?.host
        let authMethod = challenge.protectionSpace.authenticationMethod
        
        if authMethod == NSURLAuthenticationMethodDefault || authMethod == NSURLAuthenticationMethodHTTPBasic || authMethod == NSURLAuthenticationMethodHTTPDigest {
            
            let alertController = UIAlertController(title: host ?? "", message: "Требуется авторизация", preferredStyle: .alert)
            
            alertController.addTextField { [weak self] (textField) in
                textField.placeholder = "Логин"
                textField.text = self?.defaultUser
            }
            alertController.addTextField { [weak self] (textField) in
                textField.placeholder = "Пароль"
                textField.isSecureTextEntry = true
                textField.text = self?.defaultPassword
            }
            
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                let userTextField = alertController.textFields![0]
                let passwordTextField = alertController.textFields![1]
                
                let user = userTextField.text ?? ""
                let password = passwordTextField.text ?? ""
                
                DispatchQueue.main.async {
                    let credential = URLCredential(user: user, password: password, persistence: .forSession)
                    completionHandler(.useCredential, credential)
                }
            }
            alertController.addAction(okAction)
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { _ in
                DispatchQueue.main.async {
                    completionHandler(.cancelAuthenticationChallenge, nil)
                }
            }
            alertController.addAction(cancelAction)
            
            DispatchQueue.main.async {
                self.controller?.present(alertController, animated: true, completion: nil)
            }
        } else if authMethod == NSURLAuthenticationMethodServerTrust {
            completionHandler(.performDefaultHandling, nil)
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}

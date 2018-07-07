//
//  WKWebViewConfigurationExtensions.swift
//  boba
//
//  Created by Евгений Сафронов on 03.07.2018.
//  Copyright © 2018 Evgeniy Safronov. All rights reserved.
//

import WebKit

public extension WKWebViewConfiguration {
    public func setFontSize(_ fontSize: WebViewFontSize) {
        let source  = "document.getElementsByTagName('body')[0].style.fontSize= '\(fontSize.rawValue)';"
        let script: WKUserScript = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        
        self.userContentController.addUserScript(script)
    }
    
    public func textSizeAdjust(percent: Int) {
        let source  = "document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '\(percent)%';"
        let script: WKUserScript = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        
        self.userContentController.addUserScript(script)
    }
    
    public func disableMagnification() {
        // Javascript that disables pinch-to-zoom by inserting the HTML viewport meta tag into <head>
        let source = "var meta = document.createElement('meta');" +
            "meta.name = 'viewport';" +
            "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
            "var head = document.getElementsByTagName('head')[0];" +
        "head.appendChild(meta);"
        let script: WKUserScript = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        
        self.userContentController.addUserScript(script)
    }
}

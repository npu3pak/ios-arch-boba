//
//  WebView.swift
//  boba
//
//  Created by Евгений Сафронов on 03.07.2018.
//  Copyright © 2018 Evgeniy Safronov. All rights reserved.
//

import Foundation
import WebKit

public protocol WebViewAuthDelegate: class {
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
}

public protocol WebViewLoadingDelegate: class {
    func onWebViewLoadingFinish()
    func onWebViewLoadingCancel()
    func onWebViewLoadingError(_ error: WebViewError)
}

public enum WebViewUrlAction {
    case openInWebView
    case openInSafari
    case cancel
}

public class WebView: UIView, WKNavigationDelegate {

    public var onStartLoadingUrl: ((URL) -> Void)?
    
    public weak var loadingDelegate: WebViewLoadingDelegate?
    public weak var authDelegate: WebViewAuthDelegate?

    private var webView: WKWebView!
    private var cookies: [HTTPCookie]?

    // Хост страницы, которая изначально загружается в WebView. Только для нее будут подставляться куки
    private var initialRequestHost: String?

    // Хранилище куков для iOS 10 и более ранних
    private var legacyCookieStorage: HTTPCookieStorage?
    
    public var uiDelegate: WKUIDelegate? {
        get { return webView.uiDelegate }
        set { webView.uiDelegate = newValue }
    }
    
    public var allowBackForwardNavigationGestures: Bool {
        get { return webView.allowsBackForwardNavigationGestures }
        set { webView.allowsBackForwardNavigationGestures = newValue }
    }

    // Определяет действие при открытии ссылок
    public var linksActionResolver: (URL) -> WebViewUrlAction = { _ in .openInSafari }

    // MARK: - Инициализация

    /**
     Создает WebView с куками. Куки, судя по всему, должны быть помещены в хранилище до создания WebView, иначе их работа не гарантируется
     https://stackoverflow.com/a/49534854
    */
    public static func instantiateWithCookies(storageId: String, cookies: [HTTPCookie], frame: CGRect, configuration: WKWebViewConfiguration?, completion: @escaping (WebView) -> Void) {
        let configuration = configuration ?? defaultConfiguration()
        
        // В iOS 11 используем новый механизм cookieStore. В предыдущих версиях используем HTTPCookieStorage.
        // Разница в том, что первый берет на себя всю заботу об использовании куков в каждом запросе.
        // Второй требует ручного вмешательства в куки в каждом запросе. Поэтому необходим хак, реализованный в методе делегата webView decidePolicyFor
        
        guard #available(iOS 11, *) else {
            let cookieStorage = HTTPCookieStorage.sharedCookieStorage(forGroupContainerIdentifier: storageId)
            cookieStorage.cookieAcceptPolicy = .always
            // Удаляем все старые куки
            cookieStorage.removeCookies(since: Date.distantPast)
            // Помещаем новые куки
            for cookie in cookies {
                cookieStorage.setCookie(cookie)
            }
            
            let webView = WebView(frame: frame, configuration: configuration)
            webView.legacyCookieStorage = cookieStorage
            webView.cookies = cookies
            completion(webView)
            return
        }

        let dataStore = WKWebsiteDataStore.nonPersistent()
        let cookieStore = dataStore.httpCookieStore

        cookieStore.setCookies(cookies) {
            configuration.websiteDataStore = dataStore
            let webWiew = WebView(frame: frame, configuration: configuration)
            webWiew.cookies = cookies
            completion(webWiew)
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        initialize(configuration: WebView.defaultConfiguration())
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)

        initialize(configuration: WebView.defaultConfiguration())
    }
    
    public init(frame: CGRect, disabledMagnification: Bool) {
        super.init(frame: frame)
        
        let configuration: WKWebViewConfiguration = WebView.defaultConfiguration()
        if disabledMagnification {
            configuration.disableMagnification()
        }
        initialize(configuration: configuration)
    }
    
    public init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame)

        initialize(configuration: configuration)
    }
    
    private static func defaultConfiguration() -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = WKUserContentController()
        return configuration
    }
    
    public func initialize(configuration: WKWebViewConfiguration) {
        webView = WKWebView(frame: bounds, configuration: configuration)
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(webView)

        let views: [String: Any] = ["webView": webView!]
        var constraints = [NSLayoutConstraint]()
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[webView]-0-|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[webView]-0-|", options: [], metrics: nil, views: views)
        NSLayoutConstraint.activate(constraints)
    }

    // MARK: - Загрузка

    public func reload() {
        webView.reload()
    }
    
    public func load(urlString: String) {
        if let url = URL(string: urlString) {
            load(url: url)
        } else {
            loadingDelegate?.onWebViewLoadingError(WebViewError.badUrl)
        }
    }
    
    public func load(url: URL) {
        let request = URLRequest(url: url)
        load(request: request)
    }
    
    private func load(request: URLRequest) {
        if #available(iOS 11, *) {
            webView.load(request)
        } else {
            initialRequestHost = request.url?.host
            let requestWithCookies = addingCookiesFromStorage(to: request)
            webView.load(requestWithCookies)
        }
    }
    
     // MARK: - Навигация
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        // На iOS 11 куки сохраняются автоматически
        if #available(iOS 11.0, *) {
            decisionHandler(.allow)
            return
        }

        // На iOS 10 и раньше куки сохраняем в хранилище вручную
        if let urlResponse = navigationResponse.response as? HTTPURLResponse {
            saveCookiesToStorage(from: urlResponse)
        }
        decisionHandler(.allow)
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        // Открытие ссылок
        if navigationAction.navigationType == .linkActivated {
            let linkAction = linksActionResolver(url)
            if linkAction == .openInSafari {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
                decisionHandler(.cancel)
                return
            } else if linkAction == .cancel {
                decisionHandler(.cancel)
                return
            }
        }

        // После iOS 11 куки подставляются автоматически
        if #available(iOS 11.0, *) {
            onStartLoadingUrl?(url)
            decisionHandler(.allow)
            return
        }

        // Для старых iOS ловим запросы и подставляем куки вручную
        let cookieHeaderIsPresent = navigationAction.request.allHTTPHeaderFields?.keys.contains("Cookie") ?? false
        let hasCustomCookies = self.cookies?.count ?? 0 > 0
        let hasUrlCookies = self.hasCookies(for: url)
        // Подставляем куки только если запрос относится к тому же хосту, что и начальная страница
        let isInitialPageHost = self.initialRequestHost == url.host

        if isInitialPageHost && hasCustomCookies && hasUrlCookies && !cookieHeaderIsPresent {
            var request = URLRequest(url: url)
            request = addingCookiesFromStorage(to: request)
            webView.load(request)
            decisionHandler(.cancel)
            return
        } else {
            onStartLoadingUrl?(url)
            decisionHandler(.allow)
        }
    }
    
    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if let authDelegate = self.authDelegate {
            authDelegate.webView(webView, didReceive: challenge, completionHandler: completionHandler)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingDelegate?.onWebViewLoadingFinish()
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        onNavigationError(error)
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        onNavigationError(error)
    }
    
    private func onNavigationError(_ error: Error) {
        let urlError = error as? URLError
        
        if urlError != nil {
            print(urlError!.localizedDescription)
        }
        
        // Игнорируем отмененные запросы
        guard urlError?.errorCode != NSURLErrorCancelled else {
            loadingDelegate?.onWebViewLoadingCancel()
            return
        }
        
        loadingDelegate?.onWebViewLoadingError(WebViewError.translateFrom(error))
    }
    
    // MARK: - Работа с куками
    
    private func saveCookiesToStorage(from urlResponse: HTTPURLResponse) {
        guard let url = urlResponse.url else {
            return
        }

        guard let allHeaderFields = urlResponse.allHeaderFields as? [String: String] else {
            return
        }

        let cookies = HTTPCookie.cookies(withResponseHeaderFields: allHeaderFields, for: url)
        legacyCookieStorage?.setCookies(cookies, for: urlResponse.url!, mainDocumentURL: nil)
    }

    private func hasCookies(for url: URL) -> Bool {
        return legacyCookieStorage?.cookies(for: url)?.count ?? 0 > 0
    }
    
    private func addingCookiesFromStorage(to request: URLRequest) -> URLRequest {
        guard let url = request.url else {
            return request
        }

        guard let cookies = legacyCookieStorage?.cookies(for: url) else {
            return request
        }

        var request = request
        for (header, value) in HTTPCookie.requestHeaderFields(with: cookies) {
            request.addValue(value, forHTTPHeaderField: header)
        }
        return request
    }
}

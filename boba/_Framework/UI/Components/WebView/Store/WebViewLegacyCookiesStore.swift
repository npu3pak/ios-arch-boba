//
//  WebViewLegacyCookiesStore.swift
//  boba
//
//  Created by Евгений Сафронов on 03.07.2018.
//  Copyright © 2018 Evgeniy Safronov. All rights reserved.
//

import Foundation

class WebViewLegacyCookiesStore {

    private static let lockQueue = DispatchQueue(label: "lockQueue")

    private var storedCookies = [String: HTTPCookie]()

    init(cookies: [HTTPCookie]?) {
        for cookie in cookies ?? [] {
            let key = cookieKey(for: cookie)
            storedCookies[key] = cookie
        }
    }

    private func cookieKey(for cookie: HTTPCookie) -> String {
        return cookie.domain + cookie.path + cookie.name
    }

    func setCookies(_ cookies: [HTTPCookie], for url: URL) {
        let urlHost = url.host

        let validCookies = cookies.filter { urlHost == $0.domain }
        for cookie in validCookies {
            setCookie(cookie)
        }
    }

    func setCookie(_ cookie: HTTPCookie) {
        WebViewLegacyCookiesStore.lockQueue.sync {
            // Добавляем куки
            let key = cookieKey(for: cookie)
            if storedCookies.index(forKey: key) != nil {
                storedCookies.updateValue(cookie, forKey: key)
            } else {
                storedCookies[key] = cookie
            }
            // Удаляем устаревшие куки
            let expired = storedCookies.filter { (_, value) in
                value.expiresDate != nil && value.expiresDate!.timeIntervalSinceNow < 0
            }
            for (key, _) in expired {
                self.storedCookies.removeValue(forKey: key)
            }
        }
    }

    func deleteCookie(_ cookie: HTTPCookie) {
        WebViewLegacyCookiesStore.lockQueue.sync {
            let key = cookieKey(for: cookie)
            self.storedCookies.removeValue(forKey: key)
        }
    }

    func cookies(for url: URL) -> [HTTPCookie]? {
        guard let host = url.host else {
            return nil
        }

        let syncStored = WebViewLegacyCookiesStore.lockQueue.sync {storedCookies}
        return Array(syncStored.values.filter { $0.domain == host })
    }
}

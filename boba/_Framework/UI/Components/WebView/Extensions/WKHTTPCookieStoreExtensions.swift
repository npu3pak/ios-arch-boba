//
//  WKHTTPCookieStoreExtensions.swift
//  boba
//
//  Created by Евгений Сафронов on 03.07.2018.
//  Copyright © 2018 Evgeniy Safronov. All rights reserved.
//

import WebKit

@available(iOS 11.0, *)
extension WKHTTPCookieStore {
    
    func setCookies(_ cookies: [HTTPCookie], completion: @escaping () -> Void) {
        let dispatchGroup = DispatchGroup()
        
        for cookie in cookies {
            dispatchGroup.enter()
            setCookie(cookie, completionHandler: dispatchGroup.leave)
        }
        
        dispatchGroup.notify(queue: .main) {
            completion()
        }
    }
}

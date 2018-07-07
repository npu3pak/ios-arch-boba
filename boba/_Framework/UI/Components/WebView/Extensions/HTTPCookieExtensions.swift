//
//  HTTPCookieExtensions.swift
//  boba
//
//  Created by Евгений Сафронов on 03.07.2018.
//  Copyright © 2018 Evgeniy Safronov. All rights reserved.
//

import Foundation

public extension HTTPCookie {
    
    public static func cookieWith(name: String, value: String, url: String) -> HTTPCookie? {
        let properties: [HTTPCookiePropertyKey: Any] = [
            .domain: URL(string: url)?.host ?? "",
            .path: "/",
            .name: name,
            .value: value
        ]
        
        guard let cookie = HTTPCookie(properties: properties) else {
            print("Не удалось создать Cookie с указанными свойствами\n\(properties)")
            return nil
        }
        
        return cookie
    }
}

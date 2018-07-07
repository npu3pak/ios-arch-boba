//
//  WebViewError.swift
//  boba
//
//  Created by Евгений Сафронов on 03.07.2018.
//  Copyright © 2018 Evgeniy Safronov. All rights reserved.
//

import Foundation

public enum WebViewError: Error {
    case unableToLoadURL(code: Int) //  универсальная ошибка - загрузка невозможна
    case unknownError // неизвестная ошибка
    case notConnectedToInternet // нет соединения с интернетом
    case badUrl
    case timeOut
    case SSLUntrusted(code: Int) // все ошибки связанные с недоверенным  SSL (истек срок действия сертификата, сертификат отозван и т.п.)

    public static func translateFrom(_ error: Error) -> WebViewError {
        if let urlError = error as? URLError {
            switch urlError.errorCode {
            case NSURLErrorUnknown:
                return .unknownError
            case NSURLErrorNotConnectedToInternet:
                return .notConnectedToInternet
            case NSURLErrorBadURL:
                return .badUrl
            case NSURLErrorTimedOut:
                return .timeOut
            default:
                return .unableToLoadURL(code: urlError.errorCode)
            }
        } else {
            return .unknownError
        }
    }
}

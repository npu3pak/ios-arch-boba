//
//  UserError.swift
//  boba
//
//  Created by Евгений Сафронов on 02.07.2018.
//  Copyright © 2018 Evgeniy Safronov. All rights reserved.
//

import Foundation

enum UserError {
    case message(String, Error?)
    case fault(code: Int, message: String?)
    case authenticate
    case noConnection

    static func fromError(_ error: Error) -> UserError {
        switch error {
        case is UserError: return error as! UserError
        default: return .message("Ошибка. Пожалуйста сообщите о проблеме разработчикам.", error)
        }
    }

    static func withMessage(_ message: String) -> UserError {
        return .message(message, nil)
    }
    
}

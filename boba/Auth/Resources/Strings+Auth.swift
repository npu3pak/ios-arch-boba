//
//  Strings+Auth.swift
//  boba
//
//  Created by Евгений Сафронов on 02.07.2018.
//  Copyright © 2018 Evgeniy Safronov. All rights reserved.
//

import Foundation

extension Strings {
    struct Auth {
        static func confirmationHint(phone: String) -> String {
            let formattedPhone = phone.applyingMask(Constants.Masks.phone)
            return "Мы отправили SMS с кодом активации на ваш номер +7 \(formattedPhone)"
        }

        static let emptyPhoneError = "Укажите номер телефона"
        static let incorrectPhoneError = "Номер телефона указан неправильно"
        static let emptyConfirmationCodeError = "Укажите код подтверждения"
        static let incorrectConfirmationCodeError = "Код подтверждения указан неправильно"
    }
}

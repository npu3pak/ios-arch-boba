//
//  Date+Extensions.swift
//  boba
//
//  Created by Евгений Сафронов on 03.07.2018.
//  Copyright © 2018 Evgeniy Safronov. All rights reserved.
//

import Foundation

enum DateFormat: String {
    case dmy = "dd.MM.yyyy"
    case hhmmss = "HH:mm:ss"
}

extension Date {
    func asString(_ format: DateFormat) -> String {
        return asString(format: format.rawValue)
    }

    func asString(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.timeZone = TimeZone(abbreviation: "MSK")
        return formatter.string(from: self)
    }

    static func fromString(_ value: String?, format: DateFormat) -> Date? {
        guard let value = value else {
            return nil
        }

        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.timeZone = TimeZone(abbreviation: "MSK")
        return formatter.date(from: value)
    }
}

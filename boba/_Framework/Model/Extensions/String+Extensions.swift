//
//  String+Extensions.swift
//  boba
//
//  Created by Евгений Сафронов on 03.07.2018.
//  Copyright © 2018 Evgeniy Safronov. All rights reserved.
//

import Foundation

// MARK: - Регулярные выражения

extension String {
    func checkRegexp(_ pattern: String) -> Bool {
        guard let range = self.range(of: pattern, options: .regularExpression) else {
            return false
        }

        return count == distance(from: range.lowerBound, to: range.upperBound)
    }
}

// MARK: - Подстроки

extension String {

    var length: Int {
        return self.count
    }

    func substring(_ startIndex: Int, length: Int) -> String {
        guard startIndex + length > 0 && length >= 0 else {
            return ""
        }

        if startIndex > self.length - 1 && startIndex + length > self.length {
            return ""
        }

        var start: String.Index!
        var end: String.Index!

        var startPosition = startIndex
        var endPosition = length

        if startPosition < 0 {
            endPosition = length + startIndex
            startPosition = 0
        }

        start = index(self.startIndex, offsetBy: startPosition)

        if startIndex + length > self.length {
            end = self.endIndex
        } else {
            end = index(self.startIndex, offsetBy: startPosition + endPosition)
        }

        return String(self[start..<end])
    }
}

// MARK: - Работа с масками

extension String {

    /**

     Наложение маски на строку, в строку добавляются символы из маски
     - parameter mask: маска
     - parameter forwardDecoration: добалять или нет символы маски после последнего символа строки
     - returns: Новая строка после применения маски

     Если маска не задана, то строка возвращается в неизменном виде.
     Сиволы маски:
     "9" - цифры
     "L" - латинские символы
     "Б" - кирилические символы
     "S" - любые символы
     Пример маски:  (999)999-99-99
     */
    func applyingMask(_ mask: String?, forwardDecoration: Bool = false) -> String {
        guard let mask = mask, mask != ""  else {
            return self
        }

        var formatted = ""
        for i in 0..<length {
            let previous = formatted
            let valueChar = substring(i, length: 1)
            formatted.append(mask.getNextMaskDecorCharacter(from: formatted.count))
            formatted.append(valueChar)
            if !formatted.isConformToMask(mask) {
                formatted = previous
            } else if forwardDecoration {
                formatted.append(mask.getNextMaskDecorCharacter(from: formatted.count))
            }
        }
        return formatted
    }

    /**
     Удаление символов маски из строки
     - parameter mask: маска
     - returns: Новая строка после применения маски

     Если маска не задана, то строка возвращается в неизменном виде.
     Если строка не соотвествует маске, то возвращается nil. Строгое соотвествие маске не требуется (см. isConformToMask(::))
     */
    func removingMask(_ mask: String?) -> String? {
        guard let mask = mask, mask.length > 0 else {
            return self
        }

        // если строка не удовлетворяет маске, то в результате возвращается nil
        guard isConformToMask(mask) else {
            return nil
        }

        var rawValue = ""

        for i in 0..<length {
            if !mask.isMaskDecorCharacter(at: i) {
                rawValue.append(substring(i, length: 1))
            }
        }

        return rawValue
    }

    /**
     Проверяет соотвествует строка маске или нет

     - parameters:
     - mask:  Проверяемая маска
     - strong: (по умолчанию = false)
     - returns: true - если строка удовдетворяет маске

     Если strong =  true, то строка должна строго удовлетворять маске по всем позициям, в том числе и по длине, если strong = false, то строка должна соответствовать маске с лева на право, строка может быть короче маски.
     */
    func isConformToMask(_ mask: String, strong isStrongRule: Bool = false) -> Bool {
        let maskCharDigit = "9"
        let maskCharLat = "L"
        let maskCharCyr = "Б"
        let maskCharAny = "S"

        let length: Int = isStrongRule ? max(self.length, mask.length) : self.length

        for pos in 0..<length {
            guard pos < mask.length else {
                return false
            }
            guard pos < self.length else {
                return false
            }

            let maskChar = mask.substring(pos, length: 1)
            let valueChar = substring(pos, length: 1)
            switch maskChar {
            case maskCharDigit: if !(valueChar.checkRegexp("[0-9]")) {return false}
            case maskCharLat: if !(valueChar.checkRegexp("[A-Za-z]")) {return false}
            case maskCharCyr: if !(valueChar.checkRegexp("[А-Яа-я]")) {return false}
            case maskCharAny: if !(valueChar.checkRegexp(".")) {return false}
            default: if maskChar != valueChar {return false}
            }
        }
        return true
    }

    func isMaskDecorCharacter(at position: Int) -> Bool {
        guard position < length else {
            return false
        }

        let maskCharDigit = "9"
        let maskCharLat = "L"
        let maskCharCyr = "Б"
        let maskCharAny = "S"

        let char = substring(position, length: 1)
        return ![maskCharDigit, maskCharLat, maskCharCyr, maskCharAny].contains(char)
    }

    func getNextMaskDecorCharacter(from position: Int) -> String {
        guard position < self.count else {
            return ""
        }

        var pos = position
        var decoration = ""
        while self.isMaskDecorCharacter(at: pos) {
            let decorChar = substring(pos, length: 1)
            decoration.append(decorChar)
            pos += 1
        }
        return decoration
    }
}

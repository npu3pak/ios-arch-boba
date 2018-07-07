//
//  FormattedTextField.swift
//  boba
//
//  Created by Евгений Сафронов on 04.07.2018.
//  Copyright © 2018 Evgeniy Safronov. All rights reserved.
//

import UIKit

class FormattedTextField: UITextField {
    var onValueChanged: ((String?) -> Void)? {
        didSet {
            setUp()
        }
    }
    var textFieldDelegate: UITextFieldDelegate? {
        didSet {
            setUp()
        }
    }
    var inputMask: String? = nil {
        didSet {
            setUp()
        }
    }
     var inputMaskForwardDecoration: Bool = true {
        didSet {
            setUp()
        }
    }
    var maxLength: Int? = nil {
        didSet {
            setUp()
        }
    }

    override var text: String? {
        didSet {
            setUp()
        }
    }

    private var delegateWrapper: UITextFieldDelegateWrapper?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setUp()
    }

    func setUp() {
        autocorrectionType = .no

        delegateWrapper = UITextFieldDelegateWrapper()
        delegateWrapper?.mask = inputMask
        delegateWrapper?.inputMaskForwardDecoration = inputMaskForwardDecoration
        delegateWrapper?.textFieldDelegate = textFieldDelegate
        delegateWrapper?.maxLength = maxLength
        delegateWrapper?.onValueChanged = {[weak self] in self?.onValueChanged?(self?.textWithoutMask)}

        delegate = delegateWrapper

        if text != nil && inputMask != nil {
            super.text = text!.applyingMask(inputMask!, forwardDecoration: inputMaskForwardDecoration)
        }
    }

    var textWithoutMask: String? {
        return delegateWrapper?.getRawValue(fromMaskedValue: self.text) ?? self.text
    }
}

private class UITextFieldDelegateWrapper: NSObject, UITextFieldDelegate {
    var mask: String?
    var inputMaskForwardDecoration: Bool = true
    weak var textFieldDelegate: UITextFieldDelegate?
    var maxLength: Int?

    var onValueChanged: (() -> Void)?

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return textFieldDelegate?.textFieldShouldClear?(textField) ?? true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textFieldDelegate?.textFieldDidEndEditing?(textField)
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        textFieldDelegate?.textFieldDidBeginEditing?(textField)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textFieldDelegate?.textFieldShouldReturn?(textField) ?? true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return textFieldDelegate?.textFieldShouldEndEditing?(textField) ?? true
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return textFieldDelegate?.textFieldShouldBeginEditing?(textField) ?? true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textFieldDelegateResult = textFieldDelegate?.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) ?? true

        // Если поведение было переопределено в делегате ничего не делаем
        guard textFieldDelegateResult else {
            return false
        }

        let hasMask = mask?.length ?? 0 > 0

        if hasMask {
            return textFieldWithMask(textField, shouldChangeCharactersIn: range, replacementString: string)
        } else {
            return textFieldWithoutMask(textField, shouldChangeCharactersIn: range, replacementString: string)
        }
    }

    func textFieldWithMask(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //Если маски нет - никакого форматирования не выполняем
        guard let mask = mask, mask.length > 0 else {
            return false
        }

        let oldValue = textField.text ?? ""

        //Если в поле ввода ничего нет - форматиируем и вставляем новое знаение
        if oldValue.length == 0 {
            textField.text = string.applyingMask(mask, forwardDecoration: inputMaskForwardDecoration)
            onValueChanged?()
            return false
        }

        //Проверяем, есть ли в изменяемом диапазоне значащие символы
        var rangeContainsNonMaskChars = false
        for i in range.location ..< (range.location + range.length) {
            if !mask.isMaskDecorCharacter(at: i) {
                rangeContainsNonMaskChars = true
                break
            }
        }

        //Если в изменяемом диапазоне нет значащих символов - расширяем его влево(для удаления) или вправо(для вставки)
        var replacementRange = range
        if !rangeContainsNonMaskChars {
            while mask.isMaskDecorCharacter(at: replacementRange.location) {
                if string == "" {
                    replacementRange.location -= 1
                } else {
                    replacementRange.location += 1
                }
                //Уперлись в маску в начале
                if replacementRange.location < 0 || replacementRange.location == 0 && mask.isMaskDecorCharacter(at: replacementRange.location) {
                    onValueChanged?()
                    return false
                }
            }
        }

        //Проецируем изменяемый диапазон на значение без маски. Определяем, какая часть значения без маски изменяется
        var rawValue = ""
        var rawValueRangeLocation = 0
        var rawValueRangeLength = 0

        for i in 0..<oldValue.length {
            if !mask.isMaskDecorCharacter(at: i) {
                rawValue.append(oldValue.substring(i, length: 1))
                if i < replacementRange.location {
                    rawValueRangeLocation += 1
                }

                if i >= replacementRange.location && i < replacementRange.location + replacementRange.length {
                    rawValueRangeLength += 1
                }
            }
        }

        //Изменяем значение без маски
        rawValue.replace(nsRange: NSRange(location: rawValueRangeLocation, length: rawValueRangeLength), replacementString: string)

        //Проверяем, не вышло ли значение без маски за максимальную длину
        var maxRawLength = 0
        for i in 0..<mask.length {
            if !mask.isMaskDecorCharacter(at: i) {
                maxRawLength += 1
            }
        }

        if rawValue.length > maxRawLength {
            onValueChanged?()
            return false
        }

        //Накладываем маску и показываем получившееся значение в поле ввода
        let masked = rawValue.applyingMask(mask, forwardDecoration: inputMaskForwardDecoration)
        textField.text = masked

        //Расчитываем и задаем новое положение указателя
        //Сначала вычисляем, где бы находился курсор, если бы не было маски
        //При удалении (string == "") курсор остается в начале изменяемого диапазона. При вставке - смещается вправо на длину вставляемого текста
        let rawValueLengthBeforeCursor = string == "" ? rawValueRangeLocation : rawValueRangeLocation + string.length
        //Отрезаем значение без маски до расчитанного положения курсора
        let rawValueBeforeCursor = rawValue.substring(0, length: rawValueLengthBeforeCursor)
        //Накладываем на получившееся значение маску и вычисляем длину получившегося выражения
        let maskedRawValueBeforeCursor = rawValueBeforeCursor.applyingMask(mask, forwardDecoration: inputMaskForwardDecoration)
        let newCursorPosition = maskedRawValueBeforeCursor.length
        //Перемещаем курсор
        textField.setCursorPosition(newCursorPosition)

        onValueChanged?()
        return false
    }

    func textFieldWithoutMask(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldValue = textField.text as NSString?
        let newValue = oldValue?.replacingCharacters(in: range, with: string) ?? ""

        if maxLength == nil || newValue.length <= maxLength! {
            textField.text = newValue
            onValueChanged?()
        }

        return false
    }

    func getRawValue(fromMaskedValue maskedValue: String?) -> String? {
        return maskedValue?.removingMask(mask)
    }
}

fileprivate extension UITextField {
    func setCursorPosition(_ position: Int) {
        let position = self.position(from: beginningOfDocument, offset: position)!
        selectedTextRange = textRange(from: position, to: position)
    }
}

fileprivate extension String {
    mutating func replace(nsRange: NSRange, replacementString: String) {
        let nsString = self as NSString
        self = nsString.replacingCharacters(in: nsRange, with: replacementString)
    }
}

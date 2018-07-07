//
//  LimittedScrollView.swift
//  boba
//
//  Created by Евгений Сафронов on 03.07.2018.
//  Copyright © 2018 Evgeniy Safronov. All rights reserved.
//

import UIKit

// Данный сабкласс используется для решения конфликта правого свайпа у бокового меню с другими компонентами, работающими с правым свайпом.
@IBDesignable public class LimittedScrollView: UIScrollView {
    // Ограничваем зону отклика на жест у данного scrollView.
    @IBInspectable public var leftInset: CGFloat = 0
    @IBInspectable public var rigthInset: CGFloat = 0
    @IBInspectable public var topInset: CGFloat = 0
    @IBInspectable public var bottomInset: CGFloat = 0
    
    // MARK: - UIPanGestureRecognizerDelegate
    override public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let locationInView = gestureRecognizer.location(in: self)
        // Так как размеры scrollView могут превышать размеры экрана, то координаты касания могут выходить за ширину/высоту экрана. Поэтому берем остаток от деления координат касания на ширину/высоту scrollView.
        let horizontalRemainder = locationInView.x.truncatingRemainder(dividingBy: bounds.width)
        let verticalRemainder = locationInView.x.truncatingRemainder(dividingBy: bounds.height)
        
        return horizontalRemainder > leftInset &&
            horizontalRemainder < bounds.width - rigthInset &&
            verticalRemainder > topInset &&
            verticalRemainder < bounds.height - bottomInset
    }
}

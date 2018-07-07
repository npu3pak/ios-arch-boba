//
//  TableView+InfiniteScrolling.swift
//  boba
//
//  Created by Евгений Сафронов on 03.07.2018.
//  Copyright © 2018 Evgeniy Safronov. All rights reserved.
//

import SVPullToRefresh

public extension UITableView {
    public func enableInfiniteScrolling(handler: @escaping () -> Void) {
        addInfiniteScrolling(actionHandler: handler)
        
        let bundle = Bundle(for: PullToRefreshLibClass.self)
        let view = bundle.loadNibNamed("TableViewInfiniteScrolling", owner: self, options: nil)![0] as! UIView
        infiniteScrollingView.setCustom(view, forState: UInt(SVInfiniteScrollingStateLoading))
        infiniteScrollingView.setCustom(view, forState: UInt(SVInfiniteScrollingStateTriggered))
    }
    
    public func stopInfiniteScrolling() {
        if showsInfiniteScrolling {
            infiniteScrollingView.stopAnimating()
        }
    }
    
    public var infiniteScrollingHasNextPage: Bool {
        set {
            showsInfiniteScrolling = newValue
        }
        get {
            return showsInfiniteScrolling
        }
    }
}

// Класс нужен, чтобы за него зацепиться при поиске бандла
private class PullToRefreshLibClass {
}

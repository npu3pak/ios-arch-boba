//
//  SegmentedViewController.swift
//  boba
//
//  Created by Евгений Сафронов on 03.07.2018.
//  Copyright © 2018 Evgeniy Safronov. All rights reserved.
//

import UIKit
import XLPagerTabStrip

@objc open class SegmentedViewController: UIViewController {
    public var segmentContainerController: SegmentedContainerViewController?
    
    public var hasTabs = false
    public var tabLeftRightMargin: CGFloat?
    
    public func showTabs(_ tabs: [(title: String?, image: String?, controller: UIViewController)], isConstantTabWidth: Bool = true) {
        removeTabsContainer()
        if tabs.count > 1 {
            addTabsContainer(tabs: tabs, isConstantTabWidth: isConstantTabWidth)
        } else if tabs.count == 1 {
            addSingleTab(tab: tabs[0])
        }
    }
    
    private func addTabsContainer(tabs: [(title: String?, image: String?, controller: UIViewController)], isConstantTabWidth: Bool) {
        hasTabs = true
        
        segmentContainerController = SegmentedContainerViewController(tabs: tabs, isConstantTabWidth: isConstantTabWidth)
        if let tabLeftRightMargin = tabLeftRightMargin {
            segmentContainerController!.tabLeftRightMargin = tabLeftRightMargin
        }
        
        addChildViewController(segmentContainerController!)
        //Если использовать frame, то будет странный отступ сверху
        segmentContainerController!.view.frame = view.bounds
        view.addSubview(segmentContainerController!.view)
        segmentContainerController!.didMove(toParentViewController: self)
    }
    
    private func addSingleTab(tab: ((title: String?, image: String?, controller: UIViewController))) {
        addChildViewController(tab.controller)
        navigationController?.title = title
        tab.controller.view.frame = view.bounds
        view.addSubview(tab.controller.view)
        tab.controller.didMove(toParentViewController: self)
    }
    
    private func removeTabsContainer() {
        hasTabs = false
        
        segmentContainerController?.willMove(toParentViewController: nil)
        segmentContainerController?.view.removeFromSuperview()
        segmentContainerController?.removeFromParentViewController()
        segmentContainerController = nil
    }

    public func hasTab(_ title: String) -> Bool {
        return (segmentContainerController?.tabs?.filter({ $0.title == title }).count ?? 0) > 0
    }

    public func switchTo(tabTitle: String, animated: Bool = false) {
        segmentContainerController?.switchTo(tabTitle: tabTitle, animated: animated)
    }
}

//
//  SegmentedContainerViewController.swift
//  boba
//
//  Created by Евгений Сафронов on 03.07.2018.
//  Copyright © 2018 Evgeniy Safronov. All rights reserved.
//

import Foundation
import XLPagerTabStrip
import UIKit

open class SegmentedContainerViewController: BaseButtonBarPagerTabStripViewController <SegmentedContainerTab> {

    private var isConstantTabWidth: Bool = true

    public var tabLeftRightMargin: CGFloat {
        get { return settings.style.buttonBarItemLeftRightMargin }
        set { settings.style.buttonBarItemLeftRightMargin = newValue }
    }

    public var tabs: [(title: String?, image: String?, controller: UIViewController)]?
    
    public init(tabs: [(title: String?, image: String?, controller: UIViewController)]?, isConstantTabWidth: Bool = true) {
        self.isConstantTabWidth = isConstantTabWidth

        let bundle = Bundle(for: SegmentedViewController.self)
        super.init(nibName: "SegmentedViewController", bundle: bundle)
        
        self.tabs = tabs
        
        let hasImage = tabs?.contains(where: {$0.image != nil}) ?? false
        
        let nibName = hasImage ? "SegmentedContainerImageTab" : "SegmentedContainerLabelTab"
        buttonBarItemSpec = ButtonBarItemSpec.nibFile(nibName: nibName, bundle: bundle, width: { [weak self] childItemInfo in
            if self?.isConstantTabWidth ?? true {
                return 55.0
            } else {
                return self?.calcTabWidth(withTitle: childItemInfo.title) ?? 55.0
            }
        })
    }

    private func calcTabWidth( withTitle title: String) -> CGFloat {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = self.settings.style.buttonBarItemFont
        label.text = title
        let labelSize = label.intrinsicContentSize
        return labelSize.width + self.settings.style.buttonBarItemLeftRightMargin * 2
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        print("SegmentedContainerViewController не поддерживает storyboard")
    }
    
    open override func viewDidLoad() {
        settings.style.buttonBarBackgroundColor = UIColor(red: 15/255.0, green: 144/255.0, blue: 131/255.0, alpha: 1.0)
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.selectedBarBackgroundColor = UIColor(red: 255/255.0, green: 209/255.0, blue: 0/255.0, alpha: 1.0) 
        
        settings.style.selectedBarHeight = 4.0
        settings.style.buttonBarMinimumLineSpacing = 2
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        
        changeCurrentIndexProgressive = {(oldCell: SegmentedContainerTab?, newCell: SegmentedContainerTab?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.iconImage?.tintColor = UIColor.white.withAlphaComponent(0.5)
            newCell?.iconImage?.tintColor = .white
            oldCell?.label?.textColor = UIColor.white.withAlphaComponent(0.5)
            newCell?.label?.textColor = .white
        }
        
        super.viewDidLoad()
        
        containerView.bounces = false
    }
    
    open override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        var tabControllers = [UIViewController]()
        
        guard let tabs = tabs, tabs.count > 0 else {
            let emptyController = UITableViewController(style: .grouped)
            emptyController.tableView.backgroundColor = UIColor.clear
            
            return [SegmentedContainerTabViewController(title: "", imageName: nil, controller: emptyController)]
        }
        
        for (title, imageName, controller) in tabs {
            let tabController = SegmentedContainerTabViewController(title: title, imageName: imageName, controller: controller)
            tabControllers.append(tabController)
        }
        
        return tabControllers
    }
    
    open override func configure(cell: SegmentedContainerTab, for indicatorInfo: IndicatorInfo) {
        cell.iconImage?.image = indicatorInfo.image?.withRenderingMode(.alwaysTemplate)
        cell.label?.text = indicatorInfo.title
    }

    open func switchTo(tabTitle: String, animated: Bool) {
        if let controller = viewControllers.first(where: { ($0 as? SegmentedContainerTabViewController)?.tabTitle == title }) {
            moveTo(viewController: controller, animated: animated)
        }
    }
}

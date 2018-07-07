//
//  SegmentedContainerTabViewController.swift
//  boba
//
//  Created by Евгений Сафронов on 03.07.2018.
//  Copyright © 2018 Evgeniy Safronov. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class SegmentedContainerTabViewController: UIViewController, IndicatorInfoProvider {
    
    var tabTitle: String?
    var tabImageName: String?
    var tabContentViewController: UIViewController?
    
    init(title: String?, imageName: String?, controller: UIViewController) {
        super.init(nibName: nil, bundle: nil)
        
        tabTitle = title
        tabImageName = imageName
        tabContentViewController = controller
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        if let title = tabTitle, let imageName = tabImageName {
            return IndicatorInfo(title: title, image: UIImage(named: imageName))
        } else if let imageName = tabImageName {
            return IndicatorInfo(title: "", image: UIImage(named: imageName))
        } else {
            return IndicatorInfo(title: tabTitle ?? "")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let contentController = tabContentViewController else {
            return
        }
        
        addChildViewController(contentController)
        contentController.view.frame = view.frame
        view.addSubview(contentController.view)
        contentController.didMove(toParentViewController: self)
    }
}

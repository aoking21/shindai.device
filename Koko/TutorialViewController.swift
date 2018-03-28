//
//  TutorialViewController.swift
//  Koko
//
//  Created by 青木佑弥 on 2017/12/27.
//  Copyright © 2017年 青木佑弥. All rights reserved.
//


import UIKit

class PageViewController: UIPageViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setViewControllers([getFirst()], direction: .Forward, animated: true, completion: nil)
        self.dataSource = self
    }
    
    func getFirst() -> FirstViewController {
        return storyboard!.instantiateViewControllerWithIdentifier("FirstTutorialViewController") as! FirstViewController
    }
    
    func getSecond() -> SecondViewController {
        return storyboard!.instantiateViewControllerWithIdentifier("SecondTutorialViewController") as! SecondViewController
    }
    
    func getThird() -> ThirdViewController {
        return storyboard!.instantiateViewControllerWithIdentifier("ThirdTutorialViewController") as! ThirdViewController
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension TutorialViewController : UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if viewController.isKindOfClass(ThirdViewController) {
            // 3 -> 2
            return getSecond()
        } else if viewController.isKindOfClass(SecondViewController) {
            // 2 -> 1
            return getFirst()
        } else {
            // 1 -> end of the road
            return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if viewController.isKindOfClass(FirstViewController) {
            // 1 -> 2
            return getSecond()
        } else if viewController.isKindOfClass(SecondViewController) {
            // 2 -> 3
            return getThird()
        } else {
            // 3 -> end of the road
            return nil
        }
    }
}

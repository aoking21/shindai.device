import UIKit

class PageViewController: UIPageViewController,UIPageViewControllerDataSource {
    
    let idList = ["First", "Second", "Third"]
    
    //最初からあるメソッド
    override func viewDidLoad() {
        
        //最初のビューコントローラーを取得する。
        let controller = storyboard!.instantiateViewController(withIdentifier: idList.first!)
        
        //ビューコントローラーを表示する。
        self.setViewControllers([controller], direction: .forward, animated: true, completion:nil)
        
        //データ提供元に自分を設定する。
        self.dataSource = self
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        //現在のビューコントローラーのインデックス番号を取得する。
        let index = idList.index(of: viewController.restorationIdentifier!)!
        if (index > 0) {
            //前ページのビューコントローラーを返す。
            return storyboard!.instantiateViewController(withIdentifier: idList[index-1])
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        //現在のビューコントローラーのインデックス番号を取得する。
        let index = idList.index(of: viewController.restorationIdentifier!)!
        if (index < idList.count-1) {
            //次ページのビューコントローラーを返す。
            return storyboard!.instantiateViewController(withIdentifier: idList[index+1])
        }
        return nil
    }
    
    //全ページ数を返すメソッド
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return idList.count
    }
    
    //ページコントロールの最初の位置を返すメソッド
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
}

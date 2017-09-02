//
//  IntroVC.swift
//  ios
//
//  Created by Brandon Price on 9/1/17.
//  Copyright © 2017 Brandon Price. All rights reserved.
//

import UIKit

class IntroVC: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    var pages = [UIViewController]()
    let pageControl = UIPageControl()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor(red: 0.0 / 255.0, green: 122.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
        
        self.dataSource = self
        self.delegate = self

        let page1 = UIViewController()
        addText(vc: page1, text: "Welcome to Chatter")
        let page2 = UIViewController()
        addText(vc: page2, text: "Chatter secures your messages by first sharing an encryption key over bluetooth.")
        let page3 = UIViewController()
        addText(vc: page3, text: "All your messages are sent over the internet and secured with this key.")
        let page4 = UIViewController()
        addText(vc: page4, text: "Only you and whoever you are messaging have this key.")
        let page5 = UIViewController()
        addText(vc: page5, text: "Now you can truly feel secure messaging over the internet.")
        let page6 = UIViewController()
        addText(vc: page5, text: "")
        
        // add the individual viewControllers to the pageViewController
        self.pages = [page1, page2, page3, page4, page5, page6]
        setViewControllers([pages[0]], direction: .forward, animated: true, completion: nil)
        
        // pageControl
        self.pageControl.frame = CGRect()
        self.pageControl.currentPageIndicatorTintColor = UIColor.clear
        self.pageControl.pageIndicatorTintColor = UIColor.clear
        self.pageControl.numberOfPages = self.pages.count
        self.pageControl.currentPage = 0
        self.view.addSubview(self.pageControl)
        
        self.pageControl.translatesAutoresizingMaskIntoConstraints = false
        self.pageControl.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -5).isActive = true
        self.pageControl.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -20).isActive = true
        self.pageControl.heightAnchor.constraint(equalToConstant: 20).isActive = true
        self.pageControl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // UIPageViewContoller Delegate
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if let viewControllerIndex = self.pages.index(of: viewController) {
            if viewControllerIndex == 0 {
                // wrap to last page in array
                return nil
            } else {
                // go to previous page in array
                return self.pages[viewControllerIndex - 1]
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if let viewControllerIndex = self.pages.index(of: viewController) {
            if viewControllerIndex < self.pages.count - 1 {
                // go to next page in array
                return self.pages[viewControllerIndex + 1]
            } else {
                // wrap to first page in array
                return nil
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        // set the pageControl.currentPage to the index of the current viewController in pages
        if let viewControllers = pageViewController.viewControllers {
            if let viewControllerIndex = self.pages.index(of: viewControllers[0]) {
                self.pageControl.currentPage = viewControllerIndex
                
                if viewControllerIndex == pages.count - 1 {
                    exit()
                }
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func addText(vc: UIViewController, text: String) {
        let LEFT_MARGIN : CGFloat = 20.0
        let TOP_MARGIN : CGFloat = 150.0
        
        let label = UITextView(frame: CGRect(x: LEFT_MARGIN, y: TOP_MARGIN, width: vc.view.frame.width - 2 * LEFT_MARGIN, height: vc.view.frame.height - TOP_MARGIN))
        label.text = text
        label.textAlignment = .center
        
        label.font = UIFont.systemFont(ofSize: 28.0)
        label.textColor = .white
        label.backgroundColor = .clear
        vc.view.addSubview(label)
    }

    
    func exit() {
        let mainView = SignInVC()
        
        present(mainView, animated: true, completion: {
            Cache.setFirstTime(isFirstTime: false)
        })
    }
}

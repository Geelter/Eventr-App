//
//  UIViewControllerExtension.swift
//  Eventr
//
//  Created by Mateusz Jabłoniec on 04/10/2021.
//

import UIKit

private var indicatorBackgroundView: UIView?

extension UIViewController {
    func embed(_ viewController: UIViewController, inView view: UIView) {
        viewController.willMove(toParent: self)
        viewController.view.frame = view.bounds
        view.addSubview(viewController.view)
        self.addChild(viewController)
        viewController.didMove(toParent: self)
    }
    
    func remove(child viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }
    
    func showActivityIndicator() {
        indicatorBackgroundView = UIView(frame: self.view.bounds)
        indicatorBackgroundView!.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let indicatorView = UIActivityIndicatorView(style: .large)
        indicatorView.center = indicatorBackgroundView!.center
        indicatorView.startAnimating()
        indicatorBackgroundView!.addSubview(indicatorView)
        self.view.addSubview(indicatorBackgroundView!)
    }
    
    func hideActivityIndicator() {
        indicatorBackgroundView?.removeFromSuperview()
    }
}

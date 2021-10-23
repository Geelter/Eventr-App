//
//  UIViewControllerExtension.swift
//  Eventr
//
//  Created by Mateusz Jabłoniec on 04/10/2021.
//

import UIKit

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
}

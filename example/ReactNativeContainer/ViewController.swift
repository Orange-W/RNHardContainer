//
//  ViewController.swift
//  ReactNativeContainer
//
//  Created by Orange on 2018/8/19.
//  Copyright © 2018年 Orange. All rights reserved.
//

import UIKit
import React

@objc(ViewController)
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController {
    @objc(popViewController:)
    func popViewController(animated: Bool) {
        if Thread.isMainThread {
            if let rootVC = UIApplication.shared.delegate?.window??.rootViewController as? UINavigationController {
                rootVC.popViewController(animated: animated)
            }
        } else {
            DispatchQueue.main.async {
                if let rootVC = UIApplication.shared.delegate?.window??.rootViewController as? UINavigationController {
                    rootVC.popViewController(animated: animated)
                }
            }
        }
    }

    @objc(dissMissViewController:)
    func dissMissViewController(animated: Bool) {
        if Thread.isMainThread {
            if let rootVC = UIApplication.shared.delegate?.window??.rootViewController as? UINavigationController {
                rootVC.dismiss(animated: animated)
            }
        } else {
            DispatchQueue.main.async {
                if let rootVC = UIApplication.shared.delegate?.window??.rootViewController as? UINavigationController {
                    rootVC.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}

//
//  File.swift
//  iScales
//
//  Created by Orange on 2017/9/27.
//  Copyright © 2017年 Scott Law. All rights reserved.
//

import Foundation

extension DispatchQueue {
    class func runInMainQueue(execute block: () -> Swift.Void) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.sync {
                block()
            }
        }
    }

    @discardableResult class func runInMainQueue<T>(execute block: (() -> T)) -> T {
        if Thread.isMainThread {
            return block()
        } else {
            return DispatchQueue.main.sync {
                return block()
            }
        }
    }

}

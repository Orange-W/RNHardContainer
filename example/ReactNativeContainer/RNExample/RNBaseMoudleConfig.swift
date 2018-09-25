//
//  BaseRNViewController.swift
//  ReactNativeContainer
//
//  Created by Orange on 2018/9/17.
//  Copyright © 2018年 Orange. All rights reserved.
//

import UIKit
import React

@objc(BaseRNViewController)
class RNBaseMoudleConfig: NSObject, RCTBridgeDelegate {
    func sourceURL(for bridge: RCTBridge!) -> URL! {
        #if DEBUG && targetEnvironment(simulator)
        return URL(string: debugIp)
        #else
        return URL(string: debugIp)
//        return  R.file.mainJsbundle.url()!
        #endif
    }

    @objc(RNTitle)
    var RNTitle: String? { return "默认 title"}

    @objc(RNParams)
    var RNParams: [String: Any] { return ["appVersion": Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) ?? "1.0.0"]}

    @objc(RNMoudleName)
    var RNMoudleName: String {
        fatalError("子类必须重写这个方法。")
    }

    @objc(RNDebugIP)
    var debugIp: String { return "http://127.0.0.1:8081/index.bundle?platform=ios"}
}



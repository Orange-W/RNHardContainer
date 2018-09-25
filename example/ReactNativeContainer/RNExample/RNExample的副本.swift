//
//  RNExample.swift
//  ReactNativeContainer
//
//  Created by Orange on 2018/9/17.
//  Copyright © 2018年 Orange. All rights reserved.
//

import Foundation

@objc(RNExample2)
class RNExample2: RNBaseMoudleConfig {
    override var RNTitle: String? { return "RNExample2"}

    override var RNMoudleName: String { return "RNHighScores"}

    override var RNParams: [String : Any] {
        return [
            "scores" : [
                ["name" : "Alex",
                 "value": "42"],
                ["name" : "Joel",
                 "value": "10"]
            ]
        ]
    }
}

//
//  Bluetooth+RNObject.swift
//  ReactNativeContainer
//
//  Created by Orange-W on 2018/10/3.
//  Copyright © 2018年 Orange. All rights reserved.
//

import Foundation
import CoreBluetooth


extension CBPeripheral {
    var objectDict: [String: Any] {
        return [
            "UUID": self.identifier.uuidString,
            "name": self.name ?? "",
            "services": self.services?.map({$0.objectDict}) ?? []
        ]
    }
}

extension CBService {
    var objectDict: [String: Any] {
        return [
            "UUID": self.uuid.uuidString,
            "peripheral": self.peripheral.identifier.uuidString,
            "characteristics": self.characteristics?.map({$0.objectDict}) ?? [],
        ]
    }
}

extension CBCharacteristic {

    var objectDict: [String: Any] {
        let properties = [
            "broadcast": self.properties.contains(.broadcast).description,
            "read": self.properties.contains(.read).description,
            "writeWithoutResponse": self.properties.contains(.writeWithoutResponse).description,
            "write": self.properties.contains(.write).description,
            "notify": self.properties.contains(.notify).description,
            "indicate": self.properties.contains(.indicate).description,
            "authenticatedSignedWrites": self.properties.contains(.authenticatedSignedWrites).description,
            "extendedProperties": self.properties.contains(.extendedProperties).description,
            "notifyEncryptionRequired": self.properties.contains(.notifyEncryptionRequired).description,
            "indicateEncryptionRequired": self.properties.contains(.indicateEncryptionRequired).description
        ]

        return [
            "UUID": self.uuid.uuidString,
            "service": self.service.uuid.uuidString,
            "properties": properties,
            "value": "self.value",
        ]
    }
}

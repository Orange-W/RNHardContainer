//
//  BLESubscriberProtocol.swift
//  intelligent
//
//  Created by Orange on 2018/8/21.
//  Copyright © 2018年 Scott Law. All rights reserved.
//

import Foundation
import CoreBluetooth

struct BLEMainPeripheralInfoStruct {
    var peripheral: CBPeripheral?
    var state: CBPeripheralState {
        return peripheral?.state ?? .disconnected
    }

    var identify: UUID? {
        return peripheral?.identifier
    }
    var bluetoothAddress: String
    var typeString: String?

    init(bluetoothAddress: String, typeString: String? =  nil) {
        self.bluetoothAddress = bluetoothAddress
        self.typeString = typeString
    }
}

protocol BLESubscriberProtocol: class, NSObjectProtocol {
    var subscriberType: String { get }
    func newState(state: BLEInfoState)
    func scanAndConnectToPeripheral(bluetoothAddress: String)
    func findPeripheral(bluetoothAddress: String) -> CBPeripheral?
}

extension BLESubscriberProtocol {

    func newState(state: BLEInfoState) { print("hahahahahahahaha")}

    func scanAndConnectToPeripheral(bluetoothAddress: String) {
        return KREBLEScalesSubscriber.shared.scanAndConnectToPeripheral(type: subscriberType, bluetoothAddress: bluetoothAddress)
    }

    func findPeripheral(bluetoothAddress: String) -> CBPeripheral? {
        return KREBLEScalesSubscriber.shared.findPeripheral(type: subscriberType, bluetoothAddress: bluetoothAddress)
    }

}

protocol BLEScalesSubscriberProtocol: BLESubscriberProtocol {

}

extension BLEScalesSubscriberProtocol {
    var subscriberType: EquipmentType {
        return .scales
    }
}

// 非VC监听者
class BLESubscriber: NSObject, BLESubscriberProtocol {
    typealias StoreSubscriberStateType = BLEInfoState
    var subscriberType: String { return EquipmentType.unset.rawValue }
    func newState(state: BLEInfoState) {}
}

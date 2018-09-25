//
//  BLEHandle.swift
//  iScales
//
//  Created by Orange on 2017/9/29.
//  Copyright © 2017年 Scott Law. All rights reserved.
//

import Foundation
import CoreBluetooth

class BLEPeripheraHandler {
    weak var masterPeriphera: CBPeripheral?

    // MARK: 修改名字
    var peripheralDidUpdateNameHandle: ((CBPeripheral) -> Void)?
    // MARK: 服务
    var didDiscoverServicesHandle: ((_ peripheral: CBPeripheral, _ error: Error?) -> Void)?
    var didDiscoverIncludedServicesHandle: ((_ peripheral: CBPeripheral, _ service: CBService, _ error: Error?) -> Void)?
    var didModifyServicesHandle: ((_ peripheral: CBPeripheral, _ invalidatedServices: [CBService]) -> Void)?

    // MARK: 特征
    var didDiscoverCharacteristicsHandle: ((_ peripheral: CBPeripheral, _ service: CBService, _ error: Error?) -> Void)?
    var didWriteCharacteristicsHandle: ((_ peripheral: CBPeripheral, _ characteristic: CBCharacteristic, _ error: Error?) -> Void)?
    var didUpdateCharacteristicsHandle: ((_ peripheral: CBPeripheral, _ characteristic: CBCharacteristic, _ error: Error?) -> Void)?

    // MARK: 通知
    var didUpdateNotificationStateHandle: ((_ peripheral: CBPeripheral, _ characteristic: CBCharacteristic, _ error: Error?) -> Void)?

    // MARK: 配置信息
    var didDiscoverDescriptorsHandle: ((_ peripheral: CBPeripheral, _ characteristic: CBCharacteristic, _ error: Error?) -> Void)?
    var didWriteDescriptorHandle: ((_ peripheral: CBPeripheral, _ descriptor: CBDescriptor, _ error: Error?) -> Void)?
    var didUpdateDescriptorHandle: ((_ peripheral: CBPeripheral, _ descriptor: CBDescriptor, _ error: Error?) -> Void)?

    // MARK: RSSI
    var didReadRSSI: ((_ peripheral: CBPeripheral, _ RSSI: NSNumber, _ error: Error?) -> Void)?

    func updete(newHandler: BLEPeripheraHandler) {
        self.peripheralDidUpdateNameHandle = newHandler.peripheralDidUpdateNameHandle ?? self.peripheralDidUpdateNameHandle

        self.didDiscoverServicesHandle = newHandler.didDiscoverServicesHandle ?? self.didDiscoverServicesHandle
        self.didDiscoverIncludedServicesHandle = newHandler.didDiscoverIncludedServicesHandle ?? self.didDiscoverIncludedServicesHandle
        self.didModifyServicesHandle = newHandler.didModifyServicesHandle ?? self.didModifyServicesHandle

        self.didDiscoverCharacteristicsHandle = newHandler.didDiscoverCharacteristicsHandle ?? self.didDiscoverCharacteristicsHandle
        self.didWriteCharacteristicsHandle = newHandler.didWriteCharacteristicsHandle ?? self.didWriteCharacteristicsHandle
        self.didUpdateCharacteristicsHandle = newHandler.didUpdateCharacteristicsHandle ?? self.didUpdateCharacteristicsHandle

        self.didUpdateNotificationStateHandle = newHandler.didUpdateNotificationStateHandle ?? self.didUpdateNotificationStateHandle
        self.didDiscoverDescriptorsHandle = newHandler.didDiscoverDescriptorsHandle ?? self.didDiscoverDescriptorsHandle
        self.didWriteDescriptorHandle = newHandler.didWriteDescriptorHandle ?? self.didWriteDescriptorHandle

        self.didUpdateDescriptorHandle = newHandler.didUpdateDescriptorHandle ?? self.didUpdateDescriptorHandle

        self.didReadRSSI = newHandler.didReadRSSI ?? self.didReadRSSI
    }

    init() {

    }
}

extension BLEPeripheraHandler {
    func setPeripheralDidUpdateNameHandle(_ handle:( (CBPeripheral) -> Void)?) {peripheralDidUpdateNameHandle = handle}

    // 服务
    func setDidDiscoverServicesHandle(_ handle: ((_ peripheral: CBPeripheral, _ error: Error?) -> Void)?) {didDiscoverServicesHandle = handle}
    func setDidDiscoverIncludedServicesHandle(_ handle: ((_ peripheral: CBPeripheral, _ service: CBService, _ error: Error?) -> Void)?) {didDiscoverIncludedServicesHandle = handle}
    func setDidModifyServicesHandle(_ handle: ((_ peripheral: CBPeripheral, _ invalidatedServices: [CBService]) -> Void)?) {didModifyServicesHandle = handle}

    // 特征值
    func setDidDiscoverCharacteristicsHandle(_ handle: ((_ peripheral: CBPeripheral, _ service: CBService, _ error: Error?) -> Void)?) {didDiscoverCharacteristicsHandle = handle}
    func setDidWriteCharacteristicsHandle(_ handle: ((_ peripheral: CBPeripheral, _ characteristic: CBCharacteristic, _ error: Error?) -> Void)?) {didWriteCharacteristicsHandle = handle}
    func setDidUpdateCharacteristicsHandle(_ handle: ((_ peripheral: CBPeripheral, _ characteristic: CBCharacteristic, _ error: Error?) -> Void)?) {didUpdateCharacteristicsHandle = handle}

    //通知
    func setDidUpdateNotificationStateHandle(_ handle: ((_ peripheral: CBPeripheral, _ characteristic: CBCharacteristic, _ error: Error?) -> Void)?) {didUpdateNotificationStateHandle = handle}

    // 配置信息
    func setDidDiscoverDescriptorsHandle(_ handle: ((_ peripheral: CBPeripheral, _ characteristic: CBCharacteristic, _ error: Error?) -> Void)?) {didDiscoverDescriptorsHandle = handle}
    func setDidWriteDescriptorHandle(_ handle: ((_ peripheral: CBPeripheral, _ descriptor: CBDescriptor, _ error: Error?) -> Void)?) {didWriteDescriptorHandle = handle}
    func setDidUpdateDescriptorHandle(_ handle: ((_ peripheral: CBPeripheral, _ descriptor: CBDescriptor, _ error: Error?) -> Void)?) {didUpdateDescriptorHandle = handle}

    // RSSI
    func setDidReadRSSI(_ handle: ((_ peripheral: CBPeripheral, _ RSSI: NSNumber, _ error: Error?) -> Void)?) {didReadRSSI = handle}
}

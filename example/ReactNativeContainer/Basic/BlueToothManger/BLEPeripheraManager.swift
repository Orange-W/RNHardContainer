//
//  BLEPeripheraMangeer.swift
//  iScales
//
//  Created by Orange on 2017/9/11.
//  Copyright © 2017年 Scott Law. All rights reserved.
//

import Foundation
import CoreBluetooth

class BLEPeripheraManager: NSObject, CBPeripheralDelegate {
    var connectedList: [CBPeripheral] = [CBPeripheral]()
    var handlerList = [BLEPeripheraHandler]()

    func addConnected(_ periphera: CBPeripheral) {
        periphera.delegate = self
        connectedList.append(periphera)
    }

    func removeConnected(_ periphera: CBPeripheral) {
        if let index = connectedList.index(of: periphera) {
            connectedList.remove(at: index)
        }
    }

    
    func updateHandler(_ periphera: CBPeripheral?, handler: BLEPeripheraHandler ) {
        guard periphera != nil else {
            return
        }
        handler.masterPeriphera = periphera
        let searInfo = findHandler(periphera)
        if searInfo.0 == nil {
            handlerList.append(handler)
        } else {
            let baseHandler = handlerList[searInfo.1]
            baseHandler.updete(newHandler: handler)
        }
        return
    }

    // 返回元组 (对象, index下标)
    func findHandler(_ periphera: CBPeripheral?) -> (BLEPeripheraHandler?, Int) {
        guard periphera != nil else {
            return (nil, -1)
        }
        for index in 0 ..< handlerList.count {
            let oldHandler = handlerList[index]
            if periphera?.identifier == oldHandler.masterPeriphera?.identifier {
                return (oldHandler, index)
            }
        }
        return (nil, -1)
    }

    // MARK: - delegate -

    func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        handler(from: peripheral)?.peripheralDidUpdateNameHandle?(peripheral)
    }

    private func handler(from periphera: CBPeripheral) -> BLEPeripheraHandler? {
        return handlerList.filter { (handler) -> Bool in
            return handler.masterPeriphera == periphera
        }.first
    }

    // MARK: - 服务
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        handler(from: peripheral)?.didDiscoverServicesHandle?(peripheral, error)
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?) {
        handler(from: peripheral)?.didDiscoverIncludedServicesHandle?(peripheral, service, error)
    }

    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        handler(from: peripheral)?.didModifyServicesHandle?(peripheral, invalidatedServices)
    }

    // MARK: - 特征
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {// 发现
        handler(from: peripheral)?.didDiscoverCharacteristicsHandle?(peripheral, service, error)
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {// 写入
        handler(from: peripheral)?.didWriteCharacteristicsHandle?(peripheral, characteristic, error)

    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {// 跟新
        handler(from: peripheral)?.didUpdateCharacteristicsHandle?(peripheral, characteristic, error)
    }

    // MARK: - 通知
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        handler(from: peripheral)?.didUpdateNotificationStateHandle?(peripheral, characteristic, error)
    }

    // MARK: - 配置信息
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {// 配置
        handler(from: peripheral)?.didDiscoverDescriptorsHandle?(peripheral, characteristic, error)
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        handler(from: peripheral)?.didWriteDescriptorHandle?(peripheral, descriptor, error)
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        handler(from: peripheral)?.didUpdateDescriptorHandle?(peripheral, descriptor, error)
    }

    // RSSI
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        handler(from: peripheral)?.didReadRSSI?(peripheral, RSSI, error)
    }
}

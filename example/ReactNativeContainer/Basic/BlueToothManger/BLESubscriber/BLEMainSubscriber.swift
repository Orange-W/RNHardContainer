//
//  BLEMainManger.swift
//  iScales
//
//  Created by Orange on 2017/11/15.
//  Copyright © 2017年 Scott Law. All rights reserved.
//

import Foundation
import CoreBluetooth

class BLEMainSubscriber: NSObject, StoreSubscriber {
    typealias StoreSubscriberStateType = BLEInfoState

    struct WebVCBLEConnectActionKey: Hashable {
        var state: BLEConnectActionType
        var webVC: WeakRef<WebViewController>
    }

    static let shared = BLEMainSubscriber.init()

    // MARK: H5 bridge, 弱引用
    private var webVCCallBack: [WebVCBLEConnectActionKey: (String, [String: Any])] = [:]

    var subSubscribers: [BLESubscriber] = []
    var peripheConnectOption: [String: Any] {
        return [
            // 连接成功通知
            CBConnectPeripheralOptionNotifyOnConnectionKey: true,
            // 连接断开通知
            CBConnectPeripheralOptionNotifyOnDisconnectionKey: true,
            // 打开通知
            CBConnectPeripheralOptionNotifyOnNotificationKey: true,
        ]
    }

    func addSubSubscriber(subscriber: BLESubscriber) {
        if subSubscribers.contains(subscriber) {
            return
        }
        subSubscribers.append(subscriber)
    }

    func removeSubSubscriber(subscriber: BLESubscriber) {
        subSubscribers.remove(subscriber)
    }

    private override init() {
        super.init()
        BLEStore.subscribe(self)
        // app启动或者app从后台进入前台都会调用这个方法
        NotificationCenter.default.addObserver(self, selector: #selector(applicationBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }

    @objc func applicationBecomeActive() {
//        BLEManager.shared.scanPeripherals(duration: 180, serviceUUIDs: nil)
    }

    deinit {
        BLEStore.unsubscribe(self)
    }

    // 启动准备
    func startUp() {

    }

    private func broadcastSubSubscribers(subscriberType: String? = nil, state: StoreSubscriberStateType) {
        for subscriber in subSubscribers {
            if let type = subscriberType,
                subscriber.subscriberType == type {
                subscriber.newState(state: state)
            } else if subscriberType == nil {
                subscriber.newState(state: state)
            }
        }
    }

    func findDiscoveredPeripheral(uuid: String) -> CBPeripheral? {
        let peripheral = BLEManager.shared.peripheralList.first { (per) -> Bool in
            return per.identifier.uuidString == uuid
        }
        return peripheral
    }

    func findConnectedPeripheral(uuid: String) -> CBPeripheral? {
        let peripheral = BLEManager.shared.peripheraManager.connectedList.first { (per) -> Bool in
            return per.identifier.uuidString == uuid
        }
        return peripheral
    }

    // MARK: 状况变化
    func newState(state: StoreSubscriberStateType) {
        DispatchQueue.runInMainQueue {
            let action = state.centralActionType
            let peripheralOptional = state.actionPeripheral

            switch action {
            case .UpdateBluetoothState:
                if BLEManager.shared.state == .poweredOn {
                    // 搜索
//                    BLEManager.shared.scanPeripherals(serviceUUIDs: nil, options: nil)
                }
                do { // 广播
                    // H5 广播
                    callBackWebH5(state: action, result: ["isOpen": BLEManager.shared.state == .poweredOn])
                    // Native 广播
                    broadcastSubSubscribers(state: state)
                }
            case .DiscoverPeripheral:
                if let peripheral = state.actionPeripheral,
                    let RSSI = state.info?["RSSI"] as? Int {
                    let advertisementData = state.info?["advertisementData"] as? [String: Any]
                    // 广播数据
                    let isConnectable = advertisementData?["kCBAdvDataIsConnectable"] as? Int
                    let localName = advertisementData?["kCBAdvDataLocalName"] as? String
                    let manufacturerData = advertisementData?["kCBAdvDataManufacturerData"]  as? Data
                    let txPowerLevel = advertisementData?["kCBAdvDataTxPowerLevel"] as? Int
                    // H5 广播
                    callBackWebH5(
                        state: action,
                        result: ["device" : [
                            "name": peripheral.name ?? "",
                            "bluetoothId": peripheral.identifier.uuidString,
                            "RSSI": RSSI,
                            "serviceUUIDs": (peripheral.services ?? []).map({$0.uuid.uuidString}),
                            "isConnectable": isConnectable ?? "",
                            "localName": localName ?? "",
                            "manufacturerData": manufacturerData?.bytes ?? [],
                            "txPowerLevel": txPowerLevel ?? ""
                    ]])

                    // 广播所有监听者
                    broadcastSubSubscribers(subscriberType: nil, state: state)
                }
            case .Connected:
                // 设置监听
                if let peripheral = state.actionPeripheral {
                    // H5 广播
                    callBackWebH5(
                        state: action,
                        result: [
                            "name": peripheral.name ?? "",
                            "bluetoothId": peripheral.identifier.uuidString,
                            "connected": peripheral.state == .connected
                        ])

                    // Native 广播对应监听者
                    broadcastSubSubscribers(state: state)
                }

            case .FailToConnect:
                // 连接失败
                if let peripheral = peripheralOptional {
                    // H5 广播
                    callBackWebH5(
                        state: action,
                        result: [
                            "name": peripheral.name ?? "",
                            "bluetoothId": peripheral.identifier.uuidString,
                            "connected": peripheral.state == .connected
                        ])
                    broadcastSubSubscribers(state: state)
                }

            case .Disconnected:
                // 连接中断
                if let peripheral = peripheralOptional {
                    // H5 广播
                    callBackWebH5(
                        state: action,
                        result: [
                            "name": peripheral.name ?? "",
                            "bluetoothId": peripheral.identifier.uuidString,
                            "connected": peripheral.state == .connected
                        ])

                    // Native 广播对应监听者
                    broadcastSubSubscribers(state: state)
                }

            case .WillRestore:
                //恢复连接
                if let dict = state.info, // 恢复信息
                    let peripherals: [CBPeripheral] = (dict[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral]) {
                    let list = BLEManager.shared.retrievePeripherals(withIdentifiers: peripherals.map({ (per) -> UUID in
                        return per.identifier
                    }))
                    for peripheral in list {
                        // 恢复重连
                        BLEManager.shared.connect(peripheral: peripheral, options: nil)
                    }
                }

                broadcastSubSubscribers(state: state)
            case .Unkonw:
                break
            }
        }
    }
}

// MARK: - extension H5 Bridge
extension BLEMainSubscriber {
    // 添加H5 回调
    func addWebCallBack(state: BLEConnectActionType, webVC: WebViewController, funcName: String, params: [String: Any]) {
        let key = WebVCBLEConnectActionKey.init(state: state, webVC: WeakRef(webVC))
        webVCCallBack[key] = (funcName, params)
    }

    // 删除H5 回调
    func removeWebCallBack(state: BLEConnectActionType, webVC: WebViewController) {
        let key = WebVCBLEConnectActionKey.init(state: state, webVC: WeakRef(webVC))
        webVCCallBack.removeValue(forKey: key)
    }

    func callBackWebH5(state: BLEConnectActionType, result: [String: Any]) {
        webVCCallBack.forEach({ (key, value) in
            if state == key.state {
                if let vc = key.webVC.value,
                    vc.isViewLoaded && (vc.view.window != nil) {
                    vc.webViewCallback(funcName: value.0, params: BluetoothWebScheme.makeCallBackDict(code: .none, result: result))
                } else {
                    webVCCallBack.removeValue(forKey: key)
                }
            }
        })
    }
}

//  BluetoothManger.swift
//  iScales
//
//  Created by Orange on 2017/9/8.
//  Copyright © 2017年 Scott Law. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth
import React

// 蓝牙指令需要秒数
enum BLETimeOutLimit: Double {
    case `default` = 0.2 // 5条以内,100字节
    case many = 0.5 // 15条以下, 300字节
    case much = 0.8 // 20条以下, 400字节
    case large =  1.0  // 30条, 600字节
    case huge = 2.0    // 近1KB, 不应该用蓝牙传这么大的数据
}

enum BLECentralState: Int {
    case unknown
    case resetting
    case unsupported // 不支持BLE
    case unauthorized
    case poweredOff
    case poweredOn

    var desc: String {
        var desc = ""
        switch self {
        case .unknown:
            desc = "unknown"
        case .resetting:
            desc = "resetting"
        case .unsupported: // 不支持BLE
            desc = "unsupported"
        case .unauthorized:
            desc = "unauthorized"
        case .poweredOff:
            desc = "poweredOff"
        case .poweredOn:
            desc = "poweredOn"
        }
        return desc
    }
}

let BLEQueueName = "BLEMangerQueue"
let BLEEquipmentRestoreIdentifier = "com.netease.3c.iScales.BLEEquipmentRestoreIdentifier"
var BLEPeriphalDefaultOption: [String: Any] {
    return [
        CBConnectPeripheralOptionNotifyOnConnectionKey: true, // 连接成功通知
        CBConnectPeripheralOptionNotifyOnDisconnectionKey: true, // 连接断开通知
        CBConnectPeripheralOptionNotifyOnNotificationKey: true // 打开通知
    ]
}

@objc(BLEManager)
class BLEManager: NSObject, CBCentralManagerDelegate {

    var state: BLECentralState {
        return DispatchQueue.runInMainQueue {
            return BLECentralState.init(rawValue: self.centralManager.state.rawValue) ?? .unknown
        }
    }

    let BLEQueue: DispatchQueue = DispatchQueue.init(label: BLEQueueName, qos: .userInitiated, attributes: .concurrent) // 队列从不自动释放(类似timer),全局单例
    // MARK: 中心控制器和设备控制器
    private var centralManager: CBCentralManager!
    static var peripheraManager: BLEPeripheraManager = BLEManager.shared.peripheraManager
    var peripheraManager = BLEPeripheraManager()

    // MARK: 中心控制器列表
    var peripheralList: [CBPeripheral] = [CBPeripheral]()
    var connectedPeripherals: [CBPeripheral] { return self.peripheraManager.connectedList }

    private var scanTimer: Timer?

    static let shared: BLEManager = BLEManager()
    private override init() {
        super.init()
        centralManager = CBCentralManager.init(
        delegate: self,
        queue: self.BLEQueue,
        options: [CBCentralManagerOptionShowPowerAlertKey: true, // 需要打开蓝牙的 alert 提醒
        CBCentralManagerOptionRestoreIdentifierKey: BLEEquipmentRestoreIdentifier
        ])
    }

    // MARK: -
    @objc(scanPeripherals: serviceUUIDs: options:)
    func scanPeripherals(duration: Double = 999, serviceUUIDs: [String]? = nil, options: [String : Any]? = nil) {
        guard centralManager.state == .poweredOn else {
            print("搜索设备前先打开蓝牙")
            return
        }
        // 适配低版本
        if #available(iOS 9.0, *) {
            if centralManager.isScanning {
                centralManager.stopScan()
            }
        } else {
            // 旧版本的情况
            centralManager.stopScan()
        }

        let UUIDs = serviceUUIDs?.map({ (str) -> CBUUID in
            return CBUUID.init(string: str)
        })
        peripheralList.removeAll()
        centralManager.scanForPeripherals(withServices: UUIDs, options: options)
        scanTimer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(scanfTimeOut), userInfo: nil, repeats: false)
    }

    func retrievePeripherals(withIdentifiers: [UUID]) -> [CBPeripheral] {
        return centralManager.retrievePeripherals(withIdentifiers: withIdentifiers)
    }

    // MARK: - 连接设备
    func connect(peripheral: CBPeripheral, options: [String: Any]?) {
        guard centralManager.state == .poweredOn || centralManager.state == .unknown else {
            print("error: 连接前请打开蓝牙!")
            return
        }
        scanStop()
        peripheral.delegate = peripheraManager
        centralManager.connect(peripheral, options: options)
    }

    // 连接设备
    func connectToPeripheral(at row: Int) {
        let peripheral: CBPeripheral = BLEManager.shared.peripheralList[row]
        connect(peripheral: peripheral, options: nil)
    }

    /// 断开设备
    func cancelPeripheralConnection(peripheral: CBPeripheral) {
        centralManager.cancelPeripheralConnection(peripheral)
    }

    @objc private func scanfTimeOut() {
        scanStop()
    }

    func scanStop() {
        var isScanning = true
        if #available(iOS 10.0, *) {
            isScanning = centralManager.isScanning
        }

        if isScanning {
            print("scan:停止扫描!")
            BLEManager.shared.scanTimer?.invalidate()
            BLEManager.shared.scanTimer = nil
            BLEManager.shared.centralManager.stopScan()
        }
    }

    // MARK: - 代理

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // 支持高版本和低版本蓝牙
       let state = BLECentralState.init(rawValue: central.state.rawValue) ?? .unknown
        switch (state) {
        case.unsupported:
            print("BLE is not supported")
        case.unauthorized:
            print("BLE is unauthorized")
        case.unknown:
            print("BLE is Unknown")
        case.resetting:
            print("BLE is Resetting")
        case.poweredOff:
            print("BLE service is powered off")
        case.poweredOn:
            central.retrievePeripherals(withIdentifiers: connectedPeripherals.map({$0.identifier}))
            // 扫描蓝牙
            print("BLE service is powered on")
        }

        DispatchQueue.runInMainQueue {
            // UpdateBluetoothState

            EventEmitter.sharedInstance.dispatch(name: "UpdateBluetoothState", body: [
                "state": state.desc,
                "enable": state == .poweredOn,
                ])
        }
    }

    // 发现外设
    internal func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        if !peripheralList.contains(peripheral) {
            peripheralList.append(peripheral)
        }
        DispatchQueue.runInMainQueue {
           // DiscoverPeripheral
            EventEmitter.sharedInstance.dispatch(name: "DiscoverPeripheral", body: [
                "peripheral": peripheral.objectDict,
                "advertisementData": advertisementData,
                "RSSI": RSSI
                ])
        }
    }

    // 连接成功
    internal func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
//        guard !connectedPeripherals.contains(peripheral) else {
//            return
//        }
        peripheraManager.addConnected(peripheral)
        DispatchQueue.runInMainQueue {
            // Connected
            EventEmitter.sharedInstance.dispatch(name: "Connected", body: [
                "peripheral": peripheral.objectDict,
                ])
        }
    }

    // 连接中断
    internal func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        peripheraManager.removeConnected(peripheral)
        print("---BlueTooth Disconnect---\n连接中断:\(String(describing: error))")
        DispatchQueue.runInMainQueue {
            // Disconnected
            EventEmitter.sharedInstance.dispatch(name: "Disconnected", body: [
                "peripheral": peripheral.objectDict,
                ])
        }
    }

    internal func centralManager(_ central: CBCentralManager, willRestoreState dict: [String: Any]) {
        // 恢复设备连接,启用后台才能用
        DispatchQueue.runInMainQueue {
            // WillRestore
        }
    }

    // 连接失败
    internal func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        DispatchQueue.runInMainQueue {
            // FailToConnect
            EventEmitter.sharedInstance.dispatch(name: "FailToConnect", body: [
                "peripheral": peripheral.objectDict,
                ])
        }
    }

    // MARK: 后台监听,应该放业务层去做,这里给出方法
//    CBConnectPeripheralOptionNotifyOnConnectionKey：后台连接成功时，可以为指定的peripheral显示一个提示时//    CBConnectPeripheralOptionNotifyOnDisconnectionKey：后台连接断开时，可以为指定的peripheral显示一个断开连接的提示时
//    CBConnectPeripheralOptionNotifyOnNotificationKey：后台接收到给定peripheral端的通知就显示一个提示。

    //MARK: - 查找顶层控制器、
    /// 获取顶层控制器 根据window
    func getTopVC() -> (UIViewController?) {
        var window = UIApplication.shared.keyWindow
        //是否为当前显示的window
        if window?.windowLevel != UIWindowLevelNormal{
            let windows = UIApplication.shared.windows
            for  windowTemp in windows{
                if windowTemp.windowLevel == UIWindowLevelNormal{
                    window = windowTemp
                    break
                }
            }
        }

        let vc = window?.rootViewController
        return getTopVC(withCurrentVC: vc)
    }

    ///根据控制器获取 顶层控制器
    func getTopVC(withCurrentVC VC :UIViewController?) -> UIViewController? {

        if VC == nil {
            print("🌶： 找不到顶层控制器")
            return nil
        }

        if let presentVC = VC?.presentedViewController {
            //modal出来的 控制器
            return getTopVC(withCurrentVC: presentVC)
        }
        else if let tabVC = VC as? UITabBarController {
            // tabBar 的跟控制器
            if let selectVC = tabVC.selectedViewController {
                return getTopVC(withCurrentVC: selectVC)
            }
            return nil
        } else if let naiVC = VC as? UINavigationController {
            // 控制器是 nav
            return getTopVC(withCurrentVC:naiVC.visibleViewController)
        }
        else {
            // 返回顶控制器
            return VC
        }
    }
}

class EventEmitter {

/// Shared Instance.
public static var sharedInstance = EventEmitter()

// ReactNativeEventEmitter is instantiated by React Native with the bridge.
private static var eventEmitter: RCTEventEmitter!

private init() {}

// When React Native instantiates the emitter it is registered here.
func registerEventEmitter(eventEmitter: RCTEventEmitter) {
    EventEmitter.eventEmitter = eventEmitter
}

func dispatch(name: String, body: Any?) {
    EventEmitter.eventEmitter.sendEvent(withName: name, body: body)
}

/// All Events which must be support by React Native.
lazy var allEvents: [String] = {
    var allEventNames: [String] = ["DiscoverPeripheral"]

    // Append all events here

    return allEventNames
}()

}


@objc(BLERNEventSender)
class BLERNEventSender: RCTEventEmitter, RCTBridgeDelegate {

    override init() {
        super.init()
        EventEmitter.sharedInstance.registerEventEmitter(eventEmitter: self)
    }

    func sourceURL(for bridge: RCTBridge!) -> URL! {
        return URL(string: "http://192.168.1.125:8081/index.bundle?platform=ios")
    }


    @objc open override func supportedEvents() -> [String] {
        return EventEmitter.sharedInstance.allEvents
    }
}

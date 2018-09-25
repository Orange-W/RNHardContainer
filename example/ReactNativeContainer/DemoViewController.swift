//
//  DemoViewController.swift
//  Lottery
//
//  Created by Scott Law on 17/4/5.
//
//

import UIKit
import React
import SnapKit
import Rswift

#if DEBUG || ALPHA
import netfox
#endif

class DemoViewController: UIViewController {

    private var buttonConfigs: [[String: Selector]] = [
        ["网络请求监控": #selector(goNetMonitor)],
    ]

    let RNClassName = "RNExample"
    let RNMoudleSelector = NSSelectorFromString("RNMoudleName")
    let RNParamsSelector = NSSelectorFromString("RNParams")
    let RNTitleSelector = NSSelectorFromString("RNTitle")
    @objc func openRN(sender: UIButton) {
        let className = RNClassName + String(buttonConfigs.count - sender.tag - 1)
        guard let moudleName: String = getSwiftStaticProperty(className: className, selector: RNMoudleSelector) else {
            return
        }

        let params: [String: Any] = getSwiftStaticProperty(className: className, selector: RNParamsSelector) ?? [:]

        let vc = UIViewController()
        let view = RCTRootView.init(bridge: RCTBridge.init(delegate: BLERNEventSender(), launchOptions: [:]), moduleName: moudleName, initialProperties: params)
        vc.view = view
        self.present(vc, animated: true, completion: nil)
    }

    @objc func goNetMonitor() {
        #if DEBUG || ALPHA
        NFX.sharedInstance().show()
        #endif
    }

    private func runExecutor(className: String, selector: Selector, userinfo: [String: Any]) -> Bool {
        let classInstance = NSClassFromString(className) as AnyObject
        if classInstance.classForCoder.alloc().responds(to: selector),
            classInstance.classForCoder.alloc().perform(selector, with: userinfo) != nil {
            return true
        } else {
            return false
        }
    }

    private func getSwiftStaticProperty<T>(className: String, selector: Selector) -> T? {
        let classInstance = NSClassFromString(className) as AnyObject
        guard classInstance.classForCoder.alloc().responds(to: selector) else {
            return nil
        }
        let returnValue = classInstance.classForCoder.alloc().perform(selector, with: [:])
        guard let value = returnValue else {
            return nil
        }
        let back: T? = value.takeUnretainedValue() as? T
        return back
    }

    func convertCfTypeToString(cfValue: Unmanaged<AnyObject>!) -> NSString? {
        let value = Unmanaged.fromOpaque(
            cfValue.toOpaque()).takeUnretainedValue() as CFString
        if CFGetTypeID(value) == CFStringGetTypeID() {
            return NSString.init(string: value)
        } else {
            return nil
        }
    }

    private func setupView() {

        //
        let scrollView = UIScrollView()
        scrollView.delegate = self
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        let columnsInRow = 3
        let width = Int(UIScreen.main.bounds.width / CGFloat(columnsInRow))
        let height = 30
        var divOffSet = 0

        for i in 0...100 {
            let className = RNClassName + String(i)
            if let title: String = getSwiftStaticProperty(className: className, selector: RNTitleSelector) {
                buttonConfigs.append([title:#selector(openRN(sender:))])
            }
        }


        for var index in 0 ..< buttonConfigs.count {
//        for buttonConf in buttonConfigs.sorted(by: { one, other -> Bool in
//            return one.key.compare(other.key).rawValue < 0
//        }) {
            let buttonConf = buttonConfigs[index].first!

            index = buttonConfigs.count - 1 - index
            let row = index / columnsInRow
            let col = index % columnsInRow

            let button = UIButton(type: .custom)
            button.setTitle("\(index + 1)-\(buttonConf.key)", for: .normal)
            button.setTitleColor(UIColor.black, for: .normal)
            button.tag = index
            button.addTarget(self, action: (buttonConf.value), for: .touchUpInside)
            button.contentHorizontalAlignment = .left
            scrollView.addSubview(button)

            var xOffset = col * width
            let extraSpace = Int(UIScreen.main.bounds.width) - width * columnsInRow
            let eachExtraSpace = extraSpace / (columnsInRow + 1)

            xOffset += eachExtraSpace * (col + 1)

            let frame = CGRect(x: xOffset, y: row * height + divOffSet, width: width, height: height)
            button.frame = frame

        }

        let rowCount = (buttonConfigs.count - 1) / columnsInRow + 1
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: CGFloat(rowCount * height + divOffSet))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationItem.title = "Demo\(arc4random() % 100)"


        let bar = self.navigationController?.navigationBar
        // self.navigationController?.navigationBar.clipsToBounds = true

        bar?.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        bar?.shadowImage = UIImage()


        self.setupView()

        // TEST
        UserDefaults.standard.set(false, forKey: "isBind")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    deinit {

    }
}

extension DemoViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        guard let titleView = navigationItem.titleView as? ConcealingTitleView else { return }
//        titleView.scrollViewDidScroll(scrollView)
    }

}

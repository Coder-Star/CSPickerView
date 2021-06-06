//
//  PickerViewManager.swift
//  CSPickerView
//  弹出框控制
//  Created by CoderStar on 2021/6/6.
//

import UIKit

@objcMembers
public class PickerViewManager: UIView {
    public typealias BtnAction = () -> Void
    public typealias SingleDoneAction = (_ selectedIndex: Int, _ selectedValue: String) -> Void
    public typealias MultipleDoneAction = (_ selectedIndexs: [Int], _ selectedValues: [String]) -> Void
    public typealias DateDoneAction = (_ selectedDate: Date) -> Void
    public typealias MultipleAssociatedDataType = [[[String: [String]?]]]

    private var pickerView: PickerView!

    // MARK: - 常量

    private let pickerViewHeight: CGFloat = 260.0
    private let screenWidth = UIScreen.main.bounds.size.width
    private let screenHeight = UIScreen.main.bounds.size.height
    private var hideFrame: CGRect {
        return CGRect(x: 0.0, y: screenHeight, width: screenWidth, height: pickerViewHeight)
    }

    private var showFrame: CGRect {
        return CGRect(x: 0.0, y: screenHeight - pickerViewHeight, width: screenWidth, height: pickerViewHeight)
    }

    // MARK: - 初始化

    // 单列
    convenience init(frame: CGRect, toolBarTitle: String, singleColData: [String], defaultSelectedIndex: Int?, cancelAction: BtnAction?, sureAction: SingleDoneAction?) {
        self.init(frame: frame)
        pickerView = PickerView.singleColPicker(toolBarTitle, singleColData: singleColData, defaultIndex: defaultSelectedIndex, cancelAction: { [unowned self] in
            cancelAction?()
            self.dimiss()
        }, sureAction: { [unowned self] selectedIndex, selectedValue in
            sureAction?(selectedIndex, selectedValue)
            self.dimiss()
        })
        pickerView.frame = hideFrame
        addSubview(pickerView)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapAction(_:)))
        addGestureRecognizer(tap)
    }

    // 多列不关联
    convenience init(frame: CGRect, toolBarTitle: String, multipleColsData: [[String]], defaultSelectedIndexs: [Int]?, cancelAction: BtnAction?, sureAction: MultipleDoneAction?) {
        self.init(frame: frame)
        pickerView = PickerView.multipleCosPicker(toolBarTitle, multipleColsData: multipleColsData, defaultSelectedIndexs: defaultSelectedIndexs, cancelAction: { [unowned self] in
            cancelAction?()
            self.dimiss()
        }, doneAction: { [unowned self] selectedIndexs, selectedValues in
            sureAction?(selectedIndexs, selectedValues)
            self.dimiss()
        })
        pickerView.frame = hideFrame
        addSubview(pickerView)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapAction(_:)))
        addGestureRecognizer(tap)
    }

    // 多列关联
    convenience init(frame: CGRect, toolBarTitle: String, multipleAssociatedColsData: MultipleAssociatedDataType, defaultSelectedValues: [String]?, cancelAction: BtnAction?, sureAction: MultipleDoneAction?) {
        self.init(frame: frame)
        pickerView = PickerView.multipleAssociatedCosPicker(toolBarTitle, multipleAssociatedColsData: multipleAssociatedColsData, defaultSelectedValues: defaultSelectedValues, cancelAction: { [unowned self] in
            cancelAction?()
            self.dimiss()
        }, doneAction: { [unowned self] selectedIndexs, selectedValues in
            sureAction?(selectedIndexs, selectedValues)
            self.dimiss()
        })
        pickerView.frame = hideFrame
        addSubview(pickerView)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapAction(_:)))
        addGestureRecognizer(tap)
    }

    // 城市选择器
    convenience init(frame: CGRect, toolBarTitle: String, type: CityPickStyle, defaultSelectedValues: [String]?, cancelAction: BtnAction?, sureAction: MultipleDoneAction?) {
        self.init(frame: frame)
        pickerView = PickerView.citiesPicker(toolBarTitle, type: type, defaultSelectedValues: defaultSelectedValues, cancelAction: { [unowned self] in
            cancelAction?()
            self.dimiss()
        }, doneAction: { [unowned self] selectedIndexs, selectedValues in
            sureAction?(selectedIndexs, selectedValues)
            self.dimiss()
        })
        pickerView.frame = hideFrame
        addSubview(pickerView)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapAction(_:)))
        addGestureRecognizer(tap)
    }

    // 日期选择器
    convenience init(frame: CGRect, toolBarTitle: String, datePickerSetting: DatePickerSetting, cancelAction: BtnAction?, sureAction: DateDoneAction?) {
        self.init(frame: frame)
        pickerView = PickerView.datePicker(toolBarTitle, datePickerSetting: datePickerSetting, cancelAction: { [unowned self] in
            cancelAction?()
            self.dimiss()
        }, doneAction: { [unowned self] selectedDate in
            sureAction?(selectedDate)
            self.dimiss()
        })
        pickerView.frame = hideFrame
        addSubview(pickerView)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapAction(_:)))
        addGestureRecognizer(tap)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addOrentationObserver()
    }

    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - selector

extension PickerViewManager {
    private func addOrentationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.statusBarOrientationChange), name: UIApplication.didChangeStatusBarOrientationNotification, object: nil)
    }

    // 屏幕旋转时移除pickerView
    @objc
    func statusBarOrientationChange() {
        removeFromSuperview()
    }

    @objc
    func tapAction(_ tap: UITapGestureRecognizer) {
        let location = tap.location(in: self)
        if location.y <= screenHeight - pickerViewHeight {
            self.dimiss()
        }
    }
}

// MARK: - 弹出和移除self

extension PickerViewManager {
    /// 通过window 弹出view
    private func show(completion: ((Bool) -> Void)? = nil) {
        let window = UIApplication.shared.keyWindow
        guard let currentWindow = window else { return }
        currentWindow.addSubview(self)
        UIView.animate(withDuration: PickerViewConfig.shared.animateDuration, animations: { [weak self] in
            guard let self = self else { return }
            self.backgroundColor = PickerViewConfig.shared.maskColor
            self.pickerView.frame = self.showFrame
        }, completion: { complete in
            completion?(complete)
        })
    }

    /// 把self从window中移除
    public func dimiss(completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: PickerViewConfig.shared.animateDuration, animations: { [weak self] in
            guard let self = self else { return }
            self.backgroundColor = UIColor.clear
            self.pickerView.frame = self.hideFrame
        }, completion: { [weak self] complete in
            self?.removeFromSuperview()
            completion?(complete)
        })
    }
}

// MARK: - 快速使用方法

extension PickerViewManager {
    /// 单列选择器
    ///  - parameter title:                      标题
    ///  - parameter data:                       数据；数据为空时，会弹出提示框提示数据为空
    ///  - parameter defaultSeletedIndex:        默认选中的行数；传入当默认索引不在合理范围内,会默认显示第一个
    /// - Parameter cancelAction: 取消回调
    /// - Parameter sureAction: 确定回调
    public class func showSingleColPicker(_ toolBarTitle: String,
                                          data: [String],
                                          defaultSelectedIndex: Int?,
                                          cancelAction: BtnAction?,
                                          sureAction: SingleDoneAction?) {
        if data.isEmpty {
            assertionFailure("data is empty")
            return
        }
        guard let currentWindow = UIApplication.shared.keyWindow else { return }
        currentWindow.endEditing(true)
        let pickViewManager = PickerViewManager(frame: currentWindow.bounds, toolBarTitle: toolBarTitle, singleColData: data, defaultSelectedIndex: defaultSelectedIndex, cancelAction: cancelAction, sureAction: sureAction)
        pickViewManager.show()
    }

    /// 多列不关联选择器
    /// - Parameter toolBarTitle: 标题
    /// - Parameter data: 数据；为空时，会弹出提示框提示数据为空
    /// - Parameter defaultSelectedIndexs: 默认选中的每一列的行数；当默认索引不在合理范围内,会默认显示第一个，默认索引数组数量不做限制，已兼容
    /// - Parameter cancelAction: 取消回调
    /// - Parameter sureAction: 确定回调
    public class func showMultipleColsPicker(_ toolBarTitle: String,
                                             data: [[String]],
                                             defaultSelectedIndexs: [Int]?,
                                             cancelAction: BtnAction?,
                                             sureAction: MultipleDoneAction?) {
        if data.isEmpty {
            assertionFailure("data is empty")
            return
        }
        guard let currentWindow = UIApplication.shared.keyWindow else { return }
        currentWindow.endEditing(true)
        let pickViewManager = PickerViewManager(frame: currentWindow.bounds, toolBarTitle: toolBarTitle, multipleColsData: data, defaultSelectedIndexs: defaultSelectedIndexs, cancelAction: cancelAction, sureAction: sureAction)
        pickViewManager.show()
    }

    /// 多列关联选择器
    /// - Parameter toolBarTitle: 标题
    /// - Parameter data: 数据；为空时，会弹出提示框提示数据为空
    /// - Parameter defaultSelectedValues: 默认选中的每一列的数值；当默认值不存在时,会默认显示第一个，默认数据数组数量不做限制，已兼容
    /// - Parameter cancelAction: 取消回调
    /// - Parameter sureAction: 确定回调
    public class func showMultipleAssociatedColsPicker(_ toolBarTitle: String,
                                                       data: MultipleAssociatedDataType,
                                                       defaultSelectedValues: [String]?,
                                                       cancelAction: BtnAction?,
                                                       sureAction: MultipleDoneAction?) {
        if data.isEmpty {
            assertionFailure("data is empty")
            return
        }
        guard let currentWindow = UIApplication.shared.keyWindow else { return }
        currentWindow.endEditing(true)
        let pickViewManager = PickerViewManager(frame: currentWindow.bounds, toolBarTitle: toolBarTitle, multipleAssociatedColsData: data, defaultSelectedValues: defaultSelectedValues, cancelAction: cancelAction, sureAction: sureAction)
        pickViewManager.show()
    }

    /// 城市选择器
    /// - Parameter toolBarTitle:  标题
    /// - Parameter type: 显示样式类型
    /// - Parameter defaultSelectedValues: 默认选中的每一列的值, 注意不是行数；当默认值不存在时,会默认显示第一个，默认数据数组数量不做限制，已兼容
    /// - Parameter cancelAction: 取消回调
    /// - Parameter sureAction: 确定回调
    public class func showCitiesPicker(_ toolBarTitle: String,
                                       type: CityPickStyle = .province,
                                       defaultSelectedValues: [String]?,
                                       cancelAction: BtnAction?,
                                       sureAction: MultipleDoneAction?) {
        guard let currentWindow = UIApplication.shared.keyWindow else { return }
        currentWindow.endEditing(true)
        let pickViewManager = PickerViewManager(frame: currentWindow.bounds, toolBarTitle: toolBarTitle, type: type, defaultSelectedValues: defaultSelectedValues, cancelAction: cancelAction, sureAction: sureAction)
        pickViewManager.show()
    }

    /// 日期选择器
    /// - Parameter toolBarTitle: 标题
    /// - Parameter datePickerSetting: 可配置UIDatePicker的样式
    /// - Parameter cancelAction: 取消回调
    /// - Parameter sureAction: 确定回调
    public class func showDatePicker(_ toolBarTitle: String,
                                     datePickerSetting: DatePickerSetting = DatePickerSetting(),
                                     cancelAction: BtnAction?,
                                     sureAction: DateDoneAction?) {
        guard let currentWindow = UIApplication.shared.keyWindow else { return }
        currentWindow.endEditing(true)
        let pickViewManager = PickerViewManager(frame: currentWindow.bounds, toolBarTitle: toolBarTitle, datePickerSetting: datePickerSetting, cancelAction: cancelAction, sureAction: sureAction)
        pickViewManager.show()
    }
}

//
//  DurationDatePickView.swift
//  CSPickerView
//  起止时间选择弹出框
//  Created by CoderStar on 2021/6/6.
//

import Foundation
import UIKit

/// 选择器样式
@objc
public enum DurationDatePickerViewDateType: Int {
    /// 年月日
    case YMD
    /// 年月日时分
    case YMDHM

    public var formatStr: String {
        switch self {
        case .YMD:
            return "yyyy-MM-dd"
        case .YMDHM:
            return "yyyy-MM-dd HH:mm"
        }
    }
}

/// 起止时间弹出框
@objcMembers
open class DurationDatePickerView: UIView {
    public typealias SureBlock = (_ startDate: String, _ endDate: String) -> Void
    public typealias CancelBlock = () -> Void

    /// 选择日期是否可大于现在，默认true
    public var canGreatNow = true
    /// 选择日期是否可小于现在，默认true
    public var canLessNow = true
    /// 确定闭包
    public var sureBlock: SureBlock?
    /// 取消闭包
    public var cancelBlock: CancelBlock?

    /// 日期类型
    private var dateType: DurationDatePickerViewDateType = .YMD
    /// 最小时间
    private let minDate: Date? = nil
    /// 最大时间
    private let maxDate: Date? = nil
    /// 弹窗距离左右边距
    private let leftAndRightMargin: CGFloat = 35
    /// 弹窗高度
    private let popupViewHeight: CGFloat = 220
    /// 时间选择器的高度
    private let datePickerHeight: CGFloat = 200
    /// 时间选择器
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.calendar = Calendar.current
        datePicker.timeZone = TimeZone.current
        if let language = Locale.preferredLanguages.first {
            datePicker.locale = Locale(identifier: language)
        }
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        // 背景色需要在preferredDatePickerStyle设置后设置，否则会被preferredDatePickerStyle设置冲掉样式
        datePicker.backgroundColor = PickerViewConfig.shared.mainBackgroundColor
        datePicker.alpha = 0
        return datePicker
    }()

    /// 屏幕高度
    private let screenHeight = UIScreen.main.bounds.height
    /// 屏幕宽度
    private let screenWidth = UIScreen.main.bounds.width

    public lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.frame = CGRect(x: 0, y: 0, width: popupView.frame.width, height: 50)
        titleLabel.text = PickerViewUtils.localizedString(key: "CSPickerView.startEndTime")
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = PickerViewConfig.shared.mainTextColor
        titleLabel.textAlignment = .center
        return titleLabel
    }()

    public lazy var startBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitleColor(PickerViewConfig.shared.mainTextColor, for: .normal)
        btn.setTitleColor(PickerViewConfig.shared.mainTextColor, for: .selected)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        btn.titleLabel?.textAlignment = .right
        btn.addTarget(self, action: #selector(startBtnAction(btn:)), for: .touchUpInside)

        let titleString = PickerViewUtils.formatDate(date: datePicker.date, formatStr: dateType.formatStr)
        btn.setTitle(titleString, for: .normal)
        if dateType == .YMDHM {
            let title = DurationDatePickerView.appendTime(dateAndTime: titleString)
            btn.setTitle(title, for: .normal)
        }
        btn.isSelected = true
        return btn
    }()

    public lazy var endBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitleColor(PickerViewConfig.shared.mainTextColor, for: .normal)
        btn.setTitleColor(PickerViewConfig.shared.mainTextColor, for: .selected)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        btn.titleLabel?.textAlignment = .left
        btn.addTarget(self, action: #selector(endBtnAction(btn:)), for: .touchUpInside)
        return btn
    }()

    public lazy var cancelBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 0, y: self.popupView.frame.height - 49, width: (self.popupView.frame.width - 1) / 2.0, height: 49)
        btn.setTitle(PickerViewUtils.localizedString(key: "CSPickerView.cancel"), for: .normal)
        btn.setTitleColor(PickerViewConfig.shared.mainTextColor, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        btn.addTarget(self, action: #selector(cancelBtnAction), for: .touchUpInside)
        return btn
    }()

    public lazy var confirmBtn: UIButton = {
        let btn = UIButton(type: .custom)
        let x: CGFloat = self.popupView.frame.width - self.cancelBtn.frame.width - 1
        let y: CGFloat = self.popupView.frame.height - 49
        let w: CGFloat = (self.popupView.frame.width - 1) / 2.0
        let h: CGFloat = 49
        btn.frame = CGRect(x: x, y: y, width: w, height: h)
        btn.setTitle(PickerViewUtils.localizedString(key: "CSPickerView.sure"), for: .normal)
        btn.setTitleColor(PickerViewConfig.shared.mainTextColor, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        btn.addTarget(self, action: #selector(confirmBtnAction), for: .touchUpInside)
        return btn
    }()

    // MARK: 内部控件，懒加载

    private lazy var coverView: UIView = {
        let coverView = UIView()
        coverView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        coverView.addGestureRecognizer(tapGesture)
        return coverView
    }()

    private lazy var popupView: UIView = {
        let popupView = UIView()
        let width = screenWidth - (leftAndRightMargin * 2)
        let topMargin: CGFloat = (screenHeight - popupViewHeight - datePickerHeight) / 2
        popupView.frame = CGRect(x: leftAndRightMargin, y: topMargin, width: width, height: popupViewHeight)
        popupView.backgroundColor = PickerViewConfig.shared.mainBackgroundColor
        popupView.layer.masksToBounds = true
        popupView.layer.cornerRadius = 10
        popupView.alpha = 0
        return popupView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addOrentationObserver()
        UIApplication.shared.keyWindow?.addSubview(self)
        self.frame = self.superview?.bounds ?? UIScreen.main.bounds
        self.addSubview(coverView)
        self.addSubview(datePicker)
        self.addSubview(popupView)
    }

    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func addOrentationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.statusBarOrientationChange), name: UIApplication.didChangeStatusBarOrientationNotification, object: nil)
    }

    // 屏幕旋转时移除pickerView
    @objc
    func statusBarOrientationChange() {
        removeFromSuperview()
    }

    @objc
    private func dismiss() {
        dismiss(completion: nil)
    }
}

// MARK: - 暴露出去的方法，供外部调用

extension DurationDatePickerView {
    /// 展示起止时间弹出框
    /// - Parameters:
    ///   - startDate: 开始时间
    ///   - endDate: 结束时间
    ///   - dateType: 时间类型
    public class func getPopupView(startDate: Date, endDate: Date, dateType: DurationDatePickerViewDateType = .YMD) -> DurationDatePickerView {
        UIApplication.shared.keyWindow?.endEditing(true)
        let popupView = DurationDatePickerView(frame: UIScreen.main.bounds)

        popupView.datePicker.setDate(startDate, animated: false)

        popupView.dateType = dateType

        if dateType == .YMDHM {
            let startTitle = appendTime(dateAndTime: PickerViewUtils.formatDate(date: startDate, formatStr: dateType.formatStr))
            popupView.startBtn.setTitle(startTitle, for: .normal)

            let endTitle = appendTime(dateAndTime: PickerViewUtils.formatDate(date: endDate, formatStr: dateType.formatStr))
            popupView.endBtn.setTitle(endTitle, for: .normal)
        } else {
            popupView.startBtn.setTitle(PickerViewUtils.formatDate(date: startDate, formatStr: dateType.formatStr), for: .normal)
            popupView.endBtn.setTitle(PickerViewUtils.formatDate(date: endDate, formatStr: dateType.formatStr), for: .normal)
        }

        popupView.setDatePickerStyle()
        popupView.setPopupView()
        popupView.startBtnAction(btn: popupView.startBtn)
        return popupView
    }

    /// 弹出框显示
    public func show(completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: PickerViewConfig.shared.animateDuration, animations: { [weak self] in
            self?.coverView.backgroundColor = PickerViewConfig.shared.maskColor
            self?.popupView.alpha = 1
            self?.datePicker.alpha = 1
        }, completion: { complete in
            completion?(complete)
        })
    }

    /// 弹出框消失
    @objc public func dismiss(completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: PickerViewConfig.shared.animateDuration, animations: { [weak self] in
            self?.coverView.backgroundColor = .clear
            self?.popupView.alpha = 0
            self?.datePicker.alpha = 0
        }, completion: { complete in
            self.removeFromSuperview()
            completion?(complete)
        })
    }
}

// MARK: - 事件处理

extension DurationDatePickerView {
    @objc
    private func startBtnAction(btn: UIButton) {
        btn.isSelected = true
        endBtn.isSelected = false
        if canLessNow {
            datePicker.minimumDate = minDate
        } else {
            datePicker.minimumDate = Date(timeIntervalSinceNow: 0)
        }
        if canGreatNow {
            datePicker.maximumDate = maxDate
        } else {
            datePicker.maximumDate = Date(timeIntervalSinceNow: 0)
        }
        rollCurrentDate(btn: btn)
    }

    @objc
    private func endBtnAction(btn: UIButton) {
        btn.isSelected = true
        startBtn.isSelected = false
        if let date = PickerViewUtils.toDate(dateStr: startBtn.currentTitle, dateTypeStr: dateType.formatStr) {
            datePicker.minimumDate = date
        }
        if canGreatNow {
            datePicker.maximumDate = maxDate
        } else {
            datePicker.maximumDate = Date(timeIntervalSinceNow: 0)
        }
        rollCurrentDate(btn: btn)
    }

    @objc
    private func cancelBtnAction() {
        if let block = cancelBlock {
            block()
        }
        dismiss()
    }

    @objc
    private func confirmBtnAction() {
        if let block = sureBlock {
            let startDate = startBtn.currentTitle?.replaceNewlineWithWhitespace() ?? ""
            let endDate = endBtn.currentTitle?.replaceNewlineWithWhitespace() ?? ""
            block(startDate, endDate)
        }
        dismiss()
    }

    @objc
    private func datePicekerValueChanged(picker: UIDatePicker) {
        let date = picker.date
        let titleString = PickerViewUtils.formatDate(date: date, formatStr: dateType.formatStr)

        if startBtn.isSelected {
            if dateType == .YMD {
                startBtn.setTitle(titleString, for: .normal)
                if titleString > endBtn.currentTitle ?? "" {
                    guard let titleDate = PickerViewUtils.toDate(dateStr: titleString, dateTypeStr: dateType.formatStr) else {
                        return
                    }
                    let endDateStr = PickerViewUtils.formatDate(date: Date(timeInterval: TimeInterval(1 * 24 * 60 * 60), since: titleDate), formatStr: dateType.formatStr)
                    endBtn.setTitle(endDateStr, for: .normal)
                }
            } else if dateType == .YMDHM {
                let title = DurationDatePickerView.appendTime(dateAndTime: titleString)
                startBtn.setTitle(title, for: .normal)
                if titleString > endBtn.currentTitle?.replaceNewlineWithWhitespace() ?? "" {
                    guard let titleDate = PickerViewUtils.toDate(dateStr: titleString, dateTypeStr: dateType.formatStr) else {
                        return
                    }
                    let tempDateStr = PickerViewUtils.formatDate(date: Date(timeInterval: TimeInterval(1 * 24 * 60 * 60), since: titleDate), formatStr: dateType.formatStr)
                    let endDateStr = DurationDatePickerView.appendTime(dateAndTime: tempDateStr)
                    endBtn.setTitle(endDateStr, for: .normal)
                }
            }
        } else {
            endBtn.setTitle(titleString, for: .normal)
            if dateType == .YMDHM {
                let title = DurationDatePickerView.appendTime(dateAndTime: titleString)
                endBtn.setTitle(title, for: .normal)
            }
        }
    }
}

// MARK: - 私有方法

extension DurationDatePickerView {
    private func rollCurrentDate(btn: UIButton) {
        if let dateStr = btn.currentTitle?.replaceNewlineWithWhitespace(), let date = PickerViewUtils.toDate(dateStr: dateStr, dateTypeStr: dateType.formatStr) {
            datePicker.setDate(date, animated: true)
        }
    }

    /// 设置日期选择器相关属性
    private func setDatePickerStyle() {
        datePicker.frame = CGRect(x: 0, y: screenHeight - datePickerHeight, width: screenWidth, height: datePickerHeight)
        if dateType == .YMDHM {
            datePicker.datePickerMode = .dateAndTime
        } else if dateType == .YMD {
            datePicker.datePickerMode = .date
        }

        if canLessNow {
            datePicker.minimumDate = minDate
        } else {
            datePicker.minimumDate = Date(timeIntervalSinceNow: 0)
        }

        if canGreatNow {
            datePicker.maximumDate = maxDate
        } else {
            datePicker.maximumDate = Date(timeIntervalSinceNow: 0)
        }

        datePicker.addTarget(self, action: #selector(datePicekerValueChanged(picker:)), for: .valueChanged)
    }

    /// 设置popupView上的子控件
    private func setPopupView() {
        // 第一部分
        popupView.addSubview(titleLabel)
        let topLineView = UIView()
        topLineView.frame = CGRect(x: 0, y: 50, width: popupView.frame.width, height: 1)
        topLineView.backgroundColor = PickerViewConfig.shared.lineColor
        popupView.addSubview(topLineView)

        // 第二部分
        popupView.addSubview(self.startBtn)
        self.startBtn.frame = CGRect(x: 20, y: topLineView.frame.maxY + 20, width: (popupView.frame.width - 60) / 2.0, height: popupView.frame.height - 100 - 40)
        self.startBtn.titleLabel?.lineBreakMode = .byCharWrapping
        self.startBtn.titleLabel?.numberOfLines = 0
        self.startBtn.titleLabel?.textAlignment = .center

        let tempLabel = UILabel()
        tempLabel.frame = CGRect(x: self.startBtn.frame.maxX, y: self.startBtn.frame.minY, width: 20, height: self.startBtn.frame.height)
        tempLabel.textAlignment = .center
        tempLabel.text = PickerViewUtils.localizedString(key: "CSPickerView.to")
        tempLabel.font = UIFont.systemFont(ofSize: 14)
        tempLabel.textColor = PickerViewConfig.shared.mainTextColor
        popupView.addSubview(tempLabel)

        popupView.addSubview(self.endBtn)
        self.endBtn.frame = CGRect(x: tempLabel.frame.maxX, y: self.startBtn.frame.minY, width: self.startBtn.frame.width, height: self.startBtn.frame.height)
        self.endBtn.titleLabel?.lineBreakMode = .byCharWrapping
        self.endBtn.titleLabel?.numberOfLines = 0
        self.endBtn.titleLabel?.textAlignment = .center

        let bottomLineView = UIView()
        bottomLineView.frame = CGRect(x: 0, y: popupViewHeight - 50, width: popupView.frame.width, height: 1)
        bottomLineView.backgroundColor = PickerViewConfig.shared.lineColor
        popupView.addSubview(bottomLineView)

        // 第三部分
        popupView.addSubview(self.cancelBtn)

        let verticalLineView = UIView()
        verticalLineView.frame = CGRect(x: self.cancelBtn.frame.width, y: self.cancelBtn.frame.minY, width: 1, height: self.cancelBtn.frame.height)
        verticalLineView.backgroundColor = PickerViewConfig.shared.lineColor
        popupView.addSubview(verticalLineView)

        popupView.addSubview(self.confirmBtn)
    }
}

// MARK: - 方法

extension DurationDatePickerView {
    private static func appendTime(dateAndTime: String) -> String {
        let date = String(dateAndTime.prefix(10))
        let time = String(dateAndTime[dateAndTime.index(dateAndTime.startIndex, offsetBy: 11) ..< dateAndTime.index(dateAndTime.startIndex, offsetBy: 16)])
        return date + "\n" + time
    }
}

extension String {
    /// 使用空格替换字符串中的换行
    fileprivate func replaceNewlineWithWhitespace() -> String {
        return self.replacingOccurrences(of: "\n", with: " ")
    }
}

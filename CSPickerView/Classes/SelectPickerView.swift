//
//  SelectPickerView.swift
//  CSPickerView
//  选择器(单、多选)
//  Created by CoderStar on 2021/6/6.
//

import Foundation
import UIKit

// MARK: - 属性

@objcMembers
public class SelectPickerView: UIView {
    /// 数据
    public var titleArr = [String]() {
        didSet {
            tableView.reloadData()
        }
    }

    /// 清空按钮闭包
    public var cancelAction: PickerViewManager.BtnAction?
    /// 确定按钮闭包,多选
    public var sureAction: PickerViewManager.MultipleDoneAction?
    /// 确定按钮闭包,单选
    public var singleSureAction: PickerViewManager.SingleDoneAction?

    /// 选中的索引数组，多选
    private var selectIndexArr = [Int]()
    /// 选中的索引，单选
    private var selectIndex: Int?
    /// toobar高度
    private let toolBarHeight: CGFloat = 44
    /// tableview高度
    private let tableViewHeight: CGFloat = 216
    /// 总高度
    private var pickHeight: CGFloat {
        return toolBarHeight + tableViewHeight
    }

    /// 是否单项选择
    private var isSingle = false

    /// 屏幕高度
    private let screenHeight = UIScreen.main.bounds.height
    /// 屏幕宽度
    private let screenWidth = UIScreen.main.bounds.width
    /// 隐藏时frame
    private var hideFrame: CGRect {
        return CGRect(x: 0.0, y: screenHeight, width: screenWidth, height: pickHeight)
    }

    /// 显示时frame
    private var showFrame: CGRect {
        return CGRect(x: 0.0, y: screenHeight - pickHeight, width: screenWidth, height: pickHeight)
    }

    // MARK: - 私有控件

    private lazy var coverView: UIView = {
        let coverView = UIView()
        coverView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        coverView.addGestureRecognizer(tapGesture)
        return coverView
    }()

    private lazy var pickView: UIView = {
        let pickView = UIView()
        pickView.frame = hideFrame
        return pickView
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.separatorColor = PickerViewConfig.shared.lineColor
        tableView.delegate = self
        tableView.estimatedRowHeight = 35
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView()
        return tableView
    }()

    private lazy var toolBarView: ToolBarView = {
        let toolBarView = ToolBarView()
        return toolBarView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        UIApplication.shared.keyWindow?.addSubview(self)
        addOrentationObserver()
        self.frame = self.superview?.bounds ?? UIScreen.main.bounds
        self.addSubview(coverView)
        self.addSubview(pickView)
        pickView.addSubview(toolBarView)
        pickView.addSubview(tableView)

        toolBarView.cancelAction = { [weak self] in
            self?.cancelAction?()
            self?.dismiss()
        }
        toolBarView.sureAction = { [weak self] in
            guard let self = self else { return }
            if self.isSingle {
                if let tempIndex = self.selectIndex {
                    self.singleSureAction?(tempIndex, self.titleArr[tempIndex])
                    self.dismiss()
                } else {
                    self.singleSureAction?(-1, "")
                    self.dismiss()
                }
            } else {
                if self.selectIndexArr.isEmpty {
                    self.sureAction?([], [])
                    self.dismiss()
                } else {
                    let indexArr = self.selectIndexArr.sorted()
                    var valueArr = [String]()
                    for item in indexArr {
                        valueArr.append(self.titleArr[item])
                    }
                    self.sureAction?(indexArr, valueArr)
                    self.dismiss()
                }
            }
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        toolBarView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: toolBarHeight)
        tableView.frame = CGRect(x: 0, y: toolBarHeight, width: screenWidth, height: tableViewHeight)
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

// MARK: - 对外暴露方法

extension SelectPickerView {
    /// 展示多选view
    /// - Parameters:
    ///   - title: 标题
    ///   - data: 数据
    ///   - defaultSelectedIndex: 默认选中索引
    ///   - cancelAction: 取消回调
    ///   - sureAction: 确定回调
    public class func showView(title: String,
                               data: [String],
                               defaultSelectedIndexs: [Int]?,
                               cancelAction: @escaping PickerViewManager.BtnAction,
                               sureAction: @escaping PickerViewManager.MultipleDoneAction) {
        guard let view = getView(title: title, data: data, defaultSelectedIndexs: defaultSelectedIndexs) else {
            return
        }
        view.cancelAction = cancelAction
        view.sureAction = sureAction
        view.show()
    }

    /// 获取多选view
    /// - Parameters:
    ///   - title: 标题
    ///   - data: 数据
    ///   - defaultSelectedIndexs: 默认选中索引,如果为nil，表示都不选中
    /// - Returns: SelectPickerView
    public class func getView(title: String, data: [String], defaultSelectedIndexs: [Int]?) -> SelectPickerView? {
        if data.isEmpty {
            return nil
        }
        UIApplication.shared.keyWindow?.endEditing(true)
        let view = SelectPickerView()
        view.titleArr = data
        if let indexArr = defaultSelectedIndexs {
            for item in indexArr where item >= 0 && item < data.count {
                view.selectIndexArr.append(item)
            }
        }
        view.toolBarView.title = title
        return view
    }

    /// 展示单选view
    /// - Parameters:
    ///   - title: 标题
    ///   - data: 数据
    ///   - defaultSelectedIndex: 默认选中索引
    ///   - cancelAction: 取消回调
    ///   - sureAction: 确定回调
    public class func showSingleView(title: String,
                                     data: [String],
                                     defaultSelectedIndex: Int?,
                                     cancelAction: @escaping PickerViewManager.BtnAction,
                                     sureAction: @escaping PickerViewManager.SingleDoneAction) {
        guard let view = getSingleView(title: title, data: data, defaultSelectedIndex: defaultSelectedIndex) else {
            return
        }
        view.cancelAction = cancelAction
        view.singleSureAction = sureAction
        view.show()
    }

    /// 获取单选view
    /// - Parameters:
    ///   - title: 标题
    ///   - data: 数据
    ///   - defaultSelectedIndexs: 默认选中索引,如果为nil，表示都不选中
    public class func getSingleView(title: String, data: [String], defaultSelectedIndex: Int?) -> SelectPickerView? {
        if data.isEmpty {
            return nil
        }
        UIApplication.shared.keyWindow?.endEditing(true)
        let view = SelectPickerView()
        view.titleArr = data
        if let index = defaultSelectedIndex, index >= 0, index < data.count {
            view.selectIndex = index
        }
        view.isSingle = true
        view.toolBarView.title = title
        return view
    }

    /// 弹出框显示
    public func show(completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: PickerViewConfig.shared.animateDuration, animations: { [weak self] in
            guard let self = self else { return }
            self.pickView.frame = self.showFrame
            self.coverView.backgroundColor = PickerViewConfig.shared.maskColor
        }, completion: { complete in
            completion?(complete)
        })
    }

    /// 弹出框消失
    @objc
    public func dismiss(completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: PickerViewConfig.shared.animateDuration, animations: { [unowned self] in
            self.pickView.frame = self.hideFrame
            self.coverView.backgroundColor = .clear
        }, completion: { complete in
            self.removeFromSuperview()
            completion?(complete)
        })
    }
}

// MARK: - UITableView相关代理

extension SelectPickerView: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArr.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: SelectPickerViewTableCell.description()) as? SelectPickerViewTableCell
        if cell == nil {
            cell = SelectPickerViewTableCell(style: .default, reuseIdentifier: SelectPickerViewTableCell.description())
        }
        cell?.titleLabel.text = titleArr[indexPath.row]
        if isSingle {
            if selectIndex == indexPath.row {
                cell?.accessoryType = .checkmark
            } else {
                cell?.accessoryType = .none
            }
        } else {
            if selectIndexArr.contains(indexPath.row) {
                cell?.accessoryType = .checkmark
            } else {
                cell?.accessoryType = .none
            }
        }
        return cell!
    }
}

extension SelectPickerView: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isSingle {
            selectIndex = indexPath.row
        } else {
            if let index = selectIndexArr.firstIndex(of: indexPath.row) {
                selectIndexArr.remove(at: index)
            } else {
                selectIndexArr.append(indexPath.row)
            }
        }
        tableView.reloadData()
    }

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == titleArr.count - 1 {
            tableView.layoutIfNeeded()
            /// 为tableView加上header,使内容垂直居中
            let margin = tableViewHeight - tableView.contentSize.height
            if margin > 0 {
                let headerView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: margin / 2))
                let lineView = UIView(frame: CGRect(x: 0, y: headerView.frame.height - 0.05, width: screenWidth, height: 0.05))
                lineView.backgroundColor = PickerViewConfig.shared.lineColor
                headerView.addSubview(lineView)
                tableView.tableHeaderView = headerView
            }
        }
    }
}

class SelectPickerViewTableCell: UITableViewCell {
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byCharWrapping
        return titleLabel
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    private func setupView() {
        backgroundColor = PickerViewConfig.shared.mainBackgroundColor
        separatorInset = .zero
        selectionStyle = .none
        self.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: titleLabel.superview!, attribute: .top, multiplier: 1.0, constant: 10)
        let leftConstraint = NSLayoutConstraint(item: titleLabel, attribute: .left, relatedBy: .equal, toItem: titleLabel.superview!, attribute: .left, multiplier: 1.0, constant: 10)
        let bottomConstraint = NSLayoutConstraint(item: titleLabel, attribute: .bottom, relatedBy: .equal, toItem: titleLabel.superview!, attribute: .bottom, multiplier: 1.0, constant: -10)
        let rightConstraint = NSLayoutConstraint(item: titleLabel, attribute: .right, relatedBy: .equal, toItem: titleLabel.superview!, attribute: .right, multiplier: 1.0, constant: -50)
        addConstraints([topConstraint, leftConstraint, bottomConstraint, rightConstraint])
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
}

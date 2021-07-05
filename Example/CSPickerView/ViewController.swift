//
//  ViewController.swift
//  CSPickerView
//
//  Created by Coder-Star on 06/06/2021.
//  Copyright (c) 2021 Coder-Star. All rights reserved.
//

import CSPickerView
import SnapKit
import UIKit

class ViewController: UIViewController {
    enum dataType: String {
        case startAndEndDate = "起止日期"
        case startAndEndTime = "起止时间"
        case date = "日期"
        case time = "时间"
        case dateAndTime = "时间和日期"
        case single = "单列"
        case multiple = "多列不关联"
        case multipleAssociated = "多列关联"
        case city = "省市区"
        case singleSelect = "单选"
        case multipleSelect = "多选"
        case style = "自定义样式"

        var formateStr: String? {
            switch self {
            case .date:
                return "yyyy-MM-dd"
            case .time:
                return "HH:mm"
            case .dateAndTime:
                return "yyyy-MM-dd HH:mm"
            default:
                return nil
            }
        }
    }

    private let dataArr: [dataType] = [
        .startAndEndDate,
        .startAndEndTime,
        .date,
        .time,
        .dateAndTime,
        .single,
        .multiple,
        .multipleAssociated,
        .city,
        .singleSelect,
        .multipleSelect,
        .style,
    ]

    /// 单列
    private let singleData = ["swift", "ObjecTive-C(主要是用来测试数据很长时候选择的样式哦，很长很长很长很长很长的字)", "C", "C++", "java", "php", "python", "ruby", "js"]

    /// 多列不关联
    private let multipleData = [
        ["1天", "2天", "3天", "4天", "5天", "6天", "7天"],
        ["1小时", "2小时", "3小时", "4小时", "5小时"],
        ["1分钟", "2分钟", "3分钟", "4分钟", "5分钟", "6分钟", "7分钟", "8分钟", "9分钟", "10分钟"],
    ]

    /// 多列关联
    private let multipleAssociatedData: [[[String: [String]?]]] = [
        [["交通工具": ["陆地", "空中", "水上"]], // 字典
         ["食品": ["健康食品", "垃圾食品"]],
         ["游戏": ["益智游戏", "角色游戏"]]],
        [["陆地": ["公交车", "小轿车", "自行车"]],
         ["空中": ["飞机"]],
         ["水上": ["轮船"]],
         ["健康食品": ["蔬菜", "水果"]],
         ["垃圾食品": ["辣条", "不健康小吃"]],
         ["益智游戏": ["消消乐", "消灭星星"]],
         ["角色游戏": ["lol", "cf"]]],
    ]

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.delegate = self
        tableView.rowHeight = 44
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "CSPickerView"
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type = dataArr[indexPath.row]
        var tableCell = tableView.dequeueReusableCell(withIdentifier: "tableCell")
        if tableCell == nil {
            tableCell = UITableViewCell(style: .default, reuseIdentifier: "tableCell")
        }
        tableCell?.textLabel?.text = type.rawValue
        return tableCell!
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let type = dataArr[indexPath.row]
        switch type {
        case .startAndEndDate, .startAndEndTime:
            let start = Date()
            let end = Date(timeInterval: 1 * 24 * 60 * 60, since: start)
            let popupView = DurationDatePickerView.getPopupView(startDate: start, endDate: end, dateType: type == .startAndEndDate ? .YMD : .YMDHM)
            popupView.sureBlock = { [weak self] start, end in
                self?.showAlert("起始时间：\(start)\n结束时间：\(end)")
            }
            popupView.show()
        case .date, .time, .dateAndTime:
            let dateStyle = DatePickerSetting()
            if type == .time {
                dateStyle.dateMode = .time
            } else if type == .dateAndTime {
                dateStyle.dateMode = .dateAndTime
            }

            PickerViewManager.showDatePicker("日期选择", datePickerSetting: dateStyle,
                                             cancelAction: ({}),
                                             sureAction: ({ selectedDate in
                                                 self.showAlert(PickerViewUtils.formatDate(date: selectedDate, formatStr: type.formateStr!))
                                             }))
        case .single:
            PickerViewManager.showSingleColPicker("单列", data: singleData, defaultSelectedIndex: 2, cancelAction: {}, sureAction: { index, value in
                self.showAlert("索引：\(index)\n值：\(value)")
            })
        case .multiple:
            PickerViewManager.showMultipleColsPicker("多列不关联", data: multipleData, defaultSelectedIndexs: [0, 1, 1], cancelAction: {}, sureAction: { index, value in
                self.showAlert("索引：\(index)\n值：\(value)")
            })
        case .multipleAssociated:
            PickerViewManager.showMultipleAssociatedColsPicker("多列关联", data: multipleAssociatedData, defaultSelectedValues: ["食品", "垃圾食品", "不健康小吃"], cancelAction: {}, sureAction: { index, value in
                self.showAlert("索引：\(index)\n值：\(value)")
            })
        case .city:
            PickerViewManager.showCitiesPicker("省市区选择", type: .area, defaultSelectedValues: ["天津市", "天津市", "河东区"], cancelAction: {}, sureAction: { index, value in
                self.showAlert("索引：\(index)\n值：\(value)")
            })
        case .singleSelect:
            SelectPickerView.showSingleView(title: "单项选择", data: singleData, defaultSelectedIndex: 1, cancelAction: {}, sureAction: { index, value in
                self.showAlert("索引：\(index)\n值：\(value)")
            })
        case .multipleSelect:
            SelectPickerView.showView(title: "多项选择", data: singleData, defaultSelectedIndexs: [1], cancelAction: {}, sureAction: { index, value in
                self.showAlert("索引：\(index)\n值：\(value)")
            })
        case .style:
            PickerViewConfig.shared.maskColor = UIColor.black.withAlphaComponent(0.2)
            PickerViewConfig.shared.leftButtonColor = UIColor(hexString: "#999999")
            PickerViewConfig.shared.rightButtonColor = UIColor(hexString: "#32CA99")
            PickerViewConfig.shared.centerLabelColor = UIColor(hexString: "#333333")
            PickerViewConfig.shared.lineColor = .white
            PickerViewConfig.shared.leftButtonFont = UIFont.systemFont(ofSize: 14)
            PickerViewConfig.shared.rightButtonFont = UIFont.systemFont(ofSize: 14)
            PickerViewConfig.shared.centerLabelFont = UIFont.systemFont(ofSize: 16, weight: .medium)
            PickerViewConfig.shared.itemLabelFont = UIFont.systemFont(ofSize: 14)
            PickerViewConfig.shared.itemLabelColor = UIColor(hexString: "#333333")
            PickerViewConfig.shared.toolBarViewTopCornerRadius = 10

            PickerViewManager.showSingleColPicker("单列", data: singleData, defaultSelectedIndex: 2, cancelAction: {}, sureAction: { index, value in
                self.showAlert("索引：\(index)\n值：\(value)")
            })
        }
    }
}

extension ViewController {
    public func showAlert(_ message: String) {
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "关闭", style: .cancel)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension UIColor {
    /// 颜色hex值转颜色，如果hex值去除头部符号后不满6位，返回默认色-白色
    ///
    /// - Parameters:
    ///   - hexString: hex值
    ///   - alpha: 透明度
    public convenience init(hexString: String, alpha: CGFloat = 1.0) {
        var hexString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        hexString = hexString.lowercased()

        if hexString.hasPrefix("#") {
            hexString = String(hexString.dropFirst())
        }
        if hexString.hasPrefix("0x") {
            hexString = String(hexString.dropFirst(2))
        }
        // hex值少于6位，返回白色
        if hexString.count < 6 {
            self.init(red: 255, green: 255, blue: 255, alpha: alpha)
        } else {
            let scanner = Scanner(string: hexString)
            var color: UInt32 = 0
            scanner.scanHexInt32(&color)

            let mask = 0x000000FF
            let r = Int(color >> 16) & mask
            let g = Int(color >> 8) & mask
            let b = Int(color) & mask

            let red = CGFloat(r) / 255.0
            let green = CGFloat(g) / 255.0
            let blue = CGFloat(b) / 255.0

            self.init(red: red, green: green, blue: blue, alpha: alpha)
        }
    }
}

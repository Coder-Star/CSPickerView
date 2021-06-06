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

        var formateStr: String? {
            switch self {
            case .startAndEndDate:
                return nil
            case .startAndEndTime:
                return nil
            case .date:
                return "yyyy-MM-dd"
            case .time:
                return "HH:mm"
            case .dateAndTime:
                return "yyyy-MM-dd HH:mm"
            case .single:
                return nil
            case .multiple:
                return nil
            case .multipleAssociated:
                return nil
            case .city:
                return nil
            case .singleSelect:
                return nil
            case .multipleSelect:
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
    ]

    /// 单列
    private let singleData = ["swift", "ObjecTive-C(主要是用来测试数据很长时候选择的样式哦)", "C", "C++", "java", "php", "python", "ruby", "js"]

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
            var dateStyle = DatePickerSetting()
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

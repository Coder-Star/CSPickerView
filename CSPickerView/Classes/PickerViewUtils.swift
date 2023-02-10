//
//  PickerViewUtils.swift
//  CSPickerView
//  资源管理类
//  Created by CoderStar on 2021/6/6.
//

import Foundation
import UIKit

// MARK: - 资源相关

@objcMembers
public class PickerViewUtils: NSObject {
    public static var resoureBundle: Bundle? {
        if let path = Bundle(for: PickerViewUtils.self).path(forResource: "CSPickerView", ofType: "bundle") {
            return Bundle(path: path)
        }
        return nil
    }

    public static var addressPlistPath: String? {
        return resoureBundle?.path(forResource: "Address", ofType: "plist")
    }

    public static func localizedString(key: String, defaultValue: String? = nil) -> String? {
        var language = PickerViewConfig.shared.languageCode
        if language == nil {
            language = Locale.preferredLanguages.first
        }
        if language?.hasPrefix("zh-Hans") == true {
            language = "zh-Hans"
        } else {
            language = "en"
        }
        guard let bundle = resoureBundle else {
            assertionFailure("Bundle加载失败")
            return nil
        }
        guard let localizedStringPath = bundle.path(forResource: language, ofType: "lproj"), let localizedStringBundle = Bundle(path: localizedStringPath) else {
            assertionFailure("语言包加载失败")
            return nil
        }
        return Bundle.main.localizedString(forKey: key, value: localizedStringBundle.localizedString(forKey: key, value: defaultValue, table: nil), table: nil)
    }
}

// MARK: - 日期工具

extension PickerViewUtils {
    public static func formatDate(date: Date, formatStr: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar.current
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = formatStr
        let dateString = dateFormatter.string(from: date)
        return dateString
    }

    public static func toDate(dateStr: String?, dateTypeStr: String) -> Date? {
        guard let selfLowercased = dateStr?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased().replacingOccurrences(of: "T", with: " ") else {
            return nil
        }
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.calendar = Calendar.current
        formatter.dateFormat = dateTypeStr
        return formatter.date(from: selfLowercased)
    }
}

//
//  PickerViewConfig.swift
//  CSPickerView
//
//  Created by CoderStar on 2021/6/6.
//

import Foundation
import UIKit

@objcMembers
public class PickerViewConfig: NSObject {
    private override init() {}

    public static let shared = PickerViewConfig()

    /// 主背景色
    public var mainBackgroundColor: UIColor = {
        if #available(iOS 13.0, *) {
            return UIColor { traitCollection in
                if traitCollection.userInterfaceStyle == .dark {
                    return UIColor(red: 18 / 255, green: 18 / 255, blue: 18 / 255, alpha: 1)
                } else {
                    return .white
                }
            }
        } else {
            return .white
        }
    }()

    /// 蒙版颜色
    public var maskColor: UIColor = {
        if #available(iOS 13.0, *) {
            return UIColor { traitCollection in
                if traitCollection.userInterfaceStyle == .dark {
                    return UIColor.black.withAlphaComponent(0.45)
                } else {
                    return UIColor.black.withAlphaComponent(0.2)
                }
            }
        } else {
            return UIColor.black.withAlphaComponent(0.2)
        }
    }()

    /// 主文字颜色
    public var mainTextColor = PickerViewConfig.blackWhiteColor

    /// 左边按钮颜色
    public var leftButtonColor = PickerViewConfig.blackWhiteColor
    /// 左边按钮字体
    public var leftButtonFont = UIFont.systemFont(ofSize: UIFont.systemFontSize)

    /// 右边按钮颜色
    public var rightButtonColor = PickerViewConfig.blackWhiteColor
    /// 右边按钮字体
    public var rightButtonFont = UIFont.systemFont(ofSize: UIFont.systemFontSize)

    /// 中间标题颜色
    public var centerLabelColor = PickerViewConfig.blackWhiteColor
    /// 中间标题字体
    public var centerLabelFont = UIFont.systemFont(ofSize: UIFont.systemFontSize)


    /// Picker选项字体
    public var itemLabelFont = UIFont.systemFont(ofSize: UIFont.systemFontSize)
    /// Picker选项颜色
    public var itemLabelColor = PickerViewConfig.blackWhiteColor

    /// 顶部圆角
    public var toolBarViewTopCornerRadius: CGFloat = 0

    /// 分割线颜色
    public var lineColor: UIColor = {
        if #available(iOS 13.0, *) {
            return UIColor { traitCollection in
                if traitCollection.userInterfaceStyle == .dark {
                    return UIColor(red: 42 / 255, green: 42 / 255, blue: 45 / 255, alpha: 1)
                } else {
                    return UIColor(red: 242 / 255, green: 242 / 255, blue: 242 / 255, alpha: 1)
                }
            }
        } else {
            return UIColor(red: 242 / 255, green: 242 / 255, blue: 242 / 255, alpha: 1)
        }
    }()

    /// 强制使用某语言的编码
    public var languageCode: String?

    /// 动画时长
    public var animateDuration: TimeInterval = 0.2
}

extension PickerViewConfig {
    static var whiteBlackColor: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { traitCollection in
                if traitCollection.userInterfaceStyle == .dark {
                    return .black
                } else {
                    return .white
                }
            }
        } else {
            return .white
        }
    }

    static var blackWhiteColor: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { traitCollection in
                if traitCollection.userInterfaceStyle == .dark {
                    return .white
                } else {
                    return .black
                }
            }
        } else {
            return .black
        }
    }
}

# CSPickerView

[![Version](https://img.shields.io/cocoapods/v/CSPickerView.svg?style=flat)](https://cocoapods.org/pods/CSPickerView)
[![License](https://img.shields.io/cocoapods/l/CSPickerView.svg?style=flat)](https://cocoapods.org/pods/CSPickerView)
[![Platform](https://img.shields.io/cocoapods/p/CSPickerView.svg?style=flat)](https://cocoapods.org/pods/CSPickerView)
[![Doc](https://img.shields.io/badge/doc-https%3A%2F%2Fcoder--star.github.io%2FCSPickerView%2F-lightgrey)](https://coder-star.github.io/CSPickerView/)

## 安装
### 手动
将相应文件拷贝到工程中去，注意需要将资源文件也加入进去
### CocoaPods
提供了二种安装方式
- 源码方式，方便调试
- framework形式，减少编译时间

```ruby
pod 'CSPickerView' # framework形式
pod 'CSPickerView', :subspecs => ["source"] # 源码形式
pod 'CSPickerView', :subspecs => ["framework"] # framework形式，与 pod 'CSPickerView' 等效
```


## 功能介绍

- [x] 支持OC、Swift
- [x] 支持暗黑模式
- [x] 支持多种属性个性化设置
- [x] 国际化支持中文、英文，支持覆写其内容，只需在工程中语言文件key值相同便可覆盖

在`PickerViewConfig`这个单例类中看到很多属性，项目中注释也很完善。

```swift
/// 主背景色
public var mainBackgroundColor
/// 蒙板颜色
public var maskColor
/// 主要文字颜色
public var mainTextColor
/// 左侧按钮颜色
public var leftButtonColor
/// 右侧按钮颜色
public var rightButtonColor
/// 中间文字颜色
public var centerLabelColor
/// 分割线颜色
public var lineColor
/// 强制语言编码
public var languageCode
/// 动画时间
public var animateDuration
```

## 效果图
### City

<img width="50%" src="https://github.com/Coder-Star/CSPickerView/raw/main/Sceenshots/city.png">

### StartAndEndDate

startAndEndDate | startAndEndTime 
:-------------: | :-------------: 
![startAndEndDate](https://github.com/Coder-Star/CSPickerView/raw/main/Sceenshots/startAndEndDate.png) | ![startAndEndTime](https://github.com/Coder-Star/CSPickerView/raw/main/Sceenshots/startAndEndTime.png)

### DatePicker

date | time | dateAndTime 
:-------------: | :-------------: | :-------------: 
![date](https://github.com/Coder-Star/CSPickerView/raw/main/Sceenshots/date.png) | ![time](https://github.com/Coder-Star/CSPickerView/raw/main/Sceenshots/time.png) | ![dateAndTime](https://github.com/Coder-Star/CSPickerView/raw/main/Sceenshots/dateAndTime.png) |

### Picker

single | multiple | multipleAssociated 
:-------------: | :-------------: | :-------------: 
![single](https://github.com/Coder-Star/CSPickerView/raw/main/Sceenshots/single.png) | ![multiple](https://github.com/Coder-Star/CSPickerView/raw/main/Sceenshots/multiple.png) | ![multipleAssociated](https://github.com/Coder-Star/CSPickerView/raw/main/Sceenshots/multipleAssociated.png)

### Select

singleSelect | multipleSelect 
:-------------: | :-------------: 
![singleSelect](https://github.com/Coder-Star/CSPickerView/raw/main/Sceenshots/singleSelect.png) | ![multipleSelect](https://github.com/Coder-Star/CSPickerView/raw/main/Sceenshots/multipleSelect.png)

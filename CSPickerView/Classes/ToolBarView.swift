//
//  ToolBarView.swift
//  CSPickerView
//  弹出框顶部显示view
//  Created by CoderStar on 2021/6/6.
//

import UIKit

@objcMembers
open class ToolBarView: UIView {
    open var title = "" {
        didSet {
            titleLabel.text = title
        }
    }

    open var sureAction: PickerViewManager.BtnAction?
    open var cancelAction: PickerViewManager.BtnAction?

    // 用来产生上下分割线的效果
    private lazy var contentView: UIView = {
        let content = UIView()
        content.backgroundColor = PickerViewConfig.shared.mainBackgroundColor
        return content
    }()

    // 文本框
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = PickerViewConfig.shared.centerLabelColor
        label.font = PickerViewConfig.shared.centerLabelFont
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    // 取消按钮
    private lazy var clearBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle(PickerViewUtils.localizedString(key: "CSPickerView.cancel"), for: .normal)
        btn.setTitleColor(PickerViewConfig.shared.leftButtonColor, for: .normal)
        btn.titleLabel?.font = PickerViewConfig.shared.leftButtonFont
        return btn
    }()

    // 完成按钮
    private lazy var doneBtn: UIButton = {
        let donebtn = UIButton()
        donebtn.setTitle(PickerViewUtils.localizedString(key: "CSPickerView.sure"), for: .normal)
        donebtn.setTitleColor(PickerViewConfig.shared.rightButtonColor, for: .normal)
        donebtn.titleLabel?.font = PickerViewConfig.shared.rightButtonFont
        return donebtn
    }()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        backgroundColor = PickerViewConfig.shared.lineColor
        addSubview(contentView)
        contentView.addSubview(clearBtn)
        contentView.addSubview(doneBtn)
        contentView.addSubview(titleLabel)

        doneBtn.addTarget(self, action: #selector(self.sureBtnOnClick(_:)), for: .touchUpInside)
        clearBtn.addTarget(self, action: #selector(self.cancelBtnOnClick(_:)), for: .touchUpInside)
    }

    @objc
    func sureBtnOnClick(_ sender: UIButton) {
        sureAction?()
    }

    @objc
    func cancelBtnOnClick(_ sender: UIButton) {
        cancelAction?()
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        if PickerViewConfig.shared.toolBarViewTopCornerRadius > 0 {
            let fieldPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: PickerViewConfig.shared.toolBarViewTopCornerRadius, height: PickerViewConfig.shared.toolBarViewTopCornerRadius))
            let fieldLayer = CAShapeLayer()
            fieldLayer.frame = bounds
            fieldLayer.path = fieldPath.cgPath
            layer.mask = fieldLayer
        }


        let margin: CGFloat = 15
        let contentHeight = bounds.size.height - 1
        contentView.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: contentHeight)
        let clearBtnSize = clearBtn.sizeThatFits(CGSize(width: 0, height: contentHeight))
        let doneBtnSize = doneBtn.sizeThatFits(CGSize(width: 0, height: contentHeight))
        clearBtn.frame = CGRect(x: margin, y: 0, width: clearBtnSize.width, height: contentHeight)
        doneBtn.frame = CGRect(x: bounds.size.width - doneBtnSize.width - margin, y: 0, width: doneBtnSize.width, height: contentHeight)
        let titleX = clearBtn.frame.maxX + margin
        let titleW = bounds.size.width - titleX - doneBtnSize.width - margin

        titleLabel.frame = CGRect(x: titleX, y: 0.0, width: titleW, height: contentHeight)
    }
}

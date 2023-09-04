//
//  CustomPrivacyView.swift
//  Travio
//
//  Created by Mahmut Gazi Doğan on 1.09.2023.
//

import UIKit
import SnapKit

class CustomPrivacyView: UIView {
    
    var labelText: String = "" {
        didSet {
            lblTitle.text = labelText
        }
    }
    
    private lazy var lblTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: AppFont.medium.rawValue, size: 14)
        label.text = labelText
        return label
    }()
    
    private lazy var switchOnOff: UISwitch = {
        let sw = UISwitch()
//        s.thumbTintColor = .blue
        sw.isOn = false
        return sw
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
      
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        self.roundCorners(corners: [.topLeft, .topRight, .bottomLeft], radius: 16)
    }
    
    private func setupViews() {
        self.backgroundColor = .white
        self.addSubviews(lblTitle,
                         switchOnOff)
        self.addShadow()
        
        setupLayouts()
    }
    
    private func setupLayouts() {
        lblTitle.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        switchOnOff.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        
    }
    
}
//
//  PasswordTVC.swift
//  Travio
//
//  Created by Mahmut Gazi Doğan on 1.09.2023.
//

import UIKit
import SnapKit

class PasswordTVC: UITableViewCell {
    
    static let identifier = "PasswordTVC"
    weak var delegate: ReturnToSecuritySettings?
    
    lazy var textFieldView: CustomTextFieldView = {
        let view = CustomTextFieldView()
        view.textField.delegate = self
        view.secureTextEntry = true
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = .clear
    }
    
    func configure(title: String, tag: Int) {
        textFieldView.titleLabel.text = title
        textFieldView.textField.tag = tag
    }
    
    private func setupViews() {
        contentView.addSubview(textFieldView)
        setupLayouts()
    }
    
    private func setupLayouts() {
        textFieldView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-8)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
        }
    }
}

extension PasswordTVC: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text, textField == textFieldView.textField else {
            return
        }
                
        switch textField.tag {
        case 0:
            delegate?.passwordTransfer(password: text)
        case 1:
            delegate?.confirmPasswordTransfer(confirmPassword: text)
        default:
            break
        }
    }
}

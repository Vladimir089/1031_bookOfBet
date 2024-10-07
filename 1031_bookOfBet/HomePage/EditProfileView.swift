//
//  EditProfileView.swift
//  1031_bookOfBet
//
//  Created by Владимир Кацап on 07.10.2024.
//

import UIKit

class EditProfileView: UIView {

    let image: UIImage
    let name: String
    
    lazy var imageView = UIImageView(image: image)
    lazy var nameTextField = UITextField()
    
    lazy var cancelButton = UIButton(type: .system)
    lazy var saveButton = UIButton(type: .system)
    
    init(image: UIImage, name: String) {
        self.image = image
        self.name = name
        super.init(frame: .zero)
        createInterface()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createInterface() {
        backgroundColor = UIColor(red: 12/255, green: 19/255, blue: 53/255, alpha: 1)
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 100
        layer.masksToBounds = false
        
        let topLabel = UILabel()
        topLabel.text = "Fill out the profile"
        topLabel.textColor = .white
        topLabel.font = .systemFont(ofSize: 20, weight: .bold)
        addSubview(topLabel)
        topLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(10)
        }
        
        imageView.layer.cornerRadius = 8
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.height.width.equalTo(160)
            make.centerX.equalToSuperview()
            make.top.equalTo(topLabel.snp.bottom).inset(-15)
        }
        
        let nameLabel = UILabel()
        nameLabel.text = "Name"
        nameLabel.textColor = .white.withAlphaComponent(0.7)
        nameLabel.font = .systemFont(ofSize: 13, weight: .regular)
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.top.equalTo(imageView.snp.bottom).inset(-15)
        }
        
        nameTextField.text = name
        nameTextField.layer.cornerRadius = 12
        nameTextField.placeholder = "Text"
        nameTextField.backgroundColor = .white.withAlphaComponent(0.05)
        nameTextField.textColor = .white
        nameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        nameTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        nameTextField.rightViewMode = .always
        nameTextField.leftViewMode = .always
        nameTextField.delegate = self
        addSubview(nameTextField)
        nameTextField.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(54)
            make.top.equalTo(nameLabel.snp.bottom).inset(-15)
        }
        
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.backgroundColor = .white.withAlphaComponent(0.05)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cancelButton.layer.cornerRadius = 12
        cancelButton.setTitleColor(.white, for: .normal)
        addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.left.bottom.equalToSuperview().inset(15)
            make.height.equalTo(50)
            make.right.equalTo(self.snp.centerX).offset(-7.5)
        }
        
        saveButton.isEnabled = false
        saveButton.alpha = 0.5
        saveButton.setTitle("Save", for: .normal)
        saveButton.backgroundColor = UIColor(red: 175/255, green: 218/255, blue: 18/255, alpha: 1)
        saveButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        saveButton.layer.cornerRadius = 12
        saveButton.setTitleColor(.white, for: .normal)
        addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview().inset(15)
            make.height.equalTo(50)
            make.left.equalTo(self.snp.centerX).offset(7.5)
        }
    }
    
    func checkSaveButton() {
        if imageView.image != .defProfile , nameTextField.text?.count ?? 0 > 0 {
            saveButton.isEnabled = true
            saveButton.alpha = 1
        } else {
            saveButton.isEnabled = false
            saveButton.alpha = 0.5
        }
    }
}

extension EditProfileView: UITextFieldDelegate {
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        checkSaveButton()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        checkSaveButton()
        endEditing(true)
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        checkSaveButton()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        checkSaveButton()
        return true
    }
}

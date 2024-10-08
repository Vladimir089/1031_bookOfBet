//
//  NewNoteView.swift
//  1031_bookOfBet
//
//  Created by Владимир Кацап on 08.10.2024.
//

import UIKit

class NewNoteView: UIView {
    
    private lazy var titleTextField = StaticFunc.createTextField(placeholder: "Text")
    private lazy var deskTextView = UITextView()
    lazy var cancelButton = UIButton(type: .system)
    lazy var saveButton = UIButton(type: .system)
    lazy var delButton = UIButton()
    
    var index = 0
    var indexEvent = 0
    var isEdit = false
    

    override init(frame: CGRect) {
        super .init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 4
        layer.masksToBounds = false
        layer.cornerRadius = 20
        backgroundColor = UIColor(red: 12/255, green: 19/255, blue: 53/255, alpha: 1)
        
        let topLabel = UILabel()
        topLabel.text = "Your note"
        topLabel.textColor = .white
        topLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        addSubview(topLabel)
        topLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(15)
        }
        
        let titleLabel = StaticFunc.createLabel(text: "Title")
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.top.equalTo(topLabel.snp.bottom).inset(-15)
        }
        
        addSubview(titleTextField)
        titleTextField.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(54)
            make.top.equalTo(titleLabel.snp.bottom).inset(-10)
        }
        
        let deskLabel = StaticFunc.createLabel(text: "Description")
        addSubview(deskLabel)
        deskLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.top.equalTo(titleTextField.snp.bottom).inset(-15)
        }
        
        deskTextView.backgroundColor = .white.withAlphaComponent(0.05)
        deskTextView.layer.cornerRadius = 12
        deskTextView.textColor = .white
        deskTextView.font = .systemFont(ofSize: 17, weight: .regular)
        deskTextView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        addSubview(deskTextView)
        deskTextView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(deskLabel.snp.bottom).inset(-10)
            make.height.equalTo(160)
        }
        
        cancelButton.backgroundColor = .white.withAlphaComponent(0.05)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.layer.cornerRadius = 12
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.height.equalTo(50)
            make.top.equalTo(deskTextView.snp.bottom).inset(-24)
            make.right.equalTo(self.snp.centerX).offset(-7.5)
        }
        cancelButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        
        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 12
        saveButton.backgroundColor = UIColor(red: 175/255, green: 218/255, blue: 18/255, alpha: 1)
        addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(15)
            make.height.equalTo(50)
            make.top.equalTo(deskTextView.snp.bottom).inset(-24)
            make.left.equalTo(self.snp.centerX).offset(7.5)
        }
        
        delButton.backgroundColor = .clear
        let delLabel = UILabel()
        delLabel.text = "Delete"
        delLabel.textColor = UIColor(red: 175/255, green: 218/255, blue: 18/255, alpha: 1)
        delLabel.font = .systemFont(ofSize: 17, weight: .regular)
        delButton.addSubview(delLabel)
        delLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        let delImageView = UIImageView(image: .del)
        delButton.addSubview(delImageView)
        delImageView.snp.makeConstraints { make in
            make.height.width.equalTo(24)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        addSubview(delButton)
        delButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(24)
            make.width.equalTo(80)
            make.top.equalTo(cancelButton.snp.bottom).inset(-10)
        }
        delButton.alpha = 0
    }
    
    @objc func close() {
        delData()
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0
        }
    }
    
    private func delData() {
        titleTextField.text = ""
        deskTextView.text = ""
        index = 0
        isEdit = false
        endEditing(true)
        delButton.alpha = 0 
    }
    
    func createNew() -> Note {
        
        let title: String = titleTextField.text ?? ""
        let desk: String = deskTextView.text ?? ""
        
        let note = Note(title: title, description: desk)
        print(note)
        return note
    }
    
    
    func edit() {
        titleTextField.text = eventsArr[indexEvent].notes[index].title
        deskTextView.text = eventsArr[indexEvent].notes[index].description
    }
    
    
    
}

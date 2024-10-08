//
//  AddNewEventViewController.swift
//  1031_bookOfBet
//
//  Created by Владимир Кацап on 08.10.2024.
//

import UIKit
import Combine
import CombineCocoa

class AddNewEventViewController: UIViewController {
    
    private lazy var cancellable = [AnyCancellable]()
    
    var isNew = true
    var index = 0
    
    //UI
    private lazy var firstParticipantTextField = StaticFunc.createTextField(placeholder: "Text")
    private lazy var secondParticipantTextField = StaticFunc.createTextField(placeholder: "Text")
    private lazy var dateTextField = StaticFunc.createTextField(placeholder: "April, 08") //не учитывать
    private lazy var timeTextField = StaticFunc.createTextField(placeholder: "12:00 PM")
    
    private var date = ""
    private var selectedCategory = ""
    
    //other
    let datePicker = UIDatePicker()
    let timePicker = UIDatePicker()
    private var arrButtons: [UIButton] = []
    private let saveButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 12/255, green: 19/255, blue: 53/255, alpha: 1)
        checkIsNew()
        createButtons()
        setupUI()
    }
    
    
    private func setupUI() {
        let hideView = UIView()
        hideView.backgroundColor = UIColor(red: 60/255, green: 60/255, blue: 67/255, alpha: 0.3)
        hideView.layer.cornerRadius = 2.5
        view.addSubview(hideView)
        hideView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(10)
            make.height.equalTo(5)
            make.width.equalTo(36)
        }
        
        let topLabel = UILabel()
        topLabel.text = isNew ? "Add" : "Edit"
        topLabel.textColor = .white
        topLabel.font = .systemFont(ofSize: 17, weight: .bold)
        view.addSubview(topLabel)
        topLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(hideView.snp.bottom).inset(-10)
        }
        
        let mainView = UIView()
        mainView.layer.cornerRadius = 12
        mainView.backgroundColor = .white.withAlphaComponent(0.05)
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(topLabel.snp.bottom).inset(-20)
            make.height.equalTo(375)
        }
        
        let oneLabel = StaticFunc.createLabel(text: "1 participant")
        mainView.addSubview(oneLabel)
        oneLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.top.equalToSuperview().inset(15)
        }
        
        mainView.addSubview(firstParticipantTextField)
        firstParticipantTextField.delegate = self
        firstParticipantTextField.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.height.equalTo(54)
            make.top.equalTo(oneLabel.snp.bottom).inset(-10)
            make.right.equalTo(view.snp.centerX).offset(-7.5)
        }
        
        let secondLabel = StaticFunc.createLabel(text: "2 participant")
        mainView.addSubview(secondLabel)
        secondLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(15)
            make.left.equalTo(view.snp.centerX).offset(7.5)
        }
        
        secondParticipantTextField.delegate = self
        mainView.addSubview(secondParticipantTextField)
        secondParticipantTextField.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(15)
            make.height.equalTo(54)
            make.top.equalTo(oneLabel.snp.bottom).inset(-10)
            make.left.equalTo(view.snp.centerX).offset(7.5)
        }
        
        let dateLabel = StaticFunc.createLabel(text: "Date")
        mainView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.top.equalTo(firstParticipantTextField.snp.bottom).inset(-15)
        }
        
        dateTextField.delegate = self
        mainView.addSubview(dateTextField)
        dateTextField.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.height.equalTo(54)
            make.right.equalTo(view.snp.centerX).offset(-30)
            make.top.equalTo(dateLabel.snp.bottom).inset(-10)
        }
        setupDatePicker()
        
        
        let endingLabel = StaticFunc.createLabel(text: "Ending")
        mainView.addSubview(endingLabel)
        endingLabel.snp.makeConstraints { make in
            make.left.equalTo(view.snp.centerX).offset(-7)
            make.top.equalTo(firstParticipantTextField.snp.bottom).inset(-15)
        }
        
        timeTextField.delegate = self
        mainView.addSubview(timeTextField)
        timeTextField.snp.makeConstraints { make in
            make.height.equalTo(54)
            make.right.equalToSuperview().inset(15)
            make.top.equalTo(dateLabel.snp.bottom).inset(-10)
            make.left.equalTo(endingLabel)
        }
        setupTimePicker()
        
        let titleLabel = StaticFunc.createLabel(text: "Title")
        mainView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.top.equalTo(dateTextField.snp.bottom).inset(-15)
        }
        
        let oneStack = createStackView(items: [arrButtons[0], arrButtons[1], arrButtons[2]])
        mainView.addSubview(oneStack)
        oneStack.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(36)
            make.top.equalTo(titleLabel.snp.bottom).inset(-10)
        }
        
        let twoStack = createStackView(items: [arrButtons[3], arrButtons[4], arrButtons[5]])
        mainView.addSubview(twoStack)
        twoStack.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(36)
            make.top.equalTo(oneStack.snp.bottom).inset(-5)
        }
        
        let threeStack = createStackView(items: [arrButtons[6], arrButtons[7], arrButtons[8]])
        mainView.addSubview(threeStack)
        threeStack.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(36)
            make.top.equalTo(twoStack.snp.bottom).inset(-5)
        }
        
        saveButton.setTitle("Save", for: .normal)
        saveButton.layer.cornerRadius = 12
        saveButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        
        saveButton.isEnabled = false
        saveButton.backgroundColor = .white.withAlphaComponent(0.05)
        saveButton.setTitleColor(.white.withAlphaComponent(0.2), for: .normal)
        
        view.addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(50)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(10)
        }
        
        saveButton.tapPublisher
            .sink { _ in
                self.save()
            }
            .store(in: &cancellable)
        
        let hideKBGesture = UITapGestureRecognizer(target: self, action: #selector(hideKB))
        view.addGestureRecognizer(hideKBGesture)
    }
    
    private func save() {
        
        let time: String = timeTextField.text ?? ""
        let firstGroup: String = firstParticipantTextField.text ?? ""
        let secondGroup: String = secondParticipantTextField.text ?? ""
        
        let event = Event(date: date, time: time, bids: [], cetegor: selectedCategory, oneComand: firstGroup, secondComand: secondGroup, notes: [])
        
        if isNew == true {
            eventsArr.append(event)
        } else {
            eventsArr[index].date = date
            eventsArr[index].time = time
            eventsArr[index].cetegor = selectedCategory
            eventsArr[index].oneComand = firstGroup
            eventsArr[index].secondComand = secondGroup
        }
 
        do {
            let data = try JSONEncoder().encode(eventsArr) //тут мкассив конвертируем в дату
            try saveAthleteArrToFile(data: data)
           
            globalPublisher.send(0)
            self.dismiss(animated: true)
        } catch {
            print("Failed to encode or save athleteArr: \(error)")
        }
        
    }
    
    func saveAthleteArrToFile(data: Data) throws {
        let fileManager = FileManager.default
        if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filePath = documentDirectory.appendingPathComponent("event.plist")
            try data.write(to: filePath)
        } else {
            throw NSError(domain: "SaveError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to get document directory"])
        }
    }
    
    
    @objc func hideKB() {
        cheskSaveButton()
        view.endEditing(true)
    }
    
    private func createStackView(items: [UIButton]) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: items)
        stack.axis = .horizontal
        stack.spacing = 5
        stack.distribution = .fillEqually
        stack.backgroundColor = .clear
        return stack
    }
    
    private func setupDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        toolbar.setItems([doneButton], animated: false)
        dateTextField.inputAccessoryView = toolbar
        dateTextField.inputView = datePicker
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long // или вы можете настроить формат самостоятельно
        dateFormatter.dateFormat = "MMMM, dd"
        dateTextField.text = dateFormatter.string(from: sender.date)
    }
    
    @objc private func doneButtonTapped() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        date = dateFormatter.string(from: datePicker.date)
        dateTextField.resignFirstResponder()
        cheskSaveButton()
    }
    
    private func setupTimePicker() {
        // Установка режима выбора времени
        timePicker.datePickerMode = .time
        if #available(iOS 13.4, *) {
            timePicker.preferredDatePickerStyle = .wheels
        }
        timePicker.addTarget(self, action: #selector(timeChanged(_:)), for: .valueChanged)
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTappedTime))
        toolbar.setItems([doneButton], animated: false)
        timeTextField.inputAccessoryView = toolbar
        timeTextField.inputView = timePicker
    }
    
    @objc private func timeChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        timeTextField.text = dateFormatter.string(from: sender.date)
    }
    
    @objc private func doneButtonTappedTime() {
        timeTextField.resignFirstResponder()
        cheskSaveButton()
    }
    
    private func createButtons() {
        let typesArr = ["Football", "Basketball", "Tennis", "Hockey", "Baseball", "Volleyball", "Handball", "Esports", "Table tennis"]
        
        for i in typesArr {
            let button = UIButton(type: .system)
            button.setTitle(i, for: .normal)
            button.layer.cornerRadius = 18
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
            button.setTitleColor(selectedCategory == i ? .white : .white.withAlphaComponent(0.2), for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
            button.backgroundColor = selectedCategory == i ? UIColor(red: 175/255, green: 218/255, blue: 18/255, alpha: 1) : .white.withAlphaComponent(0.05)
            button.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
            arrButtons.append(button)
        }
    }
    
    @objc func buttonTapped(sender: UIButton) {
        for i in arrButtons {
            i.backgroundColor = .white.withAlphaComponent(0.05)
            i.setTitleColor(.white.withAlphaComponent(0.2), for: .normal)
        }
        sender.backgroundColor = UIColor(red: 175/255, green: 218/255, blue: 18/255, alpha: 1)
        sender.setTitleColor(.white, for: .normal)
        selectedCategory = sender.titleLabel?.text ?? ""
        cheskSaveButton()
    }
    
    
    private func checkIsNew() {
        if isNew == false {
            firstParticipantTextField.text = eventsArr[index].oneComand
            secondParticipantTextField.text = eventsArr[index].secondComand
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if let date = dateFormatter.date(from: eventsArr[index].date) {
                dateFormatter.dateFormat = "MMMM, dd"
                dateTextField.text = dateFormatter.string(from: date)
                self.date = eventsArr[index].date
            }
            timeTextField.text = eventsArr[index].time
            selectedCategory = eventsArr[index].cetegor
        }
    }
    
    private func cheskSaveButton() {
        if firstParticipantTextField.text?.count ?? 0 > 0 , secondParticipantTextField.text?.count ?? 0 > 0 , dateTextField.text?.count ?? 0 > 0, timeTextField.text?.count ?? 0 > 0, selectedCategory != "" {
            saveButton.isEnabled = true
            saveButton.backgroundColor = UIColor(red: 175/255, green: 218/255, blue: 18/255, alpha: 1)
            saveButton.setTitleColor(.white, for: .normal)
        } else {
            saveButton.isEnabled = false
            saveButton.backgroundColor = .white.withAlphaComponent(0.05)
            saveButton.setTitleColor(.white.withAlphaComponent(0.2), for: .normal)
        }
    }
    
    
}

extension AddNewEventViewController: UITextFieldDelegate {
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        cheskSaveButton()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        cheskSaveButton()
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        cheskSaveButton()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        cheskSaveButton()
        return true
    }
}

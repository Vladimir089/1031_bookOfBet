//
//  EditNewBidsViewController.swift
//  1031_bookOfBet
//
//  Created by Владимир Кацап on 09.10.2024.
//

import UIKit
import Combine
import CombineCocoa

class EditNewBidsViewController: UIViewController {
    
    private lazy var cancellable = [AnyCancellable]()
    
    var isNew = true
    var indexBids = 0
    var indexEvent = 0
    
    //ui
    private lazy var mainView = UIView()
    private lazy var topLabel = UILabel()
    private lazy var stageLabel = StaticFunc.createLabel(text: "The stage of execut")
    private lazy var selectTypeButton = UIButton(type: .system)
    private lazy var saveButton = UIButton(type: .system)
    
    //data
    private lazy var segmentedControl = UISegmentedControl(items: ["Active", "Completed"])
    private lazy var titleTextField = StaticFunc.createTextField(placeholder: "Text")
    private lazy var betTextField = StaticFunc.createTextField(placeholder: "Text")
    private lazy var coeffTextField = StaticFunc.createTextField(placeholder: "Text")
    private lazy var stageTextField = StaticFunc.createTextField(placeholder: "In process")
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 12/255, green: 19/255, blue: 53/255, alpha: 1)
        title = isNew ? "Add" : "Edit"
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        setupUI()
    }
    

    private func setupUI() {
        let hideView = UIView()
        hideView.backgroundColor = UIColor(red: 60/255, green: 60/255, blue: 67/255, alpha: 0.3)
        hideView.layer.cornerRadius = 2.5
        view.addSubview(hideView)
        hideView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(5)
            make.width.equalTo(36)
            make.height.equalTo(5)
        }
        
        topLabel.textColor = .white
        topLabel.font = .systemFont(ofSize: 28, weight: .bold)
        topLabel.text = "Fill in the details"
        view.addSubview(topLabel)
        topLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        let rightLabel = UILabel()
        rightLabel.text = "2/2"
        rightLabel.textColor = UIColor(red: 175/255, green: 218/255, blue: 18/255, alpha: 1)
        rightLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        view.addSubview(rightLabel)
        rightLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(15)
            make.centerY.equalTo(topLabel)
        }
        
        mainView.backgroundColor = .white.withAlphaComponent(0.05)
        mainView.layer.cornerRadius = 12
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(topLabel.snp.bottom).inset(-15)
            make.height.equalTo(isNew ? 282 : (eventsArr[indexEvent].bids[indexBids].isCompleted == true ? 378 : 282))
        }
        
        segmentedControl.selectedSegmentIndex = isNew ? 0 : (eventsArr[indexEvent].bids[indexBids].isCompleted == true ? 1 : 0)
        segmentedControl.selectedSegmentTintColor = UIColor(red: 175/255, green: 218/255, blue: 18/255, alpha: 1)
        let normalTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white
        ]
        segmentedControl.setTitleTextAttributes(normalTextAttributes, for: .normal)
        segmentedControl.setTitleTextAttributes(normalTextAttributes, for: .selected)
        mainView.addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview().inset(15)
            make.height.equalTo(50)
        }
        
        segmentedControl.selectedSegmentIndexPublisher
            .sink { index in
                self.changeMainViewHeight(selectedIndex: index)
            }
            .store(in: &cancellable)
        
        let titleLabel = StaticFunc.createLabel(text: "Title")
        mainView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.top.equalTo(segmentedControl.snp.bottom).inset(-15)
        }
        
        mainView.addSubview(titleTextField)
        titleTextField.delegate = self
        titleTextField.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(titleLabel.snp.bottom).inset(-10)
            make.height.equalTo(54)
        }
        
        titleTextField.text = isNew ? "" : eventsArr[indexEvent].bids[indexBids].nameStavka
        
        let betLabel = StaticFunc.createLabel(text: "Bet")
        mainView.addSubview(betLabel)
        betLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.top.equalTo(titleTextField.snp.bottom).inset(-15)
        }
        
        betTextField.keyboardType = .numberPad
        betTextField.delegate = self
        mainView.addSubview(betTextField)
        betTextField.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.height.equalTo(54)
            make.top.equalTo(betLabel.snp.bottom).inset(-10)
            make.right.equalTo(view.snp.centerX).offset(-7)
        }
        
        betTextField.text = isNew ? "" : eventsArr[indexEvent].bids[indexBids].stavka
        
        let coeffLabel = StaticFunc.createLabel(text: "Coefficient")
        mainView.addSubview(coeffLabel)
        coeffLabel.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).inset(-15)
            make.left.equalTo(view.snp.centerX).offset(7)
        }
        
        coeffTextField.keyboardType = .decimalPad
        coeffTextField.delegate = self
        mainView.addSubview(coeffTextField)
        coeffTextField.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(15)
            make.height.equalTo(54)
            make.top.equalTo(betLabel.snp.bottom).inset(-10)
            make.left.equalTo(view.snp.centerX).offset(7)
        }
        coeffTextField.text = isNew ? "" : eventsArr[indexEvent].bids[indexBids].cofficent
        
       
        mainView.addSubview(stageLabel)
        stageLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.top.equalTo(coeffTextField.snp.bottom).inset(-15)
        }
        stageLabel.alpha =  isNew ? 0 : (eventsArr[indexEvent].bids[indexBids].isCompleted == true ? 1 : 0)
        
        stageTextField.isEnabled = false
        stageTextField.delegate = self
        mainView.addSubview(stageTextField)
        stageTextField.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(54)
            make.top.equalTo(stageLabel.snp.bottom).inset(-15)
        }
    
        selectTypeButton.setBackgroundImage(.selectType, for: .normal)
        selectTypeButton.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        
        mainView.addSubview(selectTypeButton)
        
        selectTypeButton.snp.makeConstraints { make in
            make.width.equalTo(20)
            make.centerY.equalTo(stageTextField)
            make.right.equalTo(stageTextField.snp.right).inset(15)
            make.height.equalTo(12)
        }

        
        stageTextField.alpha =  isNew ? 0 : (eventsArr[indexEvent].bids[indexBids].isCompleted == true ? 1 : 0)
        stageTextField.text =  isNew ? "" : (eventsArr[indexEvent].bids[indexBids].rezult == true ? "Victory" : "Loss")
        
        
        let hideKBGesture = UITapGestureRecognizer(target: self, action: nil)
        view.addGestureRecognizer(hideKBGesture)
        hideKBGesture.tapPublisher
            .sink { _ in
                self.checkSaveButton()
                self.view.endEditing(true)
            }
            .store(in: &cancellable)
        
        
        let backButton = UIButton(type: .system)
        backButton.backgroundColor = .white.withAlphaComponent(0.05)
        backButton.layer.cornerRadius = 12
        backButton.setTitle("Back", for: .normal)
        backButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        backButton.setTitleColor(.white, for: .normal)
        
        view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.height.equalTo(50)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(10)
            make.right.equalTo(view.snp.centerX).offset(-7)
        }
        
        if isNew {
            backButton.tapPublisher
                .sink { _ in
                    self.navigationController?.popViewController(animated: true)
                }
                .store(in: &cancellable)
        } else {
            backButton.tapPublisher
                .sink { _ in
                    self.dismiss(animated: true)
                }
                .store(in: &cancellable)
        }
        
        saveButton.isEnabled = false
        saveButton.layer.cornerRadius = 12
        saveButton.setTitle("Save", for: .normal)
        saveButton.backgroundColor = .white.withAlphaComponent(0.05)
        saveButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        saveButton.setTitleColor(.white.withAlphaComponent(0.2), for: .normal)
        view.addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(15)
            make.height.equalTo(50)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(10)
            make.left.equalTo(view.snp.centerX).offset(7)
        }
        saveButton.tapPublisher
            .sink { _ in
                self.saveItem()
            }
            .store(in: &cancellable)
    }
    
    private func saveItem() {
        
        let coeff: String = coeffTextField.text?.replacingOccurrences(of: ",", with: ".") ?? ""
        let name: String = titleTextField.text ?? ""
        let bet: String = betTextField.text ?? ""
        let result: Bool = stageTextField.text == "Victory" ? true : false
        let isCompleted: Bool = segmentedControl.selectedSegmentIndex == 0 ? false : true
        
        let bids = Bids(cofficent: coeff, nameStavka: name, stavka: bet, rezult: result, isCompleted: isCompleted)
        
        if isNew == true {
            eventsArr[indexEvent].bids.append(bids)
        } else {
            eventsArr[indexEvent].bids[indexBids] = bids
        }
        
        do {
            let data = try JSONEncoder().encode(eventsArr)
            try saveEventsArrToFile(data: data)
            globalPublisher.send(0)
            self.dismiss(animated: true)
        } catch {
            print("Failed to encode or save athleteArr: \(error)")
        }
    }
    
    func saveEventsArrToFile(data: Data) throws {
        let fileManager = FileManager.default
        if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filePath = documentDirectory.appendingPathComponent("event.plist")
            try data.write(to: filePath)
        } else {
            throw NSError(domain: "SaveError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to get document directory"])
        }
    }
    
    @objc func menuButtonTapped(_ sender: UIButton) {
           let firstAction = UIAction(title: "Victory", image: nil) { _ in
               self.stageTextField.text = "Victory"
               self.checkSaveButton()
           }

           let secondAction = UIAction(title: "Loss", image: nil) { _ in
               self.stageTextField.text = "Loss"
               self.checkSaveButton()
           }

           let menu = UIMenu(title: "", children: [firstAction, secondAction])

           if #available(iOS 14.0, *) {
               sender.menu = menu
               sender.showsMenuAsPrimaryAction = true
           }
       }
    
    private func changeMainViewHeight(selectedIndex: Int) {
        if selectedIndex == 0 {
            UIView.animate(withDuration: 0.3) {
                self.stageLabel.alpha = 0
                self.stageTextField.alpha = 0
                self.selectTypeButton.alpha = 0
                self.mainView.snp.remakeConstraints({ make in
                    make.left.right.equalToSuperview().inset(15)
                    make.top.equalTo(self.topLabel.snp.bottom).inset(-15)
                    make.height.equalTo(282)
                })
                self.view.layoutIfNeeded()
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.mainView.snp.remakeConstraints({ make in
                    make.left.right.equalToSuperview().inset(15)
                    make.top.equalTo(self.topLabel.snp.bottom).inset(-15)
                    make.height.equalTo(378)
                })
                self.stageLabel.alpha = 1
                self.stageTextField.alpha = 1
                self.selectTypeButton.alpha = 1
                self.view.layoutIfNeeded()
            }
           
        }
        checkSaveButton()
    }
    
    private func checkSaveButton() {
        
        
        if segmentedControl.selectedSegmentIndex == 1 {
            if titleTextField.text?.count ?? 0 > 0, betTextField.text?.count ?? 0 > 0 , coeffTextField.text?.count ?? 0 > 0 , stageTextField.text?.count ?? 0 > 0 {
                saveButton.backgroundColor = UIColor(red: 175/255, green: 218/255, blue: 18/255, alpha: 1)
                saveButton.setTitleColor(.white, for: .normal)
                saveButton.isEnabled = true
            } else {
                saveButton.backgroundColor = .white.withAlphaComponent(0.05)
                saveButton.setTitleColor(.white.withAlphaComponent(0.2), for: .normal)
                saveButton.isEnabled = false
            }
        } else {
            if titleTextField.text?.count ?? 0 > 0, betTextField.text?.count ?? 0 > 0 , coeffTextField.text?.count ?? 0 > 0 {
                saveButton.backgroundColor = UIColor(red: 175/255, green: 218/255, blue: 18/255, alpha: 1)
                saveButton.setTitleColor(.white, for: .normal)
                saveButton.isEnabled = true
            } else {
                saveButton.backgroundColor = .white.withAlphaComponent(0.05)
                saveButton.setTitleColor(.white.withAlphaComponent(0.2), for: .normal)
                saveButton.isEnabled = false
            }
        }
        
        
        
        
    }

}


extension EditNewBidsViewController: UITextFieldDelegate {
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        checkSaveButton()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        checkSaveButton()
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

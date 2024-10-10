//
//  HomeViewController.swift
//  1031_bookOfBet
//
//  Created by Владимир Кацап on 07.10.2024.
//

import UIKit
import Combine
import CombineCocoa

class HomeViewController: UIViewController, UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    //profile
    private lazy var imageViewProfile: UIImageView = {
        let imageView = UIImageView(image: .defProfile)
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var nameProfile: UILabel = {
        let label = UILabel()
        label.text = "Hi!"
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    private var profileData: Profile?
    private lazy var editProfileView = EditProfileView(image: UIImage(data: profileData?.image ?? Data() ) ?? .defProfile , name: profileData?.name ?? "")
    
    //Combine
    private lazy var cancellable = [AnyCancellable]()
    private lazy var loadDataClass = LoadDataFromFile()
    
    //Balance
    private lazy var balanceLabel = UILabel()
    private lazy var countWinLabel = UILabel()
    
    //collection
    private var collection: UICollectionView?
    private lazy var nilArrView = UIView()
    private lazy var mainArr = [(Event, Bids)]()
    private lazy var openAllBidsButton = UIButton(type: .system)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = " "
        self.navigationItem.largeTitleDisplayMode = .always
        if let navigationBar = self.navigationController?.navigationBar {
            navigationBar.prefersLargeTitles = true
            navigationBar.largeTitleTextAttributes = [
                .foregroundColor: UIColor.white
            ]
        }
      
        showNavigationBar()
    }
    
    private func subscribe() {
       globalPublisher
            .sink { _ in
                self.countWinLabel.text = self.checkWinCount()
                self.balanceLabel.text = "$" + self.checkBalance()
                self.checkArr()
                print("save home")
            }
            .store(in: &cancellable)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 12/255, green: 19/255, blue: 53/255, alpha: 1)
       
        setupUI()
        checkProfile()
        checkArr()
        subscribe()
    }
    
    private func checkProfile() {
        profileData = loadDataClass.loadProfileFromFile() ?? nil
        if let profile = profileData {
            imageViewProfile.image = UIImage(data: profile.image)
            nameProfile.text = "Hi, " + profile.name + "!"
        }
    }

    
    private func setupUI() {
        
        let homeLabel = UILabel()
        homeLabel.text = "Home"
        homeLabel.textColor = .white
        homeLabel.font = .systemFont(ofSize: 34, weight: .bold)
        view.addSubview(homeLabel)
        homeLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(-5)
        }
        
        let topView = UIView()
        topView.backgroundColor = .white.withAlphaComponent(0.05)
        topView.layer.cornerRadius = 20
        view.addSubview(topView)
        topView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(84)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        topView.addSubview(imageViewProfile)
        imageViewProfile.snp.makeConstraints { make in
            make.height.width.equalTo(52)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(15)
        }
        
        topView.addSubview(nameProfile)
        nameProfile.snp.makeConstraints { make in
            make.left.equalTo(imageViewProfile.snp.right).inset(-10)
            make.top.equalTo(imageViewProfile.snp.top).inset(3)
        }
        
        let niceLabel = UILabel()
        niceLabel.text = "Have a nice day :)"
        niceLabel.font = .systemFont(ofSize: 17, weight: .regular)
        niceLabel.textColor = .white.withAlphaComponent(0.7)
        topView.addSubview(niceLabel)
        niceLabel.snp.makeConstraints { make in
            make.left.equalTo(imageViewProfile.snp.right).inset(-10)
            make.bottom.equalTo(imageViewProfile.snp.bottom).inset(3)
        }
        
        let editProfileButton = UIButton(type: .system)
        editProfileButton.setBackgroundImage(.editProfile, for: .normal)
        topView.addSubview(editProfileButton)
        editProfileButton.snp.makeConstraints { make in
            make.height.width.equalTo(40)
            make.right.equalToSuperview().inset(15)
            make.centerY.equalToSuperview()
        }
        editProfileButton.tapPublisher
            .sink { _ in
                self.editProfile()
            }
            .store(in: &cancellable)
        
     
        
        let hideKBGesture = UITapGestureRecognizer(target: self, action: nil)
        view.addGestureRecognizer(hideKBGesture)
        hideKBGesture.tapPublisher
            .sink { _ in
                self.view.endEditing(true)
            }
            .store(in: &cancellable)
        
        editProfileView.cancelButton.tapPublisher
            .sink { _ in
                self.view.endEditing(true)
                UIView.animate(withDuration: 0.3) {
                    self.editProfileView.alpha = 0
                }
            }
            .store(in: &cancellable)
            
        editProfileView.saveButton.tapPublisher
            .sink { _ in
                self.saveProfile()
            }
            .store(in: &cancellable)
        
        let balanceView = UIView()
        balanceView.backgroundColor = .white.withAlphaComponent(0.05)
        balanceView.layer.cornerRadius = 20
        view.addSubview(balanceView)
        balanceView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(topView.snp.bottom).inset(-10)
            make.height.equalTo(114)
        }
        
        let balance = UILabel()
        balance.text = "Balance"
        balance.font = .systemFont(ofSize: 17, weight: .regular)
        balance.textColor = UIColor(red: 175/255, green: 218/255, blue: 18/255, alpha: 1)
        balanceView.addSubview(balance)
        balance.snp.makeConstraints { make in
            make.left.top.equalToSuperview().inset(15)
        }
        
        balanceLabel.text = "$" + checkBalance()
        balanceLabel.font = .systemFont(ofSize: 28, weight: .bold)
        balanceLabel.textColor = .white
        balanceLabel.textAlignment = .left
        balanceView.addSubview(balanceLabel)
        balanceLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.centerY.equalToSuperview()
        }
        
        countWinLabel.text = checkWinCount()
        countWinLabel.textColor = .white
        countWinLabel.font = .systemFont(ofSize: 15, weight: .regular)
        balanceView.addSubview(countWinLabel)
        countWinLabel.snp.makeConstraints { make in
            make.bottom.left.equalToSuperview().inset(15)
        }
        
        let dopLabel = UILabel()
        dopLabel.text = "winning bets"
        dopLabel.textColor = .white.withAlphaComponent(0.7)
        dopLabel.font = .systemFont(ofSize: 15, weight: .regular)
        balanceView.addSubview(dopLabel)
        dopLabel.snp.makeConstraints { make in
            make.centerY.equalTo(countWinLabel)
            make.left.equalTo(countWinLabel.snp.right).inset(-3)
        }
        
        let bidsLabel = UILabel()
        bidsLabel.text = "Bids"
        bidsLabel.textColor = .white
        bidsLabel.font = .systemFont(ofSize: 28, weight: .bold)
        view.addSubview(bidsLabel)
        bidsLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.top.equalTo(balanceView.snp.bottom).inset(-15)
        }
        
        openAllBidsButton.setBackgroundImage(.openBids, for: .normal)
        view.addSubview(openAllBidsButton)
        openAllBidsButton.snp.makeConstraints { make in
            make.height.width.equalTo(17)
            make.right.equalToSuperview().inset(15)
            make.centerY.equalTo(bidsLabel)
        }
        openAllBidsButton.tapPublisher
            .sink { _ in
                self.navigationController?.pushViewController(BidsAllViewController(), animated: true)
            }
            .store(in: &cancellable)
        
        collection = {
            let layout = UICollectionViewFlowLayout()
            let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
            layout.scrollDirection = .vertical
            collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "1")
            collection.backgroundColor = .clear
            collection.delegate = self
            collection.dataSource = self
            collection.showsVerticalScrollIndicator = false
            collection.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
            return collection
        }()
        view.addSubview(collection!)
        collection?.snp.makeConstraints({ make in
            make.left.right.equalToSuperview().inset(15)
            make.bottom.equalToSuperview()
            make.top.equalTo(bidsLabel.snp.bottom).inset(-10)
        })
        
        nilArrView = {
            let view = UIView()
            view.backgroundColor = .white.withAlphaComponent(0.05)
            view.layer.cornerRadius = 20
            let imageView = UIImageView(image: .nilArr)
            view.addSubview(imageView)
            imageView.snp.makeConstraints { make in
                make.height.width.equalTo(70)
                make.left.equalToSuperview().inset(15)
                make.centerY.equalToSuperview()
            }
            
            let emptyLabel = UILabel()
            emptyLabel.text = "Empty"
            emptyLabel.textColor = .white
            emptyLabel.font = .systemFont(ofSize: 28, weight: .bold)
            view.addSubview(emptyLabel)
            emptyLabel.snp.makeConstraints { make in
                make.left.equalTo(imageView.snp.right).inset(-10)
                make.top.equalTo(imageView).inset(10)
            }
            
            let dopLabel = UILabel()
            dopLabel.text = "Your records were not found"
            dopLabel.font = .systemFont(ofSize: 13, weight: .regular)
            dopLabel.textColor = .white.withAlphaComponent(0.7)
            view.addSubview(dopLabel)
            dopLabel.snp.makeConstraints { make in
                make.left.equalTo(imageView.snp.right).inset(-10)
                make.bottom.equalTo(imageView).inset(10)
            }
            return view
        }()
        view.addSubview(nilArrView)
        nilArrView.alpha = 0
        nilArrView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(102)
            make.top.equalTo(bidsLabel.snp.bottom).inset(-10)
        }
        
        view.addSubview(editProfileView)
        editProfileView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(403)
            make.center.equalToSuperview()
        }
        editProfileView.alpha = 0
        let openChangeImageGesture = UITapGestureRecognizer(target: self, action: nil)
        editProfileView.imageView.addGestureRecognizer(openChangeImageGesture)
        openChangeImageGesture.tapPublisher
            .sink { _ in
                self.setImage()
            }
            .store(in: &cancellable)
    }
    
    //СДЕЛАТЬ ЭКРАН ДОБАВЛЕНИЯ НОВОГО ЕВЕНТА И ИХ ПРОСМОТР РЕДАКТИРОВАНИ 
    
    private func checkBalance() -> String {
        var balance = 0.00
        for i in eventsArr {
            for item in i.bids {
                if item.rezult == true {
                    let coeff: Double = Double(item.cofficent) ?? 1
                    let stavka: Double = Double(item.stavka) ?? 1
                    balance += stavka * coeff
                }
            }
        }
        return String(format: "%.2f", balance)
    }

    
    private func checkWinCount() -> String {
        var wins = 0
        for i in eventsArr {
            for item in i.bids {
                if item.rezult == true {
                    wins += 1
                }
            }
        }
        return "\(wins)"
    }
    
    private func checkArr() {
        
        mainArr.removeAll()
        
        for i in eventsArr {
            if i.bids.count > 0 {
                for bid in i.bids {
                    mainArr.append((i, bid))
                }
            }
        }
        
        
        
        if mainArr.count > 0 {
            nilArrView.alpha = 0
            collection?.alpha = 100
            openAllBidsButton.alpha = 100
        } else {
            nilArrView.alpha = 100
            collection?.alpha = 0
            openAllBidsButton.alpha = 0
        }
        
        self.collection?.reloadData()
    }
  
    
    private func editProfile() {
        editProfileView.saveButton.alpha = 0.5
        editProfileView.saveButton.isEnabled = false
        self.editProfileView.alpha = 100
        editProfileView.imageView.image = UIImage(data: profileData?.image ?? Data())
        editProfileView.nameTextField.text = profileData?.name
    }
    
    @objc func setImage() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = false
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let pickedImage = info[.originalImage] as? UIImage {
            editProfileView.imageView.image = pickedImage
            editProfileView.checkSaveButton()
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    private func saveProfile() {
        let image: Data = editProfileView.imageView.image?.jpegData(compressionQuality: 0) ?? Data()
        let name: String = editProfileView.nameTextField.text ?? ""
        
        let profile = Profile(image: image, name: name)
        
        do {
            let data = try JSONEncoder().encode(profile) //тут мкассив конвертируем в дату
            try loadDataClass.saveProfileToFile(data: data)
            imageViewProfile.image = UIImage(data: image)
            nameProfile.text = "Hi, " + name + "!"
            self.profileData = profile
            UIView.animate(withDuration: 0.3) {
                self.editProfileView.alpha = 0
            }
        } catch {
            print("Failed to encode or save athleteArr: \(error)")
        }
    }
    
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mainArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "1", for: indexPath)
        cell.subviews.forEach { $0.removeFromSuperview() }
        cell.layer.cornerRadius = 20
        cell.backgroundColor = .white.withAlphaComponent(0.05)
        
        let coeffView = UIView()
        coeffView.backgroundColor = .white.withAlphaComponent(0.05)
        coeffView.layer.cornerRadius = 12
        cell.addSubview(coeffView)
        coeffView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.height.equalTo(77)
            make.width.equalTo(92)
            make.centerY.equalToSuperview()
        }
        
        let coeffLabel = UILabel()
        coeffLabel.text = mainArr[indexPath.row].1.cofficent
        coeffLabel.textColor = UIColor(red: 175/255, green: 218/255, blue: 18/255, alpha: 1)
        coeffLabel.textAlignment = .center
        coeffLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        coeffView.addSubview(coeffLabel)
        coeffLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.centerY.equalToSuperview().offset(-5)
        }
        
        let typeGameLabel = UILabel()
        typeGameLabel.text = mainArr[indexPath.row].0.cetegor
        typeGameLabel.textAlignment = .center
        typeGameLabel.textColor = .white
        typeGameLabel.font = .systemFont(ofSize: 11, weight: .regular)
        coeffView.addSubview(typeGameLabel)
        typeGameLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(5)
            make.top.equalTo(coeffLabel.snp.bottom).inset(-3)
        }
        
        let nameBetLabel = UILabel()
        nameBetLabel.text = mainArr[indexPath.row].0.oneComand + " - " + mainArr[indexPath.row].0.secondComand
        nameBetLabel.textAlignment = .left
        nameBetLabel.textColor = .white
        nameBetLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        cell.addSubview(nameBetLabel)
        nameBetLabel.snp.makeConstraints { make in
            make.left.equalTo(coeffView.snp.right).inset(-10)
            make.top.equalTo(coeffView.snp.top).inset(3)
            make.right.equalToSuperview().inset(15)
        }
        
        let nameBidLabel = UILabel()
        nameBidLabel.text = mainArr[indexPath.row].1.nameStavka
        nameBidLabel.textAlignment = .left
        nameBidLabel.textColor = UIColor(red: 175/255, green: 218/255, blue: 18/255, alpha: 1)
        nameBidLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        cell.addSubview(nameBidLabel)
        nameBidLabel.snp.makeConstraints { make in
            make.left.equalTo(coeffView.snp.right).inset(-10)
            make.top.equalTo(nameBetLabel.snp.bottom).inset(-2)
            make.right.equalToSuperview().inset(15)
        }
        
        let betTextLabel = StaticFunc.createLabel(text: "Bet")
        cell.addSubview(betTextLabel)
        betTextLabel.snp.makeConstraints { make in
            make.left.equalTo(coeffView.snp.right).inset(-10)
            make.top.equalTo(nameBidLabel.snp.bottom).inset(-2)
        }
        
        let betLabel = UILabel()
        betLabel.text = "$ " + mainArr[indexPath.row].1.stavka
        betLabel.textColor = .white
        betLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        betLabel.textAlignment = .left
        //betLabel.backgroundColor = .red
        cell.addSubview(betLabel)
        betLabel.snp.makeConstraints { make in
            make.top.equalTo(betTextLabel.snp.bottom).inset(-2)
            make.left.equalTo(coeffView.snp.right).inset(-10)
            make.right.equalTo(cell.snp.centerX).offset(30)
        }
        
        let resultLabel = StaticFunc.createLabel(text: "Result")
        cell.addSubview(resultLabel)
        resultLabel.snp.makeConstraints { make in
            make.top.equalTo(nameBidLabel.snp.bottom).inset(-2)
            make.left.equalTo(cell.snp.centerX).offset(35)
        }
        
        let resultBetLabel = UILabel()
        resultBetLabel.textAlignment = .left
        resultBetLabel.textColor = .white
        resultBetLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        
        let betDouble: Double = Double(mainArr[indexPath.row].1.stavka) ?? 1.1
        let coeffDouble: Double = Double(mainArr[indexPath.row].1.cofficent) ?? 1.1
        
        let balance = betDouble * coeffDouble
        
        resultBetLabel.text = "$ " + String(format: "%.2f", balance)
        cell.addSubview(resultBetLabel)
        resultBetLabel.snp.makeConstraints { make in
            make.left.equalTo(resultLabel)
            make.top.equalTo(resultLabel.snp.bottom).inset(-2)
            make.right.equalToSuperview().inset(15)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 109)
    }
}

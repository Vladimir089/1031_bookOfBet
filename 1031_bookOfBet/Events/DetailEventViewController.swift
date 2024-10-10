//
//  DetailEventViewController.swift
//  1031_bookOfBet
//
//  Created by Владимир Кацап on 08.10.2024.
//

import UIKit
import Combine
import CombineCocoa

class DetailEventViewController: UIViewController {
    
    var index = 0
    private lazy var cancellable = [AnyCancellable]()
    
    //UI
    private lazy var nameLabel = UILabel()
    private lazy var dateLabel = UILabel()
    private lazy var timeLabel = UILabel()
    private lazy var typeButton = UIButton()
    
    //collections
    private var mainCollection: UICollectionView?
    private var bidsCollection: UICollectionView?
    private var notesCollection: UICollectionView?
    
    //other
    private var newNoteView = NewNoteView()
    private var isLocal = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.tintColor = UIColor(red: 175/255, green: 218/255, blue: 18/255, alpha: 1)
        self.navigationItem.largeTitleDisplayMode = .never
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 12/255, green: 19/255, blue: 53/255, alpha: 1)
        subscribe()
        setupUI()
        newNoteView.saveButton.addTarget(self, action: #selector(saveNote), for: .touchUpInside)
        newNoteView.delButton.addTarget(self, action: #selector(delNote), for: .touchUpInside)
    }
    
    @objc func delNote() {
        eventsArr[index].notes.remove(at:newNoteView.index)
        newNoteView.close()
        save()
        
        do {
            let data = try JSONEncoder().encode(eventsArr) //тут мкассив конвертируем в дату
            try saveEventArrToFile(data: data)
           
            globalPublisher.send(0)
        } catch {
            print("Failed to encode or save athleteArr: \(error)")
        }
        
    }
    
    @objc func saveNote() {
        if newNoteView.isEdit == true{
            let newNote = newNoteView.createNew()
            eventsArr[index].notes[newNoteView.index] = newNote
            newNoteView.close()
        } else {
            let newNote = newNoteView.createNew()
            eventsArr[index].notes.append(newNote)
            newNoteView.close()
        }
        
        save()
    }
    
    private func save() {
        do {
            let data = try JSONEncoder().encode(eventsArr) //тут мкассив конвертируем в дату
            try saveEventArrToFile(data: data)
           
            globalPublisher.send(0)
        } catch {
            print("Failed to encode or save athleteArr: \(error)")
        }
    }
    
    
    func saveEventArrToFile(data: Data) throws {
        let fileManager = FileManager.default
        if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filePath = documentDirectory.appendingPathComponent("event.plist")
            try data.write(to: filePath)
        } else {
            throw NSError(domain: "SaveError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to get document directory"])
        }
    }
    
    private func subscribe() {
        
        globalPublisher
            .sink { _ in
                print("isLocal before: \(self.isLocal)") // Отслеживаем текущее значение
                if self.isLocal == false {
                    print("Calling update()")
                    self.update()
                } else {
                    print("Skipping update, resetting isLocal")
                    self.isLocal = false
                }
                print("isLocal after: \(self.isLocal)")
            }
            .store(in: &cancellable)



    }
    
    @objc func delEvent() {
        isLocal = true
        cancellable.removeAll()
        eventsArr.remove(at: index)
        index = 0
        self.save()
        
        self.navigationController?.popViewController(animated: true)
    }
    
    private func update() {
        if isLocal == false {
            guard index >= 0 && index < eventsArr.count else {
                return
            }
            if isLocal == false {
                nameLabel.text = eventsArr[index].oneComand + " - " + eventsArr[index].secondComand
                dateLabel.text = formatDate(date: eventsArr[index].date)
                timeLabel.text = eventsArr[index].time
                typeButton.setTitle(eventsArr[index].cetegor, for: .normal)
                notesCollection?.reloadData()
                bidsCollection?.reloadData()
                mainCollection?.reloadData()
                

                self.view.layoutIfNeeded()
            }
           
        }
    }
    
    @objc func editEvent() {
        print(index)
        let vc = AddNewEventViewController()
        vc.isNew = false
        vc.index = index
        self.present(vc, animated: true)
    }

    
    @objc func createNewNote() {
        newNoteView.isEdit = false
        newNoteView.snp.updateConstraints({ make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(440)
            make.center.equalToSuperview()
        })
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.3) {
            self.newNoteView.alpha = 1
        }
        
    }
    
    private func setupUI() {
        nameLabel.text = eventsArr[index].oneComand + " - " + eventsArr[index].secondComand
        nameLabel.textColor = .white
        nameLabel.textAlignment = .left
        nameLabel.font = .systemFont(ofSize: 34, weight: .bold)
        view.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        let infoView = UIView()
        infoView.backgroundColor = .white.withAlphaComponent(0.05)
        infoView.layer.cornerRadius = 20
        view.addSubview(infoView)
        infoView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(44)
            make.top.equalTo(nameLabel.snp.bottom).inset(-10)
        }
        
        let calendarImageView = UIImageView(image: .calendar)
        infoView.addSubview(calendarImageView)
        calendarImageView.snp.makeConstraints { make in
            make.height.width.equalTo(20)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(15)
        }
        
        dateLabel.text = formatDate(date: eventsArr[index].date)
        dateLabel.textColor = .white.withAlphaComponent(0.7)
        dateLabel.font = .systemFont(ofSize: 13, weight: .regular)
        infoView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.left.equalTo(calendarImageView.snp.right).inset(-10)
            make.centerY.equalToSuperview()
        }
        
        let timeImageView = UIImageView(image: .clock)
        infoView.addSubview(timeImageView)
        timeImageView.snp.makeConstraints { make in
            make.height.width.equalTo(20)
            make.left.equalTo(dateLabel.snp.right).inset(-15)
            make.centerY.equalToSuperview()
        }
        
        timeLabel.text = eventsArr[index].time
        timeLabel.textColor = .white.withAlphaComponent(0.7)
        timeLabel.font = .systemFont(ofSize: 13, weight: .regular)
        infoView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.left.equalTo(timeImageView.snp.right).inset(-10)
            make.centerY.equalToSuperview()
        }
        
        typeButton.setTitle(eventsArr[index].cetegor, for: .normal)
        typeButton.backgroundColor = .white.withAlphaComponent(0.05)
        typeButton.setTitleColor(.white.withAlphaComponent(0.2), for: .normal)
        typeButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        typeButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        typeButton.layer.cornerRadius = 18
        view.addSubview(typeButton)
        typeButton.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.height.equalTo(36)
            make.top.equalTo(infoView.snp.bottom).inset(-10)
        }
        
        mainCollection = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "1")
            collection.showsVerticalScrollIndicator = false
            collection.delegate = self
            collection.backgroundColor = .clear
            collection.dataSource = self
            collection.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0)
            return collection
        }()

        view.addSubview(mainCollection!)
        mainCollection?.snp.makeConstraints({ make in
            make.left.right.equalToSuperview().inset(15)
            make.bottom.equalToSuperview()
            make.top.equalTo(typeButton.snp.bottom).inset(-10)
        })
        
        newNoteView.alpha = 0
        view.addSubview(newNoteView)
        newNoteView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(437)
            make.center.equalToSuperview()
        }
        
        let hideKBGesture = UITapGestureRecognizer(target: self, action: nil)
        view.addGestureRecognizer(hideKBGesture)
        hideKBGesture.tapPublisher
            .sink { _ in
                self.view.endEditing(true)
            }
            .store(in: &cancellable)
        
        let delButton = UIButton(type: .system)
        delButton.setTitle("Delete", for: .normal)
        delButton.backgroundColor = .white.withAlphaComponent(0.05)
        delButton.layer.cornerRadius = 12
        delButton.setTitleColor(.white, for: .normal)
        delButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        view.addSubview(delButton)
        delButton.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(10)
            make.height.equalTo(50)
            make.right.equalTo(view.snp.centerX).offset(-7.5)
        }
        delButton.addTarget(self, action: #selector(delEvent), for: .touchUpInside)
           
        
        let editButton = UIButton(type: .system)
        editButton.backgroundColor = UIColor(red: 175/255, green: 218/255, blue: 18/255, alpha: 1)
        editButton.layer.cornerRadius = 12
        editButton.setTitleColor(.white, for: .normal)
        editButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        editButton.setTitle("Edit", for: .normal)
        view.addSubview(editButton)
        editButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(15)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(10)
            make.height.equalTo(50)
            make.left.equalTo(view.snp.centerX).offset(7.5)
        }
        editButton.addTarget(self, action: #selector(editEvent), for: .touchUpInside)
        
        notesCollection = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "3")
            collection.showsVerticalScrollIndicator = false
            collection.delegate = self
            collection.backgroundColor = .clear
            collection.dataSource = self
            return collection
        }()
        
        bidsCollection = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "2")
            collection.showsVerticalScrollIndicator = false
            collection.delegate = self
            collection.backgroundColor = .clear
            collection.dataSource = self
            return collection
        }()
    }
    
    
    
    private func formatDate(date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: date) {
            dateFormatter.dateFormat = "MMMM dd, yyyy"
            return dateFormatter.string(from: date)
        } else {
            return "Invalid date"
        }
    }
    
    @objc func editNote(sender: UIButton) {
        newNoteView.isEdit = true
        newNoteView.delButton.alpha = 1
        newNoteView.index = sender.tag
        newNoteView.indexEvent = index
        newNoteView.edit()
        newNoteView.snp.updateConstraints({ make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(460)
            make.center.equalToSuperview()
        })
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.3) {
            self.newNoteView.alpha = 1
        }
    }

}


extension DetailEventViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == mainCollection {
            return 2
        } else if collectionView == bidsCollection {
            return eventsArr[index].bids.count > 0 ? eventsArr[index].bids.count : 1
        } else {
            return eventsArr[index].notes.count > 0 ? eventsArr[index].notes.count : 1
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == mainCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "1", for: indexPath)
            cell.subviews.forEach { $0.removeFromSuperview() }
            cell.backgroundColor = .clear
            
            let bidsLabel = UILabel()
            bidsLabel.text = indexPath.row == 0 ? "Bids" : "Notes"
            bidsLabel.textColor = .white
            bidsLabel.font = .systemFont(ofSize: 28, weight: .bold)
            bidsLabel.numberOfLines = 0 // Установите это, чтобы текст переносился
            cell.addSubview(bidsLabel)
            bidsLabel.snp.makeConstraints { make in
                make.left.top.equalToSuperview()
            }
            
            if indexPath.row == 1 {
                let button = UIButton(type: .system)
                button.setBackgroundImage(.addNote, for: .normal)
                cell.addSubview(button)
                button.snp.makeConstraints { make in
                    make.height.width.equalTo(24)
                    make.right.equalToSuperview()
                    make.centerY.equalTo(bidsLabel)
                }
                button.addTarget(self, action: #selector(createNewNote), for: .touchUpInside)
            }
           
            if indexPath.row == 0 {
                
                cell.addSubview(bidsCollection!)
                bidsCollection?.snp.makeConstraints({ make in
                    make.left.right.equalToSuperview()
                    make.bottom.equalToSuperview()
                    make.top.equalTo(bidsLabel.snp.bottom).inset(-10)
                })
            } else {
               
                cell.addSubview(notesCollection!)
                notesCollection?.snp.makeConstraints({ make in
                    make.left.right.equalToSuperview()
                    make.bottom.equalToSuperview()
                    make.top.equalTo(bidsLabel.snp.bottom).inset(-10)
                })
            }
            return cell
        } else if collectionView == bidsCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "2", for: indexPath)
            cell.subviews.forEach { $0.removeFromSuperview() }
            cell.backgroundColor = .white.withAlphaComponent(0.05)
            cell.layer.cornerRadius = 20
            
            if eventsArr[index].bids.count > 0 {
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
                coeffLabel.text = eventsArr[index].bids[indexPath.row].cofficent
                coeffLabel.textColor = UIColor(red: 175/255, green: 218/255, blue: 18/255, alpha: 1)
                coeffLabel.textAlignment = .center
                coeffLabel.font = .systemFont(ofSize: 20, weight: .semibold)
                coeffView.addSubview(coeffLabel)
                coeffLabel.snp.makeConstraints { make in
                    make.left.right.equalToSuperview().inset(15)
                    make.centerY.equalToSuperview().offset(-5)
                }
                
                let typeGameLabel = UILabel()
                typeGameLabel.text = eventsArr[index].cetegor
                typeGameLabel.textAlignment = .center
                typeGameLabel.textColor = .white
                typeGameLabel.font = .systemFont(ofSize: 11, weight: .regular)
                coeffView.addSubview(typeGameLabel)
                typeGameLabel.snp.makeConstraints { make in
                    make.left.right.equalToSuperview().inset(5)
                    make.top.equalTo(coeffLabel.snp.bottom).inset(-3)
                }
                
                let nameBetLabel = UILabel()
                nameBetLabel.text = eventsArr[index].oneComand + " - " + eventsArr[index].secondComand
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
                nameBidLabel.text = eventsArr[index].bids[indexPath.row].nameStavka
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
                betLabel.text = "$ " + eventsArr[index].bids[indexPath.row].stavka
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
                
                let betDouble: Double = Double(eventsArr[index].bids[indexPath.row].stavka) ?? 1.1
                let coeffDouble: Double = Double(eventsArr[index].bids[indexPath.row].cofficent) ?? 1.1
                
                let balance = betDouble * coeffDouble
                
                resultBetLabel.text = "$ " + String(format: "%.2f", balance)
                cell.addSubview(resultBetLabel)
                resultBetLabel.snp.makeConstraints { make in
                    make.left.equalTo(resultLabel)
                    make.top.equalTo(resultLabel.snp.bottom).inset(-2)
                    make.right.equalToSuperview().inset(15)
                }
                
            } else {
                let nilArrView = {
                    let view = UIView()
                    view.backgroundColor = .clear
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
                cell.addSubview(nilArrView)
                nilArrView.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
            }
            
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "3", for: indexPath)
            cell.subviews.forEach { $0.removeFromSuperview() }
            cell.backgroundColor = .white.withAlphaComponent(0.05)
            cell.layer.cornerRadius = 20
            if eventsArr[index].notes.count > 0 {
                cell.backgroundColor = UIColor(red: 12/255, green: 19/255, blue: 53/255, alpha: 1)
                let mainView = UIView()
                mainView.backgroundColor = .white.withAlphaComponent(0.05)
                mainView.layer.cornerRadius = 24
                cell.addSubview(mainView)
                mainView.snp.makeConstraints { make in
                    make.left.top.bottom.equalToSuperview()
                    make.right.equalToSuperview().inset(44)
                }
                let titleLabel = UILabel()
                titleLabel.text = eventsArr[index].notes[indexPath.row].title
                titleLabel.textColor = .white
                titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
                titleLabel.textAlignment = .left
                mainView.addSubview(titleLabel)
                titleLabel.snp.makeConstraints { make in
                    make.left.right.equalToSuperview().inset(10)
                    make.top.equalToSuperview().inset(10)
                }
                
                let desklabel = UILabel()
                desklabel.textColor = .white.withAlphaComponent(0.7)
                desklabel.font = .systemFont(ofSize: 15, weight: .regular)
                desklabel.textAlignment = .left
                desklabel.numberOfLines = 0
                desklabel.text = eventsArr[index].notes[indexPath.row].description
                mainView.addSubview(desklabel)
                desklabel.snp.makeConstraints { make in
                    make.left.right.equalToSuperview().inset(10)
                    make.top.equalToSuperview().inset(30)
                    make.bottom.equalToSuperview().inset(10)
                }
                
                let editNoteButton = UIButton(type: .system)
                editNoteButton.backgroundColor = UIColor(red: 175/255, green: 218/55, blue: 18/255, alpha: 1)
                editNoteButton.layer.cornerRadius = 16
                let imageViewEdit = UIImageView(image: .editNote)
                editNoteButton.addSubview(imageViewEdit)
                imageViewEdit.snp.makeConstraints { make in
                    make.center.equalToSuperview()
                    make.height.width.equalTo(24)
                }
                cell.addSubview(editNoteButton)
                editNoteButton.snp.makeConstraints { make in
                    make.right.equalToSuperview()
                    make.width.equalTo(34)
                    make.top.bottom.equalToSuperview()
                }
                editNoteButton.tag = indexPath.row
                editNoteButton.addTarget(self, action: #selector(editNote(sender:)), for: .touchUpInside)
                
            } else {
                let nilArrView = {
                    let view = UIView()
                    view.backgroundColor = .clear
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
                cell.addSubview(nilArrView)
                nilArrView.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
            }
            
            
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == mainCollection {
            if indexPath.row == 0 {
                return CGSize(width: collectionView.bounds.width, height: eventsArr[index].bids.count > 0 ? CGFloat((eventsArr[index].bids.count * 120 + 50)) : 155)
            } else {
                return CGSize(width: collectionView.bounds.width, height: eventsArr[index].notes.count > 0 ? CGFloat((eventsArr[index].notes.count * 120 + 50)) : 155)
            }
        } else if collectionView == bidsCollection {
            return CGSize(width: collectionView.bounds.width, height: 109)
        } else {
            return CGSize(width: collectionView.bounds.width, height: 109)
        }
    }

    
}

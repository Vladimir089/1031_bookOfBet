//
//  EventsViewController.swift
//  1031_bookOfBet
//
//  Created by Владимир Кацап on 08.10.2024.
//

import UIKit
import Combine
import CombineCocoa

class EventsViewController: UIViewController {
    
    private lazy var cancellable = [AnyCancellable]()
    
    //type collection
    private let typesArr = ["All", "Football", "Basketball", "Tennis", "Hockey", "Baseball", "Volleyball", "Handball", "Esports", "Table tennis"]
    private lazy var selectedType = "All"
    private var typeCollection: UICollectionView?
    
    //dateCollection
    private var dateCollection: UICollectionView?
    private lazy var selectedDate = getTodayDate()
    private lazy var datesArr = getFormattedDatesForCurrentMonth()
    
    //eventCollection
    private lazy var sortedEventsArr: [Event] = eventsArr
    private var eventCollection: UICollectionView?
    
    //other
    private lazy var nilArrView = UIView()
    
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 12/255, green: 19/255, blue: 53/255, alpha: 1)
        subscribe()
        setupUI()
        reloadCollections()
        let backButton = UIBarButtonItem()
        backButton.title = ""
        navigationItem.backBarButtonItem = backButton
    }
    
    private func createNewEvent() {
        let vc = AddNewEventViewController()
        self.present(vc, animated: true)
    }
    
    private func reloadCollections() {
        sortedEventsArr = []
        
        if selectedType == "All" {
            sortedEventsArr = eventsArr.filter({$0.date == selectedDate})
        } else {
            let weakArr = eventsArr.filter({$0.date == selectedDate})
            sortedEventsArr = weakArr.filter({$0.cetegor == selectedType})
        }
        checkArr()
        eventCollection?.reloadData()
    }
    
    private func subscribe() {
        globalPublisher
            .sink { _ in
                self.reloadCollections()
            }
            .store(in: &cancellable)
    }
    
    private func setupUI() {
        
        let homeLabel = UILabel()
        homeLabel.text = "Events"
        homeLabel.textColor = .white
        homeLabel.font = .systemFont(ofSize: 34, weight: .bold)
        view.addSubview(homeLabel)
        homeLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(-5)
        }
        
        
        
        typeCollection = {
            let layout = UICollectionViewFlowLayout()
            let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
            layout.scrollDirection = .horizontal
            collection.backgroundColor = .clear
            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            collection.showsHorizontalScrollIndicator = false
            collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "1")
            layout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
            collection.delegate = self
            layout.minimumLineSpacing = 5
            collection.dataSource = self
            return collection
        }()
        view.addSubview(typeCollection!)
        typeCollection?.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(36)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        dateCollection = {
            let layout = UICollectionViewFlowLayout()
            let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
            layout.scrollDirection = .horizontal
            collection.backgroundColor = .white.withAlphaComponent(0.05)
            collection.layer.cornerRadius = 20
            collection.showsHorizontalScrollIndicator = false
            collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "2")
            collection.delegate = self
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            layout.minimumLineSpacing = 5
            collection.dataSource = self
            return collection
        }()
        view.addSubview(dateCollection!)
        dateCollection?.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(100)
            make.top.equalTo(typeCollection!.snp.bottom).inset(-10)
        }
        
        let addEventButton = UIButton(type: .system)
        addEventButton.setTitle("Add an event", for: .normal)
        addEventButton.backgroundColor = .white.withAlphaComponent(0.05)
        addEventButton.layer.cornerRadius = 12
        addEventButton.setTitleColor(.white, for: .normal)
        addEventButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        view.addSubview(addEventButton)
        addEventButton.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.height.equalTo(50)
            make.right.equalTo(view.snp.centerX).offset(-5)
            make.top.equalTo(dateCollection!.snp.bottom).inset(-10)
        }
        addEventButton.tapPublisher
            .sink { _ in
                self.createNewEvent()
            }
            .store(in: &cancellable)
        
        let addBidButton = UIButton(type: .system)
        addBidButton.setTitle("Add a bid", for: .normal)
        addBidButton.backgroundColor = UIColor(red: 175/255, green: 218/255, blue: 18/255, alpha: 1)
        addBidButton.layer.cornerRadius = 12
        addBidButton.setTitleColor(.white, for: .normal)
        addBidButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        view.addSubview(addBidButton)
        addBidButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(15)
            make.height.equalTo(50)
            make.left.equalTo(view.snp.centerX).offset(5)
            make.top.equalTo(dateCollection!.snp.bottom).inset(-10)
        }
        
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
            make.top.equalTo(addBidButton.snp.bottom).inset(-10)
        }
        
        eventCollection = {
            let layout = UICollectionViewFlowLayout()
            let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
            layout.scrollDirection = .vertical
            collection.backgroundColor = .clear
            collection.showsHorizontalScrollIndicator = false
            collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "3")
            collection.delegate = self
            collection.showsVerticalScrollIndicator = false
            layout.minimumLineSpacing = 5
            collection.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0)
            collection.dataSource = self
            return collection
        }()
        view.addSubview(eventCollection!)
        eventCollection?.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(addBidButton.snp.bottom).inset(-10)
            make.bottom.equalToSuperview()
        }
    }
    
    private func checkArr() {
        if sortedEventsArr.count > 0 {
            nilArrView.alpha = 0
            eventCollection?.alpha = 1
        } else {
            nilArrView.alpha = 1
            eventCollection?.alpha = 0
        }
    }
    
    private func getFormattedDatesForCurrentMonth() -> [String] {
        let calendar = Calendar.current
        let currentDate = Date()
        guard let range = calendar.range(of: .day, in: .month, for: currentDate),
              let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate)) else {
            return []
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        var formattedDates: [String] = []
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                let formattedDate = dateFormatter.string(from: date)
                formattedDates.append(formattedDate)  // Добавляем отформатированную дату в массив
            }
        }
        
        return formattedDates
    }
    
    private func getTodayDate() -> String {
        let dateFormatterInput = DateFormatter()
        dateFormatterInput.dateFormat = "yyyy-MM-dd"
        return dateFormatterInput.string(from: Date())
    }
}


extension EventsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == typeCollection {
            return typesArr.count
        } else if collectionView == dateCollection {
            return datesArr.count
        } else {
            return sortedEventsArr.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == typeCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "1", for: indexPath)
            cell.subviews.forEach { $0.removeFromSuperview() }
            let item = typesArr[indexPath.row]
            
            cell.layer.cornerRadius = 20
            cell.backgroundColor = item == selectedType ? UIColor(red: 175/255, green: 218/255, blue: 18/255, alpha: 1) : .white.withAlphaComponent(0.05)
            
            let button = UIButton(type: .system)
            button.setTitle(item, for: .normal)
            button.setTitleColor(item == selectedType ? .white : .white.withAlphaComponent(0.2), for: .normal)
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
            button.layer.cornerRadius = 18
            button.isEnabled = false
            button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
            cell.addSubview(button)
            button.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.left.right.equalToSuperview()
                make.height.equalTo(36)
            }
            
            return cell
        } else if collectionView == dateCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "2", for: indexPath)
            cell.subviews.forEach { $0.removeFromSuperview() }
            let item = datesArr[indexPath.row]
            
            let dateFormatterInput = DateFormatter()
            dateFormatterInput.dateFormat = "yyyy-MM-dd"
            let date = dateFormatterInput.date(from: item)
            
            let dateFormatterDay = DateFormatter()
            dateFormatterDay.dateFormat = "E"
            let topLabel = UILabel()
            topLabel.text = dateFormatterDay.string(from: date ?? Date()).uppercased()
            topLabel.textColor = .white.withAlphaComponent(0.7)
            topLabel.font = .systemFont(ofSize: 13, weight: .semibold)
            cell.addSubview(topLabel)
            topLabel.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().inset(15)
            }
            
            let dateFormarmatterCount = DateFormatter()
            dateFormarmatterCount.dateFormat = "d"
            
            let dateButton = UIButton()
            dateButton.backgroundColor = selectedDate == item ? UIColor(red: 175/255, green: 218/255, blue: 18/255, alpha: 1) : .clear
            dateButton.layer.cornerRadius = 22
            dateButton.setTitle(dateFormarmatterCount.string(from: date ?? Date()).uppercased(), for: .normal)
            dateButton.isEnabled = false
            dateButton.titleLabel?.font = .systemFont(ofSize: 24, weight: .semibold)
            cell.addSubview(dateButton)
            dateButton.snp.makeConstraints { make in
                make.height.width.equalTo(44)
                make.bottom.equalToSuperview().inset(15)
            }
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "3", for: indexPath)
            cell.subviews.forEach { $0.removeFromSuperview() }
            let item = sortedEventsArr[indexPath.row]
            cell.backgroundColor = .white.withAlphaComponent(0.05)
            cell.layer.cornerRadius = 20
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            let dateLabel = UILabel()
            
            if let date = dateFormatter.date(from: item.date) {
                dateFormatter.dateFormat = "MMMM dd, yyyy"
                dateLabel.text = dateFormatter.string(from: date)
            } else {
                dateLabel.text = "Invalid date"
            }
            
            dateLabel.textColor = .white
            dateLabel.font = .systemFont(ofSize: 13, weight: .bold)
            cell.addSubview(dateLabel)
            dateLabel.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().inset(15)
            }
            
            let dateFormatterTime = DateFormatter()
            dateFormatterTime.dateFormat = "hh:mm a"
            
            
            let timeButton = UIButton()
            timeButton.backgroundColor = .white.withAlphaComponent(0.05)
            timeButton.layer.cornerRadius = 8
            timeButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
            timeButton.setTitleColor(.white, for: .normal)
            timeButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
            if let date = dateFormatterTime.date(from: item.time) {
                dateFormatterTime.dateFormat = "HH:mm"
                let militaryTimeString = dateFormatterTime.string(from: date)
                timeButton.setTitle(militaryTimeString, for: .normal)
            }
            cell.addSubview(timeButton)
            timeButton.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(dateLabel.snp.bottom).inset(-10)
                make.height.equalTo(30)
            }
            
            let firstLabel = UILabel()
            firstLabel.text = item.oneComand
            firstLabel.textAlignment = .center
            firstLabel.textColor = .white
            firstLabel.font = .systemFont(ofSize: 17, weight: .bold)
            cell.addSubview(firstLabel)
            firstLabel.snp.makeConstraints { make in
                make.centerY.equalTo(timeButton.snp.centerY)
                make.left.equalToSuperview().inset(15)
                make.right.equalTo(cell.snp.centerX).offset(-40)
            }
            
            let secondLabel = UILabel()
            secondLabel.text = item.secondComand
            secondLabel.textAlignment = .center
            secondLabel.textColor = .white
            secondLabel.font = .systemFont(ofSize: 17, weight: .bold)
            cell.addSubview(secondLabel)
            secondLabel.snp.makeConstraints { make in
                make.centerY.equalTo(timeButton.snp.centerY)
                make.right.equalToSuperview().inset(15)
                make.left.equalTo(cell.snp.centerX).offset(40)
            }
            
            let bidsLabel = UILabel()
            bidsLabel.textColor = UIColor(red: 175/255, green: 218/255, blue: 18/255, alpha: 1)
            bidsLabel.font = .systemFont(ofSize: 13, weight: .bold)
            bidsLabel.text = "\(item.bids.count) bids"
            cell.addSubview(bidsLabel)
            bidsLabel.snp.makeConstraints { make in
                make.top.equalTo(timeButton.snp.bottom).inset(-7)
                make.centerX.equalToSuperview()
            }
            
            let typeView = UIView()
            typeView.backgroundColor = .white.withAlphaComponent(0.05)
            typeView.layer.cornerRadius = 12
            cell.addSubview(typeView)
            typeView.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(15)
                make.top.equalTo(bidsLabel.snp.bottom).inset(-7)
                make.height.equalTo(29)
            }
            
            let typeLabel = UILabel()
            typeLabel.text = item.cetegor
            typeLabel.font = .systemFont(ofSize: 13, weight: .regular)
            typeLabel.textColor = .white
            typeView.addSubview(typeLabel)
            typeLabel.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == typeCollection {
            selectedType = typesArr[indexPath.row]
            typeCollection?.reloadData()
        }
        if collectionView == dateCollection {
            selectedDate = datesArr[indexPath.row]
            dateCollection?.reloadData()
        }
        if collectionView == eventCollection {
            let vc = DetailEventViewController()
            
            var index = 0
            for i in eventsArr {
                if i.id == sortedEventsArr[indexPath.row].id {
                    vc.index = index
                    vc.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    index += 1
                }
            }
            
           
        }
        
        reloadCollections()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == dateCollection {
            return CGSize(width: 44, height: collectionView.bounds.height)
        }
        if collectionView == eventCollection {
            return CGSize(width: collectionView.bounds.width, height: 143)
        }
        //nil
        return CGSize(width: 10, height: 10)
    }
}

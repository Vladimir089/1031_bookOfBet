//
//  AddNewBidsViewController.swift
//  1031_bookOfBet
//
//  Created by Владимир Кацап on 09.10.2024.
//

import UIKit
import Combine

class AddNewBidsViewController: UIViewController {
    
    private lazy var cancellable = [AnyCancellable]()
    
    private var selectedIndex: Int?
    
    private lazy var nextButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 12/255, green: 19/255, blue: 53/255, alpha: 1)
        title = "Add"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        setupUI()
        //subscribe()
    }
    
    private func subscribe() {
        globalPublisher
            .sink { _ in
                self.dismiss(animated: true)
            }
            .store(in: &cancellable)
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
        
        let topLabel = UILabel()
        topLabel.textColor = .white
        topLabel.font = .systemFont(ofSize: 28, weight: .bold)
        topLabel.text = "Select an event"
        view.addSubview(topLabel)
        topLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        let rightLabel = UILabel()
        rightLabel.text = "1/2"
        rightLabel.textColor = UIColor(red: 175/255, green: 218/255, blue: 18/255, alpha: 1)
        rightLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        view.addSubview(rightLabel)
        rightLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(15)
            make.centerY.equalTo(topLabel)
        }
        
        let mainVollection: UICollectionView = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collection.showsVerticalScrollIndicator = false
            collection.backgroundColor = .clear
            collection.delegate = self
            collection.dataSource = self
            collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "1")
            collection.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
            return collection
        }()
        view.addSubview(mainVollection)
        mainVollection.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(topLabel.snp.bottom).inset(-10)
            make.bottom.equalToSuperview()
        }
        
        nextButton.setTitle("Next", for: .normal)
        nextButton.layer.cornerRadius = 12
        nextButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        nextButton.isEnabled = false
        nextButton.backgroundColor = .white.withAlphaComponent(0.05)
        nextButton.setTitleColor(.white.withAlphaComponent(0.2), for: .normal)
        view.addSubview(nextButton)
        nextButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(15)
            make.height.equalTo(50)
        }
        nextButton.addTarget(self, action: #selector(nextPage), for: .touchUpInside)
        
    }
    
    @objc func nextPage() {
       let vc = EditNewBidsViewController()
        vc.isNew = true
        vc.indexEvent = selectedIndex ?? 0
        self.navigationController?.pushViewController(vc, animated: true)
    }


}


extension AddNewBidsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return eventsArr.count > 0 ? eventsArr.count : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "1", for: indexPath)
        cell.subviews.forEach { $0.removeFromSuperview() }
        cell.backgroundColor = .white.withAlphaComponent(0.05)
        cell.layer.cornerRadius = 20
        
        if  eventsArr.count > 0 {
            let item = eventsArr[indexPath.row]
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            if selectedIndex == indexPath.row {
                cell.layer.borderWidth = 3
                cell.layer.borderColor = UIColor(red: 175/255, green: 218/255, blue: 18/255, alpha: 1).cgColor
            } else {
                cell.layer.borderWidth = 0
                cell.layer.borderColor = UIColor.clear.cgColor
            }
            
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
            
            let typeView = UIView()
            typeView.backgroundColor = .white.withAlphaComponent(0.05)
            typeView.layer.cornerRadius = 12
            cell.addSubview(typeView)
            typeView.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(15)
                make.top.equalTo(timeButton.snp.bottom).inset(-7)
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 121)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if eventsArr.count > 0 {
            nextButton.isEnabled = true
            nextButton.backgroundColor = UIColor(red: 175/255, green: 218/255, blue: 18/255, alpha: 1)
            nextButton.setTitleColor(.white, for: .normal)
            selectedIndex = indexPath.row
            collectionView.reloadData()
        }
    }
}

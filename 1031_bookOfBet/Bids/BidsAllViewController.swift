//
//  BidsAllViewController.swift
//  1031_bookOfBet
//
//  Created by Владимир Кацап on 10.10.2024.
//

import UIKit
import Combine
import CombineCocoa

class BidsAllViewController: UIViewController {
    
    private var cancellable = [AnyCancellable]()
    private var collection: UICollectionView?
    private lazy var segmentedControl = UISegmentedControl(items: ["Active", "Completed"])
    
    private lazy var mainArr = [(Event, Bids)]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.largeTitleDisplayMode = .never
        if let navigationBar = self.navigationController?.navigationBar {
            navigationBar.prefersLargeTitles = false
        }
        showNavigationBar()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 12/255, green: 19/255, blue: 53/255, alpha: 1)
        settingNavController()
        createIterface()
        sortArr(index: 0)
        subscribe()
    }
    
    private func subscribe() {
        globalPublisher.sink { _ in
            self.sortArr(index: self.segmentedControl.selectedSegmentIndex)
        }
        .store(in: &cancellable)
    }
    
    private func settingNavController() {
        let customBackButton = UIBarButtonItem(image: .backButton.resize(targetSize: CGSize(width: 70, height: 44)).withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(backButtonTapped))
          navigationItem.leftBarButtonItem = customBackButton
        
        let customRightButton = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(addButtonTapped))
        customRightButton.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        navigationItem.rightBarButtonItem = customRightButton
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func addButtonTapped() {
        self.present(UINavigationController(rootViewController: AddNewBidsViewController()), animated: true)
    }
    
    private func createIterface() {
        let bidsLabel = UILabel()
        bidsLabel.text = "Bids"
        bidsLabel.textColor = .white
        bidsLabel.font = .systemFont(ofSize: 34, weight: .bold)
        view.addSubview(bidsLabel)
        bidsLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
      
        let normalTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white
        ]
        segmentedControl.setTitleTextAttributes(normalTextAttributes, for: .normal)
        segmentedControl.setTitleTextAttributes(normalTextAttributes, for: .selected)
        segmentedControl.selectedSegmentTintColor = UIColor(red: 175/255, green: 218/255, blue: 18/255, alpha: 1)
        view.addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(46)
            make.top.equalTo(bidsLabel.snp.bottom).inset(-10)
        }
        
        segmentedControl.selectedSegmentIndex = 0
        
        segmentedControl.selectedSegmentIndexPublisher
            .sink { index in
                self.sortArr(index: index)
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
            make.top.equalTo(segmentedControl.snp.bottom).inset(-10)
        })
        
    }
    
    
    private func sortArr(index: Int) {
        mainArr.removeAll()
        
        if index == 0 {
            for i in eventsArr {
                if i.bids.count > 0 {
                    for bid in i.bids {
                        if bid.isCompleted == false {
                            mainArr.append((i, bid))
                        }
                    }
                }
            }
        } else {
            for i in eventsArr {
                if i.bids.count > 0 {
                    for bid in i.bids {
                        if bid.isCompleted == true {
                            mainArr.append((i, bid))
                        }
                    }
                }
            }
        }
        
        collection?.reloadData()
    }
 
    
}

extension BidsAllViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let idEvent = mainArr[indexPath.row].0.id
        let idBid = mainArr[indexPath.row].1.id
        
        let indexEvent = eventsArr.firstIndex(where: {$0.id == idEvent})
        let indexBid = mainArr[indexPath.row].0.bids.firstIndex(where: {$0.id == idBid})
        
        let vc = EditNewBidsViewController()
        vc.isNew = false
        vc.indexBids = indexBid ?? 0
        vc.indexEvent = indexEvent ?? 0
        
        self.present(UINavigationController(rootViewController: vc), animated: true)
        
    }
}

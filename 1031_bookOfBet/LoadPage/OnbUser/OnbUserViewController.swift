//
//  OnbUserViewController.swift
//  1031_bookOfBet
//
//  Created by Владимир Кацап on 07.10.2024.
//

import UIKit
import Combine
import CombineCocoa

class OnbUserViewController: UIViewController {
    
    private lazy var bgImageView = UIImageView(image: .us1)
    private lazy var topLabel = UILabel()
    private lazy var tapNumbers = 1
    private lazy var pageIndicator = UIPageControl()
    
    private lazy var cancellables = [AnyCancellable]()

    override func viewDidLoad() {
        super.viewDidLoad()
        createInterface()
    }
    

    private func createInterface() {
        view.addSubview(bgImageView)
        bgImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        topLabel.textColor = .white
        topLabel.font = .systemFont(ofSize: 34, weight: .bold)
        topLabel.textAlignment = .center
        topLabel.numberOfLines = 2
        topLabel.text = "Everything is in your\nhands!"
        view.addSubview(topLabel)
        topLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(15)
        }
        
        pageIndicator.numberOfPages = 2
        pageIndicator.currentPage = 0
        pageIndicator.currentPageIndicatorTintColor = UIColor(red: 175/255, green: 218/255, blue: 18/255, alpha: 1)
        pageIndicator.tintColor = .white.withAlphaComponent(0.2)
        pageIndicator.isUserInteractionEnabled = false
        view.addSubview(pageIndicator)
        pageIndicator.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(topLabel.snp.bottom).inset(-15)
        }
        
        
        let nextButton = UIButton(type: .system)
        nextButton.backgroundColor = UIColor(red: 175/255, green: 218/255, blue: 18/255, alpha: 1)
        nextButton.layer.cornerRadius = 12
        nextButton.setTitle("Next", for: .normal)
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.layer.shadowColor = UIColor.black.cgColor
        nextButton.layer.shadowOpacity = 0.25
        nextButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        nextButton.layer.shadowRadius = 4
        nextButton.layer.masksToBounds = false
        view.addSubview(nextButton)
        nextButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(50)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(15)
        }
        nextButton.tapPublisher
            .sink { _ in
                self.nextButtonTapped()
            }
            .store(in: &cancellables)

    }
    
    private func nextButtonTapped() {
        tapNumbers += 1
        switch tapNumbers {
        case 2:
            topLabel.text = "Taste the victory!"
            pageIndicator.currentPage = 1
            bgImageView.image = .us2
        case 3:
            self.navigationController?.setViewControllers([TabBarViewController()], animated: true)
        default:
            return
        }
        
    }
    
}

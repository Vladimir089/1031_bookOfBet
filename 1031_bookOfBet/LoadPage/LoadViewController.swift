//
//  LoadViewController.swift
//  1031_bookOfBet
//
//  Created by Владимир Кацап on 07.10.2024.
//

import UIKit
import SnapKit

class LoadViewController: UIViewController {
    
    private lazy var timer = Timer()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 12/255, green: 19/255, blue: 53/255, alpha: 1)
        createInterface()
        setupTimer()
    }
    
    private func createInterface() {
        let logImageView = UIImageView(image: .logLoad)
        view.addSubview(logImageView)
        logImageView.snp.makeConstraints { make in
            make.height.width.equalTo(200)
            make.center.equalToSuperview()
        }
        
        let loadIndicator = UIActivityIndicatorView(style: .large)
        loadIndicator.color = .white
        loadIndicator.startAnimating()
        view.addSubview(loadIndicator)
        loadIndicator.snp.makeConstraints { make in
            make.height.width.equalTo(30)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(60)
        }
        
    }
    
    private func setupTimer() {
        timer = .scheduledTimer(withTimeInterval: 7, repeats: false, block: { _ in //7
            if isBet == false {
                if UserDefaults.standard.object(forKey: "tab") != nil {
                    self.navigationController?.setViewControllers([TabBarViewController()], animated: true)
                } else {
                   self.navigationController?.setViewControllers([OnbUserViewController()], animated: true)
                }
            } else {
                if UserDefaults.standard.object(forKey: "Rew") != nil {
                   // self.navigationController?.setViewControllers([WebSiteViewController()], animated: true)
                } else {
                  // self.navigationController?.setViewControllers([OnbRewViewController()], animated: true)
                }
            }
        })
    }
    

}

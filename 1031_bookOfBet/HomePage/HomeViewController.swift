//
//  HomeViewController.swift
//  1031_bookOfBet
//
//  Created by Владимир Кацап on 07.10.2024.
//

import UIKit

class HomeViewController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Home"
        self.navigationItem.largeTitleDisplayMode = .always
        if let navigationBar = self.navigationController?.navigationBar {
            navigationBar.prefersLargeTitles = true
            navigationBar.largeTitleTextAttributes = [
                .foregroundColor: UIColor.white
            ]
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 12/255, green: 19/255, blue: 53/255, alpha: 1)
        
    }
    

    
}

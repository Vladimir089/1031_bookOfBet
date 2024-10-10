//
//  SettingsViewController.swift
//  1031_bookOfBet
//
//  Created by Владимир Кацап on 10.10.2024.
//

import UIKit
import Combine
import CombineCocoa
import StoreKit
import WebKit

class SettingsViewController: UIViewController {
    
    private var cancellable = [AnyCancellable]()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 12/255, green: 19/255, blue: 53/255, alpha: 1)
        setupUI()
    }
    

    private func setupUI() {
        let homeLabel = UILabel()
        homeLabel.text = "Settings"
        homeLabel.textColor = .white
        homeLabel.font = .systemFont(ofSize: 34, weight: .bold)
        view.addSubview(homeLabel)
        homeLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(-5)
        }
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        stackView.backgroundColor = .clear
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.height.equalTo(106)
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(homeLabel.snp.bottom).inset(-15)
        }
        
        let shareButton = createButton(image: .share, text: "Share the\napp")
        let rateButton = createButton(image: .rate, text: "Rate our\napp")
        let polButton = createButton(image: .pol, text: "Usage\nPolicy")
        
        stackView.addArrangedSubview(shareButton)
        stackView.addArrangedSubview(rateButton)
        stackView.addArrangedSubview(polButton)
        
        polButton.tapPublisher
            .sink { _ in
                self.policy()
            }
            .store(in: &cancellable)
        
        rateButton.tapPublisher
            .sink { _ in
                self.rateApps()
            }
            .store(in: &cancellable)
        
        shareButton.tapPublisher
            .sink { _ in
                self.shareApps()
            }
            .store(in: &cancellable)
    }
    
    private func createButton(image: UIImage, text: String) -> UIButton {
        let button = UIButton()
        button.backgroundColor = .white.withAlphaComponent(0.05)
        button.layer.cornerRadius = 12
        
        let imageView = UIImageView(image: image)
        button.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.height.width.equalTo(24)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(20)
        }
        
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 2
        label.textAlignment = .center
        button.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(10)
            make.top.equalTo(imageView.snp.bottom).inset(-5)
        }
        return button
    }
    
    private func rateApps() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
            if let url = URL(string: "ID") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
    private func shareApps() {
        let appURL = URL(string: "ID")!
        let activityViewController = UIActivityViewController(activityItems: [appURL], applicationActivities: nil)
        
        // Настройка для показа в виде popover на iPad
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }

        self.present(activityViewController, animated: true, completion: nil)
    }
    
    private func policy() {
        let webVC = WebViewController()
        webVC.urlString = "POL"
        present(webVC, animated: true, completion: nil)
    }

}


class WebViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    var urlString: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
        
        // Загружаем URL
        if let urlString = urlString, let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }
    }
}

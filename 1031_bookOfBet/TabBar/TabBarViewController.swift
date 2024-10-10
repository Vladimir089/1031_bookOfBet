import UIKit
import SnapKit
import Combine

var globalPublisher = PassthroughSubject<Any, Never>()

var eventsArr: [Event] = []

class TabBarViewController: UITabBarController {

    let tabbarView = UIView()
    let tabbarItemBackgroundView = UIView()
    var centerConstraint: NSLayoutConstraint?
    var buttons: [UIButton] = []
    
    
    override func viewDidLoad() {
        UserDefaults.standard.set("w", forKey: "tab")
        super.viewDidLoad()
        eventsArr = loadEventsArrFromFile() ?? []
        generateControllers()
        setView()
        buttonTapped(sender: buttons[0])
        let backButton = UIBarButtonItem()
        backButton.title = ""
        navigationItem.backBarButtonItem = backButton
    }


    private func setView() {
        view.addSubview(tabbarView)
        tabbarView.backgroundColor = .white.withAlphaComponent(0.05)
        tabbarView.translatesAutoresizingMaskIntoConstraints = false
        tabbarView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30).isActive = true
        tabbarView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -60).isActive = true
        tabbarView.heightAnchor.constraint(equalToConstant: 72).isActive = true
        tabbarView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        tabbarView.layer.cornerRadius = 20

        if buttons.count > 0 {
            for x in 0..<buttons.count {
                view.addSubview(buttons[x])
                buttons[x].tag = x
                buttons[x].layer.cornerRadius = 12
                buttons[x].translatesAutoresizingMaskIntoConstraints = false
                buttons[x].centerYAnchor.constraint(equalTo: tabbarView.centerYAnchor).isActive = true
                buttons[x].widthAnchor.constraint(equalTo: tabbarView.widthAnchor, multiplier: 1 / CGFloat(buttons.count), constant: -15).isActive = true
                buttons[x].heightAnchor.constraint(equalTo: tabbarView.heightAnchor , constant: -15).isActive = true
                buttons[x].addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
                if x == 0 {
                    buttons[x].leftAnchor.constraint(equalTo: tabbarView.leftAnchor, constant: 12).isActive = true
                } else {
                    buttons[x].leftAnchor.constraint(equalTo: buttons[x - 1].rightAnchor, constant: 12).isActive = true
                }
            }

            tabbarView.addSubview(tabbarItemBackgroundView)
            tabbarItemBackgroundView.translatesAutoresizingMaskIntoConstraints = false
            tabbarItemBackgroundView.widthAnchor.constraint(equalTo: tabbarView.widthAnchor, multiplier: 1 / CGFloat(buttons.count), constant: -15).isActive = true
            tabbarItemBackgroundView.heightAnchor.constraint(equalTo: tabbarView.heightAnchor, constant: -15).isActive = true
            tabbarItemBackgroundView.centerYAnchor.constraint(equalTo: tabbarView.centerYAnchor).isActive = true
            tabbarItemBackgroundView.layer.cornerRadius = 33
            tabbarItemBackgroundView.backgroundColor = .clear

            centerConstraint = tabbarItemBackgroundView.centerXAnchor.constraint(equalTo: buttons[0].centerXAnchor)
            centerConstraint?.isActive = true
        }
    }

    private func generateControllers() {
        let home = generateViewControllers(image: UIImage.homeTab.resize(targetSize: CGSize(width: 24, height: 24)), vc: HomeViewController())
        
        let eventVC = generateViewControllers(image: UIImage.eventsTab.resize(targetSize: CGSize(width: 24, height: 24)), vc: EventsViewController())
        let setting = generateViewControllers(image: UIImage.settingsTab, vc: SettingsViewController())
        viewControllers = [home, eventVC, setting]
    }

    private func generateViewControllers(image: UIImage, vc: UIViewController) -> UIViewController {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .black //UIColor(red: 229/255, green: 25/255, blue: 64/255, alpha: 1)
        button.backgroundColor = .white
        button.layer.cornerRadius = 40
        let resizedImage = image.resize(targetSize: CGSize(width: 20, height: 20)).withRenderingMode(.alwaysTemplate)
        button.setImage(resizedImage, for: .normal)
        buttons.append(button)
        return vc
    }
    
    @objc func buttonTapped(sender: UIButton) {
        selectedIndex = sender.tag
        
        for button in buttons {
            button.tintColor = .white.withAlphaComponent(0.2)
            button.backgroundColor = .clear
        }
        
        UIView.animate(withDuration: 0.2, delay: 0 , options: .beginFromCurrentState) {
            
            self.buttons[sender.tag].tintColor = .white
            self.buttons[sender.tag].backgroundColor = UIColor(red: 175/255, green: 218/255, blue: 18/255, alpha: 1)
            self.tabbarView.layoutIfNeeded()
        }
    }
    
    func loadEventsArrFromFile() -> [Event]? {
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Unable to get document directory")
            return nil
        }
        let filePath = documentDirectory.appendingPathComponent("event.plist")
        do {
            let data = try Data(contentsOf: filePath)
            let athleteArr = try JSONDecoder().decode([Event].self, from: data)
            return athleteArr
        } catch {
            print("Failed to load or decode athleteArr: \(error)")
            return nil
        }
    }
}






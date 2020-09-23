//
//  SelectionController.swift
//  VideoRecording
//
//  Created by mac on 23/09/2020.
//  Copyright © 2020 Private. All rights reserved.
//

import UIKit

class SelectionController: UIViewController {
    
    
    @IBOutlet weak var lblPath: UILabel!
    @IBOutlet weak var oltPath: UIButton!{
        didSet {
            oltPath.layer.cornerRadius = 20
            oltPath.layer.borderColor = UIColor.clear.cgColor
            oltPath.layer.borderWidth = 0.5
            oltPath.layer.masksToBounds = true
        }
    }
    
    var delegate :leftMenuProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        addBackButtonToNavigationBar()
        if let folderName = UserDefaults.standard.string(forKey: "album") {
            lblPath.text = folderName
        }
        
    }
    
    func addBackButtonToNavigationBar() {
        let backButton = UIButton(type: .custom)
        backButton.frame = CGRect(x: 0, y: 0, width: 20, height: 30)
        backButton.setBackgroundImage(UIImage(named: "backButton"), for: .normal)
        backButton.addTarget(self, action: #selector(moveToParentController), for: .touchUpInside)
        let backBarButton = UIBarButtonItem(customView: backButton)
        self.navigationItem.leftBarButtonItem = backBarButton
    }
    
    @objc func moveToParentController() {
        self.delegate?.changeViewController(.main)
    }
    
    
    @IBAction func actionChangePath(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "SettingsController") as! SettingsController
        navigationController?.pushViewController(vc, animated: true)
    }
}

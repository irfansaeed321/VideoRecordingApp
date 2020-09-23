//
//  LeftController.swift
//  VideoRecording
//
//  Created by mac on 09/09/2020.
//  Copyright © 2020 Private. All rights reserved.
//

import UIKit

enum leftMenu : Int {
    case main = 0
    case settings
}

protocol leftMenuProtocol {
    func changeViewController(_ menu : leftMenu)
}

class LeftController: UIViewController, leftMenuProtocol {

    @IBOutlet weak var tableView: UITableView!{
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.tableFooterView = UIView()
            tableView.separatorStyle = .singleLine
        }
    }
    
    
    var viewSettings: UIViewController!
    var viewHome: UIViewController!
    var dataArray = ["Home", "Settings option"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeViews()
    }
    
    fileprivate func initializeViews() {
        let homeView = storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        self.viewHome = UINavigationController(rootViewController: homeView)
        
        let settingsView = storyboard?.instantiateViewController(withIdentifier: "SelectionController") as! SelectionController
        settingsView.delegate = self
        self.viewSettings = UINavigationController(rootViewController: settingsView)
    }

    func changeViewController(_ menu: leftMenu) {
        switch  menu {
             case .main:
                slideMenuController()?.changeMainViewController(viewHome, close: true)
        case .settings:
            slideMenuController()?.changeMainViewController(viewSettings, close: true)
        }
    }
}

extension LeftController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LeftMenuCell", for: indexPath) as! LeftMenuCell
        cell.lblName.text = dataArray[indexPath.row]
        if indexPath.row == 0 {
            cell.imgIcon.image = UIImage(named: "home")?.withRenderingMode(.alwaysTemplate)
            cell.imgIcon.tintColor = .red
        } else {
            cell.imgIcon.image = UIImage(named: "settings")?.withRenderingMode(.alwaysTemplate)
             cell.imgIcon.tintColor = .red
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let menu = leftMenu(rawValue: indexPath.row) {
            self.changeViewController(menu)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}




class LeftMenuCell: UITableViewCell {
    
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
      
    }
}

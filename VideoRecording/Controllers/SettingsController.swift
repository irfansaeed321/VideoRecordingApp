//
//  SettingsController.swift
//  VideoRecording
//
//  Created by mac on 09/09/2020.
//  Copyright © 2020 Private. All rights reserved.
//

import UIKit
import Photos

class SettingsController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!{
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.tableFooterView = UIView()
        }
    }
    
    let fetchOptions = PHFetchOptions()
    var namesArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Change Video Save path"
        getAlbums { (assetsIn) in
            for item in assetsIn {
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
                if let name = item.localizedTitle {
                    namesArray.append(name)
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if namesArray.count != 0 {
            let sortedArray = namesArray.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending}
            
            self.namesArray = sortedArray
            tableView.reloadData()
        }
    }
    
    
    func getAlbums(completion: (_ albums: [PHAssetCollection]) -> ()) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "localizedTitle", ascending: true)]
        
        let albums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: fetchOptions)
        
        var result = Set<PHAssetCollection>()
        
        [albums, smartAlbums].forEach {
            $0.enumerateObjects { collection, index, stop in
                if let album = collection as? PHAssetCollection {
                    result.insert(album)
                }
            }
        }
        completion(Array<PHAssetCollection>(result))
    }
}


extension SettingsController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return namesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsCell
        cell.lblName.text = namesArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = AlertView.prepare(title: "Video Recording", message: "Are you sure change video saving path?", okAction: {
            let obj = self.namesArray[indexPath.row]
            UserDefaults.standard.set(obj, forKey: "album")
            UserDefaults.standard.synchronize()
            self.sceneDelegate.moveToHome()
        }, cancelAction: nil)
        present(alert, animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
}



class SettingsCell: UITableViewCell {
    
    
    @IBOutlet weak var lblName: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}

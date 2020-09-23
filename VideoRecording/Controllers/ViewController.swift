//
//  ViewController.swift
//  VideoRecording
//
//  Created by mac on 08/09/2020.
//  Copyright © 2020 Private. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift
import MobileCoreServices
import Photos
import AVFoundation
import AVKit
import AssetsLibrary

class ViewController: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var tableView: UITableView!{
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.tableFooterView = UIView()
            tableView.register(UINib(nibName: "VideoCell", bundle: nil), forCellReuseIdentifier: "VideoCell")
        }
    }
    
    @IBOutlet weak var oltRecord: UIButton!{
        didSet {
            oltRecord.layer.cornerRadius = 10
        }
    }
    
    let picker = UIImagePickerController()
    var assetsFetchResult = PHFetchResult<PHAsset>()
    lazy var imageManager: PHCachingImageManager = {
        return PHCachingImageManager()
    }()
    var albumFound = false
    let session = AVAudioSession.sharedInstance()
    var playerViewController: AVPlayerViewController!
    var objArray = [VideoObject]()
    var imageUrls = [URL]()
    
    var assetsArray = [PHAsset]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Video Recording"
        addLeftBarButtonWithImage()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let status = PHPhotoLibrary.authorizationStatus()
        self.fetchCustomAlbumPhotos()
        if status == .notDetermined  {
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized {
                    self.fetchCustomAlbumPhotos()
                }
            })
        }
    }
    
    func fetchCustomAlbumPhotos() {
        let albumName = UserDefaults.standard.string(forKey: "album") ?? "Video Recorder"
        
//        let albumName = "Video Recorder"
        var assetCollection = PHAssetCollection()
        var photoAssets = PHFetchResult<AnyObject>()
        let fetchOptions = PHFetchOptions()
        
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collection:PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let firstObject = collection.firstObject{
            //found the album
            assetCollection = firstObject
            albumFound = true
            objArray = []
        }
        else { albumFound = false }
        _ = collection.count
        photoAssets = PHAsset.fetchAssets(in: assetCollection, options: nil) as! PHFetchResult<AnyObject>
        photoAssets.enumerateObjects{(object: AnyObject!,
            count: Int,
            stop: UnsafeMutablePointer<ObjCBool>) in
            if object is PHAsset {
                if let asset = object as? PHAsset {
                    let options = PHVideoRequestOptions()
                    options.isNetworkAccessAllowed = true
                    options.deliveryMode = .automatic
                     self.assetsArray.append(asset)
                    _ = self.imageManager.requestAVAsset(forVideo: asset, options: options, resultHandler: { (asset, audioMix, info) in
                        if asset != nil {
                            if let assets = asset as? AVURLAsset {
                                let urlVideo = assets.url
                                let size = assets.fileSize
                                let name = urlVideo.lastPathComponent
                                let durationInSeconds = assets.duration.seconds
                                self.objArray.append(VideoObject(name: name, duration: durationInSeconds, size: size ?? 0, url: urlVideo))
                            }
                        }
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    })
                }
            }
        }
    }
    func getThumbnailImageFromVideoUrl(url: URL, completion: @escaping ((_ image: UIImage?)->Void)) {
        DispatchQueue.global().async { //1
            let asset = AVAsset(url: url) //2
            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset) //3
            avAssetImageGenerator.appliesPreferredTrackTransform = true //4
            let thumnailTime = CMTimeMake(value: 2, timescale: 1) //5
            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil) //6
                let thumbImage = UIImage(cgImage: cgThumbImage) //7
                DispatchQueue.main.async { //8
                    completion(thumbImage) //9
                }
            } catch {
                print(error.localizedDescription) //10
                DispatchQueue.main.async {
                    completion(nil) //11
                }
            }
        }
    }
    
    
    func playVideo(streamUrl: URL?) {
        guard let url = streamUrl else {
            return
        }
        if AVAudioSession.isHeadphonesConnected {
            try? session.overrideOutputAudioPort(.none)
        } else {
            try? session.overrideOutputAudioPort(.speaker)
        }
        let player = AVPlayer(url: url)
        playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.entersFullScreenWhenPlaybackBegins = true
        present(playerViewController, animated: true) {
            self.playerViewController.player?.play()
        }
    }
    
    func removeItem(index: Int) {
        DispatchQueue.main.async {
            self.objArray.remove(at: index)
            self.tableView.reloadData()
        }
    }
    
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    
    @IBAction func actionRecord(_ sender: UIButton) {
        VideoHelper.startMediaBrowser(delegate: self, sourceType: .camera)
//        print(assetsArray)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath) as! VideoCell
        let objData = objArray[indexPath.row]
        getThumbnailImageFromVideoUrl(url: objData.url.absoluteURL) { (image) in
            cell.imgPicture?.image = image
        }
        if let size = objData.size {
            let sizeInKB = size/1024
            let inMB = sizeInKB/1024
            cell.lblSize.text = "\(inMB) MB"
        }
        
        if let name = objData.name {
            cell.lblName.text = name
        }
        
        if let duration = objData.duration {
            let time = secondsToHoursMinutesSeconds(seconds: Int(duration))
            cell.lblDuration.text = "\(time.0):\(time.1):\(time.2)"
        }
        
        return cell
    }
   

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let objData = objArray[indexPath.row]
        playVideo(streamUrl: objData.url)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.deleteAssets([self.assetsArray[indexPath.row]] as NSArray)
            }, completionHandler: { success, error in
                if success {
                    self.fetchCustomAlbumPhotos()
                }
            })
        }
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedVideo = info[.mediaType] as? String,
            pickedVideo == (kUTTypeMovie as String) {
            if let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
                CustomPhotoAlbum.sharedInstance.saveVideo(url: url)
            }
        }
        dismiss(animated: true) {
            self.fetchCustomAlbumPhotos()
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true) {
            self.fetchCustomAlbumPhotos()
        }
    }
}


struct VideoObject {
    
    var name: String!
    var duration: Double!
    var size: Int!
    var url: URL!
    
    init(name: String, duration: Double, size: Int, url: URL) {
        self.name = name
        self.duration = duration
        self.size = size
        self.url = url
    }
}

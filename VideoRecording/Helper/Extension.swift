//
//  Extension.swift
//  VideoRecording
//
//  Created by mac on 09/09/2020.
//  Copyright © 2020 Private. All rights reserved.
//

import UIKit
import AVFoundation

extension FileManager {
    
    func saveFileToDocumentDirectory(fileUrl: URL, name: String, extention:String) -> URL? {
        let videoData = NSData(contentsOf: fileUrl as URL)
        let path = try! FileManager.default.url(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: false)
        let filePath = path.appendingPathComponent(name + extention)
        do {
            try videoData?.write(to: filePath)
            return filePath
        }
        catch {
            print(error)
            return nil
        }
    }
    
    func saveFileToDocumentsDirectory(image: UIImage, name: String, extention: String) -> URL? {
        let path = try! FileManager.default.url(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: false)
        let imagePath = path.appendingPathComponent(name + extention)
        let jpgImageData = image.jpegData(compressionQuality: 0)
        do {
            try jpgImageData!.write(to: imagePath)
            return imagePath
        } catch {
            return nil
        }
    }
    
    func removeFileFromDocumentsDirectory(fileUrl: URL) -> Bool {
        do {
            try self.removeItem(at: fileUrl)
            return true
        } catch {
            return false
        }
    }
}

extension AVAudioSession {
    static var isHeadphonesConnected: Bool {
        return sharedInstance().isHeadphonesConnected
    }
    var isHeadphonesConnected: Bool {
        return !currentRoute.outputs.filter { $0.isHeadphones }.isEmpty
    }
}

extension AVAudioSessionPortDescription {
    var isHeadphones: Bool {
        return portType == AVAudioSession.Port.headphones
    }
}

extension Date {
    var startOfDay : Date {
        let calendar = Calendar.current
        let unitFlags = Set<Calendar.Component>([.year, .month, .day])
        let components = calendar.dateComponents(unitFlags, from: self)
        return calendar.date(from: components)!
    }
}

extension AVURLAsset {
    var fileSize: Int? {
        let keys: Set<URLResourceKey> = [.totalFileSizeKey, .fileSizeKey]
        let resourceValues = try? url.resourceValues(forKeys: keys)

        return resourceValues?.fileSize ?? resourceValues?.totalFileSize
    }
}

extension UIViewController {
    open override func awakeFromNib() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}

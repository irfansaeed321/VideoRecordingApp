//
//  AppDelegate.swift
//  VideoRecording
//
//  Created by mac on 08/09/2020.
//  Copyright © 2020 Private. All rights reserved.
//

import UIKit
import CoreData
import SlideMenuControllerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        customizeNavigationBar()
        checkUserExist()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {

    }

    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "VideoRecording")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

extension AppDelegate {
    func customizeNavigationBar() {
        let appearance = UINavigationBar.appearance()
        appearance.setBackgroundImage(UIImage(), for: .default)
        appearance.shadowImage = UIImage()
        appearance.isTranslucent = false
        appearance.barTintColor = .red
        appearance.tintColor = .white
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
    }
    
    
    func checkUserExist() {
        if let user = UserDefaults.standard.string(forKey: "album") {
            if user.isEmpty {
                UserDefaults.standard.set("Video Recorder", forKey: "album")
                UserDefaults.standard.synchronize()
            }
        }
    }
}

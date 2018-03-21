//
//  AppDelegate.swift
//  Todoey
//
//  Created by Gabriele Filosofi on 08/03/2018.
//  Copyright © 2018 Gabriele Filosofi. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //Get our Realm file's path (only for development when using a simulator)
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        do {
            let _ = try Realm()
        } catch {
            print("Error initialising realm database")
        }
        return true
    }
}


//
//  AppDelegate.swift
//  myNursingSpots
//
//  Created by Elena Kulakova on 2019-06-27.
//  Copyright © 2019 Elena Kulakova. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var myLocation: CLLocationCoordinate2D?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let dataController = DataController.shared
        dataController.load()
        setCustomizations()
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        try? DataController.shared.viewContext.save()
    }
    
    func setCustomizations() {
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Avenir", size: 17) as Any]
        
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self])
            .setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Avenir", size: 17) as Any,      NSAttributedString.Key.foregroundColor: UIColor.black],
                                     for: .normal)
        UINavigationBar.appearance().tintColor = .black
    }
}


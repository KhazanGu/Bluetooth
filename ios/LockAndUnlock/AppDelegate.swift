//
//  AppDelegate.swift
//  LockAndUnlock
//
//  Created by Khazan on 2020/9/21.
//

import Foundation
import UIKit
import CoreBluetooth

class AppDelegate: NSObject, UIApplicationDelegate {
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("didFinishLaunchingWithOptions launchOptions:\(String(describing: launchOptions))")
        
        BluetoothControler.sharedInstance.launchWithOptions(launchOptions: launchOptions)
    
        return true
    }
    
}

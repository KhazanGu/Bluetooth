//
//  AppDelegate.swift
//  LockAndUnlock
//
//  Created by Khazan on 2020/9/17.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var statusItem: NSStatusItem!

    var statusBarMenu: NSMenu!
    
    var statusBarMenuItem: NSMenuItem!

    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application

        statusItem = NSStatusBar.system.statusItem(withLength: 30)
        
        statusItem.button?.image = NSImage(named: NSImage.Name("StateIcon"))
        
        statusBarMenu = NSMenu(title: "LockAndUnlock")

        statusItem.menu = statusBarMenu
        
        statusBarMenuItem = NSMenuItem(title: "RSSI    --", action: nil, keyEquivalent: "")

        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        
        statusBarMenu.addItem(statusBarMenuItem)

        statusBarMenu.addItem(NSMenuItem.separator())

        statusBarMenu.addItem(quitItem)

        NotificationCenter.default.addObserver(self, selector: #selector(updateRSSI(not:)), name: NSNotification.Name.init("RSSI_UPDATE"), object:  nil)
        
        
    }
    
    @objc func updateRSSI(not: NSNotification) -> Void {
        
        guard let userInfo = not.userInfo else { return }
        
        guard let RSSI = userInfo["RSSI"] as? String else { return }
        
        statusBarMenuItem.title = "RSSI    " + RSSI
        
    }
        
    @objc func quit() -> Void {
        
        NSApplication.shared.terminate(self)
        
    }
        

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        
        return false
        
    }
    

}




/*
 *
 Background
 
 https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/CoreBluetooth_concepts/CoreBluetoothBackgroundProcessingForIOSApps/PerformingTasksWhileYourAppIsInTheBackground.html#//apple_ref/doc/uid/TP40013257-CH7-SW1
 
 */

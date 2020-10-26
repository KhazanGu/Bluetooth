//
//  ViewController.swift
//  LockAndUnlock
//
//  Created by Khazan on 2020/9/17.
//

import Cocoa

class ViewController: NSViewController, BluetoothDelegate {
    
    
    func updateRSSI(RSSI: String) {
        
        NotificationCenter.default.post(name: NSNotification.Name.init("RSSI_UPDATE"), object: nil, userInfo: [AnyHashable("RSSI"): RSSI])
                
        self.RSSILabel.stringValue = RSSI
        
    }

    
    @IBAction func onSwitch(_ sender: NSSwitch) {
                
        if sender.state == .on {
            
            bluetooth.startAdv()
            
        } else {
            
            bluetooth.stopAdv()
            
        }
        
    }
    

    
    

    let bluetooth = Bluetooth()
    
    var lockstate = false
    
    @IBOutlet weak var RSSILabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        bluetooth.delegate = self
        
        bluetooth.userName = NSUserName()
        
    }
    
    

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}


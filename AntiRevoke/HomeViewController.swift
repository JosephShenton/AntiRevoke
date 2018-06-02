//
//  ViewController.swift
//  AntiRevoke
//
//  Created by Joseph Shenton on 02/06/18.
//  Copyright © 2018 Joseph Shenton. All rights reserved.
//

import UIKit
import NetworkExtension


class HomeViewController: UITableViewController {
    
    @IBOutlet var connectButton: UIButton!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    var status: VPNStatus {
        didSet(o) {
            updateConnectButton()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.status = .off
        super.init(coder: aDecoder)
        NotificationCenter.default.addObserver(self, selector: #selector(onVPNStatusChanged), name: NSNotification.Name(rawValue: kProxyServiceVPNStatusNotification), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.status = VpnManager.shared.vpnStatus
    }
    
    func onVPNStatusChanged(){
        self.status = VpnManager.shared.vpnStatus
    }
    
    func updateConnectButton(){
        switch status {
        case .connecting:
            connectButton.setTitle("Connecting", for: UIControlState())
            statusLabel.text = "Connecting"
        case .disconnecting:
            connectButton.setTitle("Disconnecting", for: UIControlState())
            statusLabel.text = "Disconnecting"
        case .on:
            connectButton.setTitle("Disconnect", for: UIControlState())
            statusLabel.text = "Connected"
        case .off:
            connectButton.setTitle("Connect", for: UIControlState())
            statusLabel.text = "Disconnected"

        }
        connectButton.isEnabled = [VPNStatus.on,VPNStatus.off].contains(VpnManager.shared.vpnStatus)

        
    }
    
    @IBAction func connectToAntiRevoke(_ sender: AnyObject) {
        print("Connecting to AntiRevoke")
        if(VpnManager.shared.vpnStatus == .off){
            VpnManager.shared.connect()
        }else{
            VpnManager.shared.disconnect()
        }
    }
    
    
}



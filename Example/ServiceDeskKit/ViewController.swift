//
//  ViewController.swift
//  ServiceDeskKit
//
//  Created by willpowell8 on 11/10/2017.
//  Copyright (c) 2017 willpowell8. All rights reserved.
//

import UIKit
import ServiceDeskKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        ServiceDesk.shared.setup(host: "https://holtrenfrew.atlassian.net", serviceDeskId: "2", requestTypeId: "157")
        ServiceDesk.shared.preAuth(username: "Holts360.User@holtrenfrew.com", password: "R3nfr3w99")
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         ServiceDesk.shared.raise()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


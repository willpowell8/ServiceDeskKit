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
        ServiceDesk.shared.setup(host: "{HOST}", serviceDeskId: "{SERVICE_DESK_ID}", requestTypeId: "{REQUEST_TYPE_ID}")
        ServiceDesk.shared.preAuth(username: "{USERNAME}", password: "{PASSWORD}")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startServiceDesk()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createPDF()->String{
        let fileName = "test.pdf"
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0] as NSString
        let pathForPDF = documentsDirectory.appending("/" + fileName)
        
        UIGraphicsBeginPDFContextToFile(pathForPDF, .zero, nil)
        
        let pageSize = CGRect(x:0,y:0,width:400,height:500)
        UIGraphicsBeginPDFPageWithInfo(pageSize, nil)
        let font = UIFont(name: "Helvetica", size: 12.0)
        let textRect = CGRect(x:5,y:5,width:500,height:18)
        let paragraphStyle:NSMutableParagraphStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.alignment = NSTextAlignment.left
        paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        let textColor = UIColor.black
        
        let textFontAttributes = [
            NSAttributedStringKey.font: font!,
            NSAttributedStringKey.foregroundColor: textColor,
            NSAttributedStringKey.paragraphStyle: paragraphStyle
        ]
        
        let text = "HELLO WORLD"
        text.draw(in: textRect, withAttributes: textFontAttributes)
        
        UIGraphicsEndPDFContext()
        return "file://"+pathForPDF
    }
    
    func startServiceDesk(){
        ServiceDesk.shared.raise(defaultFields: ["attachment":createPDF()])
    }

}


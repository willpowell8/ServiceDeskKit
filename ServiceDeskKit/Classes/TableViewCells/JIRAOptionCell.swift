//
//  JIRAOptionCell.swift
//  JIRAMobileKit
//
//  Created by Will Powell on 11/10/2017.
//

import Foundation

class JIRAOptionCell:JIRACell{
    override func setup(){
        self.accessoryType = .disclosureIndicator
        self.detailTextLabel?.textColor = ServiceDesk.MainColor
    }
    
    override func applyData(data:[String:Any]){
        if let field = field, let identifier = field.fieldId {
            if let element = data[identifier] as? DisplayClass {
                self.detailTextLabel?.text = element.label
            }else if let elements = data[identifier] as? [DisplayClass] {
                let strs = elements.flatMap({ (element) -> String? in
                    return element.label
                })
                self.detailTextLabel?.text = strs.joined(separator: ", ")
            }
        }
    }
}

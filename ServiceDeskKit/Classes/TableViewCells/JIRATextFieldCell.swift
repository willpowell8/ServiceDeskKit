//
//  JIRATextFieldCell.swift
//  JIRAMobileKit
//
//  Created by Will Powell on 11/10/2017.
//

import Foundation

class JIRATextFieldCell:JIRACell{
    var textField:UITextField?
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected == true {
            self.textField?.becomeFirstResponder()
        }else{
            self.textField?.resignFirstResponder()
        }
    }
    override func setup(){
        textField = UITextField()
        textField?.placeholder = ServiceDesk.placeHolderText
        textField?.textAlignment = .right
        self.addSubview(textField!)
        textField?.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 9.0, *) {
            textField?.leftAnchor.constraint(equalTo: self.textLabel!.rightAnchor, constant: 10).isActive = true
            textField?.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -30).isActive = true
            textField?.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            textField?.heightAnchor.constraint(equalToConstant: 20).isActive = true
        }
        textField?.textColor = ServiceDesk.MainColor
        self.textLabel?.backgroundColor = .red
        textField?.addTarget(self, action: #selector(didChangeTextfield), for: UIControl.Event.editingChanged)
    }
    
    override func applyData(data:[String:Any]){
        if let field = field, let identifier = field.fieldId {
            if let element = data[identifier] as? String {
                self.textField?.text = element
            }
        }
    }
    
    override func deselect() {
        super.deselect()
        self.textField?.resignFirstResponder()
    }
    
    @objc func didChangeTextfield(){
        delegate?.jiraSelected(field: field, item: self.textField?.text)
    }
}

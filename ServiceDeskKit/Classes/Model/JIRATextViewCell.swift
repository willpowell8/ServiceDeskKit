//
//  JIRATextViewCell.swift
//  MBProgressHUD
//
//  Created by Will Powell on 11/11/2017.
//

import Foundation

class JIRATextViewCell:JIRACell{
    var textField:UITextView?
    
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
        hideNormalLabel()
        textField = UITextView()
        //textField?.placeholder = "enter value"
        //textField?.textAlignment = .right
        self.addSubview(textField!)
        textField?.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 9.0, *) {
            textField?.leftAnchor.constraint(equalTo: titleLabel.leftAnchor, constant: -3).isActive = true
            textField?.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -30).isActive = true
            textField?.topAnchor.constraint(equalTo: self.topAnchor, constant:30).isActive = true
            textField?.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant:-10).isActive = true
        }
        textField?.textColor = ServiceDesk.MainColor
        self.textLabel?.backgroundColor = .red
        //textField?.addTarget(self, action: #selector(didChangeTextfield), for: UIControlEvents.editingChanged)
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
    
    override func height()->CGFloat{
        return 200
    }
}

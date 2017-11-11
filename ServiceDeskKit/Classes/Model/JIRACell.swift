//
//  JIRACells.swift
//  Pods
//
//  Created by Will Powell on 30/08/2017.
//
//

import Foundation

class JIRACell:UITableViewCell{
    
    var field:ServiceDeskRequestField?
    var delegate:JIRASubTableViewControllerDelegate?
    var titleLabel:UILabel = UILabel()
    
    func start(field:ServiceDeskRequestField?, data:[String:Any]?){
        self.field = field
        textLabel?.text = field?.name
        titleLabel.text = field?.name
        setup()
        guard let dataV = data else{
            return
        }
        applyData(data: dataV)
    }
    
    func setup(){
        
    }
    
    func deselect(){
        
    }
    
    func applyData(data:[String:Any]){
        
    }
    
    func height()->CGFloat{
        return 44
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
    }
    
    func hideNormalLabel(){
        addSubview(titleLabel)
        textLabel?.isHidden = true
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 9.0, *), let textLabel = self.textLabel {
            titleLabel.leftAnchor.constraint(equalTo: textLabel.leftAnchor, constant: 0).isActive = true
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        }
    }
    
}

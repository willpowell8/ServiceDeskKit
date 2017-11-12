//
//  ServiceEntities.swift
//  MBProgressHUD
//
//  Created by Will Powell on 10/11/2017.
//

import Foundation


protocol DisplayClass:NSObjectProtocol {
    var label:String?{get}
    func applyData(data:[AnyHashable:Any])
}

class ServiceDeskEntity :NSObject {
    required public override init() {
        super.init()
    }
    
    func export()->Any? {
        return [String:Any]()
    }
}

class ServiceDeskRequest:ServiceDeskEntity {
    var requestTypeFields:[ServiceDeskRequestField]?
    var canAddRequestParticipants:Bool?
    var canRaiseOnBehalfOf:Bool?
    func applyData(data:[AnyHashable:Any]){
        if let canRaiseOnBehalfOf = data["canAddRequestParticipants"] as? Bool  {
            self.canRaiseOnBehalfOf = canRaiseOnBehalfOf
        }
        if let canAddRequestParticipants = data["canAddRequestParticipants"] as? Bool  {
            self.canAddRequestParticipants = canAddRequestParticipants
        }
        if let requestTypeFieldsData = data["requestTypeFields"] as? [[AnyHashable:Any]] {
            self.requestTypeFields = requestTypeFieldsData.flatMap({ (requestTypeFieldsDataElement) -> ServiceDeskRequestField? in
                let element = ServiceDeskRequestField()
                element.applyData(data: requestTypeFieldsDataElement)
                return element
            })
        }
    }
}

class ServiceDeskRequestField:ServiceDeskEntity {
    var fieldId:String?
    var name:String?
    var descr:String?
    var required:Bool = false
    var validValues:[ServiceDeskRequestFieldValue]?
    var jiraSchema:ServiceDeskJIRASchema?
    func applyData(data:[AnyHashable:Any]){
        if let fieldId = data["fieldId"] as? String  {
            self.fieldId = fieldId
        }
        
        if let name = data["name"] as? String  {
            self.name = name
        }
        
        if let descr = data["description"] as? String  {
            self.descr = descr
        }
        
        if let required = data["required"] as? Bool  {
            self.required = required
        }
        
        if let jiraSchemaData = data["jiraSchema"] as? [AnyHashable:Any]  {
            let jiraSchema = ServiceDeskJIRASchema()
            jiraSchema.applyData(data: jiraSchemaData)
            self.jiraSchema = jiraSchema
        }
        
        if let validValuesData = data["validValues"] as? [[AnyHashable:Any]] {
            self.validValues = validValuesData.flatMap({ (data) -> ServiceDeskRequestFieldValue? in
                let element = ServiceDeskRequestFieldValue()
                element.applyData(data: data)
                return element
            })
        }
    }
}

class ServiceDeskRequestFieldValue:ServiceDeskEntity, DisplayClass {
    var value:String?
    var label:String?
    var children:[ServiceDeskRequestFieldValue]?
    func applyData(data:[AnyHashable:Any]){
        if let value = data["value"] as? String  {
            self.value = value
        }
        if let label = data["label"] as? String  {
            self.label = label
        }
        
        if let childrenData = data["children"] as? [[AnyHashable:Any]] {
            self.children = childrenData.flatMap({ (data) -> ServiceDeskRequestFieldValue? in
                let element = ServiceDeskRequestFieldValue()
                element.applyData(data: data)
                return element
            })
        }
    }
    
    override func export()->Any? {
        return value
    }
}

class ServiceDeskJIRASchema:ServiceDeskEntity {
    var type:String?
    var custom:String?
    var customId:String?
    var system:String?
    func applyData(data:[AnyHashable:Any]){
        if let type = data["type"] as? String  {
            self.type = type
        }
        if let custom = data["custom"] as? String  {
            self.custom = custom
        }
        if let customId = data["customId"] as? String  {
            self.customId = customId
        }
        if let system = data["system"] as? String  {
            self.system = system
        }
    }
}

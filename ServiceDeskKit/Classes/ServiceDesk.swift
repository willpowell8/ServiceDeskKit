//
//  JIRA.swift
//  Pods
//
//  Created by Will Powell on 30/08/2017.
//
//

import Foundation
import MBProgressHUD

public class ServiceDesk {
    
    // Jira singleton instance
    public static var shared = ServiceDesk()
    
    private static let url_request_metadata = "/rest/servicedeskapi/servicedesk/[SERVICE_DESK_ID]/requesttype/[REQUEST_TYPE_ID]/field"

    // END POINTS
    private static let url_issue  = "rest/api/2/issue";
    private static let url_issue_attachments = "rest/api/2/issue/%@/attachments";
    
    
    
    private static let url_myself = "/rest/api/2/myself"
    private static let url_jql_property = "/rest/api/1.0/jql/autocomplete?"
    
    internal static let MainColor = UIColor(red:32/255.0, green: 80.0/255.0, blue: 129.0/255.0,alpha:1.0)
    
    private var _host:String?
    // jira host eg. http://company.atlassian.net for JIRA cloud hosted
    public var host:String? {
        get{
            return _host
        }
    }
    
    private var _serviceDeskId:String?
    // jira host eg. http://company.atlassian.net for JIRA cloud hosted
    public var serviceDeskId:String? {
        get{
            return _serviceDeskId
        }
    }
    private var _requestTypeId:String?
    // jira host eg. http://company.atlassian.net for JIRA cloud hosted
    public var requestTypeId:String? {
        get{
            return _requestTypeId
        }
    }
    
    private var _username:String?
    
    // jira host eg. http://company.atlassian.net for JIRA cloud hosted
    var username:String? {
        get{
            if _username != nil {
                return _username
            }
            return UserDefaults.standard.string(forKey: "JIRA_USE")
        }
        set {
            _username = newValue
            UserDefaults.standard.set(newValue, forKey: "JIRA_USE")
            UserDefaults.standard.synchronize()
        }
    }
    
    private var _password:String?
    var password:String? {
        get{
            if _password != nil {
                return _password
            }
            return UserDefaults.standard.string(forKey: "JIRA_PWD")
        }
        set {
            _password = newValue
            UserDefaults.standard.set(newValue, forKey: "JIRA_PWD")
            UserDefaults.standard.synchronize()
        }
    }
    
    
    public func preAuth(username:String, password:String){
        _password = password
        _username = username
    }
    
    // The fields that should be added for all tasks by default
    public var globalDefaultFields:[String:Any]?
    
    internal static func getBundle()->Bundle{
        let podBundle =  Bundle.init(for: ServiceDesk.self)
        let bundleURL = podBundle.url(forResource: "ServiceDeskKit" , withExtension: "bundle")
        return Bundle(url: bundleURL!)!
    }
    
    //
    public func setup(host:String, serviceDeskId:String, requestTypeId:String, defaultValues:[String:Any]? = nil){
        var shouldReset = false
        if let originalHost = UserDefaults.standard.string(forKey: "SERVICEDESK_HOST"), let originalServiceDeskId = UserDefaults.standard.string(forKey: "SERVICEDESK_SERVICEDESKID") {
            if originalHost != host || serviceDeskId != originalServiceDeskId {
                shouldReset = true
            }
        }else{
            shouldReset = true
        }
        self._host = host
        self._serviceDeskId = serviceDeskId
        self._requestTypeId = requestTypeId
        if shouldReset {
            UserDefaults.standard.set(nil, forKey: "SERVICEDESK_CREATEMETA_CACHE")
            UserDefaults.standard.set(host,forKey: "SERVICEDESK_HOST")
            UserDefaults.standard.set(serviceDeskId,forKey: "SERVICEDESK_SERVICEDESKID")
            UserDefaults.standard.set(requestTypeId,forKey: "SERVICEDESK_REQUESTTYPEID")
            UserDefaults.standard.set(nil, forKey: "SERVICEREQUEST_PWD")
            UserDefaults.standard.set(nil, forKey: "SERVICEREQUEST_USE")
            UserDefaults.standard.synchronize()
        }
    }
    
    public func raise(defaultFields:[String:Any]? = nil){
        if let rootController = UIApplication.shared.keyWindow?.rootViewController {
            
            // Start with global fields
            var fields = self.globalDefaultFields ?? [String:Any]()
            
            // merge in default fields for current view
            if let singleDefaults = defaultFields {
                singleDefaults.forEach({ (key, value) in
                    fields[key] = value
                })
            }
            
            // Add Image
            if let image = UIApplication.shared.keyWindow?.capture() {
                if let attachments = fields["attachment"] {
                    if var attachmentAry = attachments as? [Any] {
                        attachmentAry.insert(image, at: 0)
                        fields["attachment"] = attachmentAry
                    }else{
                        fields["attachment"] = [image,attachments]
                    }
                }else{
                    fields["attachment"] = [image]
                }
            }
            if let environment = fields["description"] as? String {
                fields["description"] = environment + " " + ServiceDesk.environmentString()
            }else{
                fields["description"] = ServiceDesk.environmentString()
            }
            let newVC = JIRARaiseTableViewController()
            var currentController: UIViewController! = rootController
            while( currentController.presentedViewController != nil ) {
                currentController = currentController.presentedViewController
            }
            newVC.singleInstanceDefaultFields = fields
            newVC.image = UIApplication.shared.keyWindow?.capture()
            
            let nav = UINavigationController(rootViewController: newVC);
            nav.navigationBar.barStyle = .blackOpaque
            nav.navigationBar.tintColor = UIColor.white
            nav.navigationBar.barTintColor = ServiceDesk.MainColor
            nav.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
            nav.navigationBar.isTranslucent = false
            nav.navigationBar.isOpaque = true
            currentController.present(nav, animated: true)
        }
    }
    
    func generateBearerToken(username:String, password:String)->String?{
        let userPasswordString = username + ":" + password
        if let userPasswordData = userPasswordString.data(using: String.Encoding.utf8) {
            let base64EncodedCredential = userPasswordData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue:0))
            return "Basic \(base64EncodedCredential)"
        }
        return nil
    }

    func getBearerToken()->String?{
        if let username = self.username, let password =
            self.password {
            return generateBearerToken(username: username, password: password)
        }
        return ""
    }
    
    func session()->URLSession{
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["Authorization" : getBearerToken()!]
        return URLSession(configuration: config)
    }
    
    func session(_ username:String, _ password:String)->URLSession{
        let config = URLSessionConfiguration.default
        if let authString = generateBearerToken(username: username, password: password) {
            config.httpAdditionalHeaders = ["Authorization" : authString]
        }
        return URLSession(configuration: config)
    }
    
    public func login(username:String, password:String, completion: @escaping (_ completed:Bool, _ error:String?) -> Void) {
        let url = URL(string: "\(host!)\(ServiceDesk.url_myself)")!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        let task = session(username, password).dataTask(with:request) { data, response, error in
            
            if let _ = response as? HTTPURLResponse {
                do {
                    _ = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)  as? NSDictionary
                    self.username = username
                    self.password = password
                    completion(true, nil)
                } catch {
                    print("error serializing JSON: \(error)")
                    completion(false,"Could not authenticate you. You may need to login on the web to reset captcha before trying again.")
                }
            }else{
                completion(false,"Could connect to JIRA. Check your configurations.")
            }
        }
        task.resume()
    }
    
    static func environmentString()->String {
        var buildStr = "";
        var versionStr = "";
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionStr = version
        }
        if let version = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            buildStr = version
        }
        let systemVersion = UIDevice.current.systemVersion
        /*var output = ""
        Bundle.allFrameworks.forEach { (bundle) in
            if let bundleIdentifier = bundle.bundleIdentifier, bundleIdentifier.contains("com.apple") == false{
                var record = bundleIdentifier
                if let version = bundle.infoDictionary!["CFBundleShortVersionString"] as? String {
                    record += " - \(version)"
                }
                output += record+"\n"
            }
        }*/
        
        return "\(UIDevice.current.model) \(systemVersion) version: \(versionStr) - build: \(buildStr)"
    }
    
    private func createDataTransferObject(_ issueData:[AnyHashable:Any]) -> [String:Any]{
        var data = [String:Any]()
        issueData.forEach { (key,value) in
            if let key = key as? String {
                if value is String {
                    data[key] = value
                }else if let jiraEntity = value as? ServiceDeskEntity {
                    data[key] = jiraEntity.export()
                }else if let jiraEntityAry = value as? [ServiceDeskEntity] {
                    let entities = jiraEntityAry.map({ (entity) -> Any? in
                        return entity.export()
                    })
                    data[key] = entities
                }
            }
        }
        return ["fields":data]
    }
    
    internal func create(issueData:[AnyHashable:Any], completion: @escaping (_ error:String?,_ key:String?) -> Void){
        let url = URL(string: "\(host!)/\(ServiceDesk.url_issue)")!
        let data = createDataTransferObject(issueData)
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: JSONSerialization.WritingOptions(rawValue: 0))
            request.httpBody = jsonData
            let task = session().dataTask(with:request) { data, response, error in
                
                if let _ = response as? HTTPURLResponse {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)  as? NSDictionary
                        if let key = json?.object(forKey: "key") as? String {
                            if let attachments = issueData["attachment"] as? [Any] {
                                self.uploadAttachments(key: key, attachments: attachments, completion: completion)//.postImage(key: key, image: image, completion: completion)
                            }else{
                                completion(nil, key)
                            }
                        }else if let errors = json?.object(forKey: "errors") as? [String:Any] {
                            var str = [String]()
                            errors.forEach({ (key, value) in
                                if let val = value as? String {
                                    str.append(val)
                                }
                            })
                            let errorMessage = str.joined(separator: "\n")
                            completion(errorMessage, nil)
                        }
                    } catch {
                        print("error serializing JSON: \(error)")
                        completion("error serializing JSON: \(error)", nil)
                    }
                }
            }
            task.resume()
        } catch {
            print(error)
            completion("error serializing JSON: \(error)", nil)
        }
    }
    
    
    internal func uploadAttachments(key:String, attachments:[Any], completion: @escaping (_ error:String?,_ key:String?) -> Void){
        var datas = [(name:String, data:Data, mimeType:String)]()
        attachments.forEach { (attachment) in
            if let attachmentPath = attachment as? String, let attachmentURL:URL = URL(string:attachmentPath) {
                if let data = try? Data(contentsOf:attachmentURL) {
                    let mimeType = attachmentURL.absoluteString.mimeType()
                    let fileName = attachmentURL.lastPathComponent
                    datas.append((name: fileName, data: data, mimeType: mimeType))
                }
            }else if let attachmentURL = attachment as? URL {
                if let data = try? Data(contentsOf:attachmentURL) {
                    let mimeType = attachmentURL.absoluteString.mimeType()
                    let fileName = attachmentURL.lastPathComponent
                    datas.append((name: fileName, data: data, mimeType: mimeType))
                }
            }else if let attachmentImage = attachment as? UIImage{
                if let data = UIImagePNGRepresentation(attachmentImage) {
                    datas.append((name: "Screenshot.png", data: data, mimeType: "image/png"))
                }
            }
        }
        uploadDataAttachments(key:key, attachments: datas, count:0, completion: completion)
    }
    
    internal func uploadDataAttachments(key:String, attachments:[(name:String, data:Data, mimeType:String)], count:Int, completion: @escaping (_ error:String?,_ key:String?) -> Void){
        if count >= attachments.count {
            completion(nil, key)
        }else{
            let attachment = attachments[count]
            self.postAttachment(key: key, data: attachment, completion: { (error, keyStr) in
                self.uploadDataAttachments(key: key, attachments: attachments, count: (count + 1), completion: completion)
            })
        }
    }
    
    internal func postAttachment(key:String, data:(name:String, data:Data, mimeType:String), completion: @escaping (_ error:String?,_ key:String?) -> Void)
    {
        let url = URL(string: "\(host!)/rest/api/2/issue/\(key)/attachments")!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("nocheck", forHTTPHeaderField: "X-Atlassian-Token")
        
        request.httpMethod = "POST"
        
        let boundary = generateBoundaryString()
        
        //define the multipart request type
        
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let attachmentData = data.data
        
        let body = NSMutableData()
        
        let fname = data.name
        let mimetype = data.mimeType
        
        //define the data post parameter
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"file\"; filename=\"\(fname)\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(attachmentData)
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using:String.Encoding.utf8)!)
        
        let outputData = body as Data
        request.httpBody = outputData
        
        let task = session().dataTask(with:request) { data, response, error in
            
            if let _ = response as? HTTPURLResponse {
                do {
                    let _ = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)  as? NSDictionary
                    completion(nil, key)
                } catch {
                    print("error serializing JSON: \(error)")
                    completion("error serializing JSON: \(error)", nil)
                }
            }else{
                completion("error connecting to JIRA no attachment uploaded", nil)
            }
        }
        
        task.resume()
    }
    
    internal func createMeta(_ completion: @escaping (_ error:Bool, _ request:ServiceDeskRequest?) -> Void){
        /*if let cachedData = UserDefaults.standard.data(forKey: "JIRA_CREATEMETA_CACHE") {
            processCreateMetaData(cachedData, completion: completion)
            return
        }*/
        guard let host = self.host, let serviceDeskId = self.serviceDeskId, let requestTypeId = requestTypeId else {
            return
        }
        var urlString = ServiceDesk.url_request_metadata
        urlString = urlString.replacingOccurrences(of: "[SERVICE_DESK_ID]", with: serviceDeskId)
        
         urlString = urlString.replacingOccurrences(of: "[REQUEST_TYPE_ID]", with: requestTypeId)
        let url = URL(string: "\(host)\(urlString)")!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        let task = session().dataTask(with:request) { data, response, error in
            if let _ = response as? HTTPURLResponse {
                do {
                    guard let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)  as? [AnyHashable:Any] else{
                        DispatchQueue.main.async {
                            completion(false,nil)
                        }
                        return
                    }
                    
                    
                    //UserDefaults.standard.set(data!, forKey: "JIRA_CREATEMETA_CACHE")
                    //UserDefaults.standard.synchronize()
                    let serviceDesk  = ServiceDeskRequest()
                    serviceDesk.applyData(data: json)
                    DispatchQueue.main.async {
                        completion(true, serviceDesk)
                    }
                } catch {
                    print("error serializing JSON: \(error)")
                    DispatchQueue.main.async {
                        completion(false,nil)
                    }
                }
            }
        }
        task.resume()
    }
    
    public func generateBoundaryString() -> String
    {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    public func getFullImage()->UIImage{
        let window: UIWindow! = UIApplication.shared.keyWindow
        
        return window.capture()
    }
}

//
//  SampleCloudService.swift
//  Cirrent
//
//  Created by PSIHPOK on 1/9/17.
//  Copyright © 2017 PSIHPOK. All rights reserved.
//


public class SampleDevice {
    var deviceID:String!
    var friendlyName:String!
    var name:String!
    var imageURL:String!
}

@objc public enum LOGIN_RESULT_ : Int {
    case SUCCESS
    case FAILED
}

@objc public enum BOUND_DEVICES_RESULT_ : Int {
    case SUCCESS
    case FAILED_NO_DEVICE
    case FAILED_UNEXPECTED_RESPONSE
}

@objc public enum COMPLETION_RESULT_ : Int {
    case SUCCESS
    case NOT_LOGGED_IN
    case INVALID_DEVICE_ID
    case ERROR
}

public typealias LOGIN_RESULT = LOGIN_RESULT_
public typealias BOUND_DEVICES_RESULT = BOUND_DEVICES_RESULT_
public typealias COMPLETION_RESULT = COMPLETION_RESULT_

public typealias LoginCompletionHandler = (LOGIN_RESULT) -> Void
public typealias GetBoundDevicesCompletionHandler = (BOUND_DEVICES_RESULT, [SampleDevice]?) -> Void
public typealias BindCompletionHandler = (String?, COMPLETION_RESULT) -> Void
public typealias ResetCompletionHandler = (String?, COMPLETION_RESULT) -> Void
public typealias GetTokenCompletionHandler = (String?, COMPLETION_RESULT) -> Void

class SampleCloudService {

    static let sharedService:SampleCloudService = SampleCloudService()
    
    private let tokenURL = "https://go.cirrent.com/cloud/token/search"
    private let apiURL = "https://go.cirrent.com/cloud/"
    private let loginURL = "https://go.cirrent.com/api/login"
    
    private static let LOGGED_KEY = "logged_before_key"
    private static let OWNERID_KEY = "owner_id_key"
    private static let ID_ACCOUNT_KEY = "idaccount_key"
    private static let USERNAME_KEY = "username_key"
    private static let PASSWORD_KEY = "password_key"
    
    static let MANAGE_TOKEN_SCOPE = "manage"
    static let SEARCH_TOKEN_SCOPE = "search"
    static let BIND_TOKEN_SCOPE = "bind"
    
    var username:String? {
        get {
            let name = UserDefaults.standard.string(forKey: SampleCloudService.USERNAME_KEY)
            return name
        }
        
        set (name) {
            UserDefaults.standard.set(name, forKey: SampleCloudService.USERNAME_KEY)
        }
    }
    
    var password:String? {
        get {
            let pass = UserDefaults.standard.string(forKey: SampleCloudService.PASSWORD_KEY)
            return pass
        }
        
        set (pass) {
            UserDefaults.standard.set(pass, forKey: SampleCloudService.PASSWORD_KEY)
        }
    }
    
    var bLogged:Bool {
        get {
            let bLogged = UserDefaults.standard.bool(forKey: SampleCloudService.LOGGED_KEY)
            return bLogged
        }
        
        set(logged) {
            UserDefaults.standard.set(logged, forKey: SampleCloudService.LOGGED_KEY)
        }
    }
    
    var ownerID:String? {
        get {
            let ownerID = UserDefaults.standard.string(forKey: SampleCloudService.OWNERID_KEY)
            return ownerID
        }
        
        set(id) {
            UserDefaults.standard.set(id, forKey: SampleCloudService.OWNERID_KEY)
        }
    }
    
    var accountID:String? {
        get {
            let accountID = UserDefaults.standard.string(forKey: SampleCloudService.ID_ACCOUNT_KEY)
            return accountID
        }
        
        set(id) {
            UserDefaults.standard.set(id, forKey: SampleCloudService.ID_ACCOUNT_KEY)
        }
    }
    
    var manage_token:String? = nil
    var search_token:String? = nil
    var bind_token:String? = nil
    var lastBoundDeviceID:String? = nil
    
    init() {
        
    }
    
    func login(username:String, password:String, completion: @escaping LoginCompletionHandler) {
        self.username = username
        self.password = password
        
        let encoded_username = username.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let encoded_password = password.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        
        let url = "\(loginURL)?username=\(encoded_username!)&password=\(encoded_password!)"
        
        sendPostRequest(url: url, completionHandler: {
            data, response, error in
            
            guard let data = data, error == nil else {
                LogService.sharedService.debug(data: "LOGIN-FAILED - CLOUD CONNECTION ERROR")
                completion(.FAILED)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                LogService.sharedService.debug(data: "LOGIN-FAILED - INVALID_STATUS:\(httpStatus.statusCode)")
                completion(.FAILED)
                return
            }
            
            let json = JSON(data: data)
            if json == nil {
                LogService.sharedService.debug(data: "LOGIN-FAILED - INVALID RESPONSE, NO JSON")
                completion(.FAILED)
                return
            }
            
            let user = json["data"]["user"]
            if user == nil {
                LogService.sharedService.debug(data: "LOGIN-FAILED - INVALID RESPONSE, JSON PARSE ERROR")
                completion(.FAILED)
                return
            }
            
            if user["idAccount"] == nil || user["idAccount"].stringValue == "" {
                LogService.sharedService.debug(data: "LOGIN-FAILED - INVALID ACCOUNT ID")
                completion(.FAILED)
                return
            }
            
            self.accountID = user["idAccount"].stringValue
            self.ownerID = username
            LogService.sharedService.debug(data: "LOGIN-SUCCESS")
            completion(.SUCCESS)
        })
    }
    
    func logOut() {
        username = nil
        password = nil
        ownerID = nil
        accountID = nil
        bLogged = false
    }
    
    func getBoundDevices(completion: @escaping GetBoundDevicesCompletionHandler) {
        let url = apiURL + "/devices"
        sendGetRequest(url: url, completionHandler: {
            data, response, error in
            
            guard let _ = data, error == nil else {
                LogService.sharedService.debug(data: "SampleCloud - Offline")
                completion(BOUND_DEVICES_RESULT.FAILED_UNEXPECTED_RESPONSE, nil)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode == 404 {
                LogService.sharedService.debug(data: "SampleCloud - Get Devices From Account - No devices")
                completion(BOUND_DEVICES_RESULT.FAILED_NO_DEVICE, nil)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                LogService.sharedService.debug(data: "SampleCloud - Get Devices From Account - INVALID_STATUS:\(httpStatus.statusCode)")
                completion(BOUND_DEVICES_RESULT.FAILED_UNEXPECTED_RESPONSE, nil)
                return
            }
            
            let str = String(data: data!, encoding: .utf8)
            print("SampleCloud: get devices returned ", str!)
            
            let jsonData:JSON = JSON(data: data!)
            self.manage_token = jsonData["manage_token"].stringValue
            let jsonArray = jsonData["devices"]
            
            var deviceArray:[SampleDevice] = [SampleDevice]()
            for item in jsonArray {
                let device = self.getSampleDeviceFromJson(data: item.1)
                deviceArray.append(device)
            }
            
            if deviceArray.count == 0 {
                LogService.sharedService.debug(data: "SampleCloud - Get Devices From Account - NO_DEVICES")
                completion(BOUND_DEVICES_RESULT.FAILED_NO_DEVICE, nil)
            }
            else {
                LogService.sharedService.debug(data: "SampleCloud - Get Devices From Account Success")
                completion(BOUND_DEVICES_RESULT.SUCCESS, deviceArray)
            }
        })
    }
    
    public func getToken(tokenType:TOKEN_TYPE, deviceID:String?, completion:@escaping (_ token:String?) -> Void) {
        if tokenType == .SEARCH {
            if search_token == nil {
                getSearchToken(completion: {
                    token, response in
                    
                    if response != .SUCCESS {
                        completion(nil)
                    }
                    else {
                        completion(self.search_token)
                    }
                })
            }
            else {
                completion(self.search_token)
            }
        }
        else if tokenType == .BIND {
            // clear the bind token if this is a new device ID
            if (deviceID != lastBoundDeviceID) {
                print("Clearing bind token")
                bind_token == nil
            }
            
            if bind_token == nil && deviceID != nil {
                bindDevice(deviceID: deviceID!, friendlyName: nil, completion: {
                    token, response in
                    
                    if response != .SUCCESS {
                        print("In SampleCloud, bind failed so no token")
                        completion(nil)
                    }
                    else {
                        print("In SampleCloud, got a new bind token ", self.bind_token)
                        completion(self.bind_token)
                    }
                })
            }
            else {
                print("In SampleCloud, returning earlier bind token ", self.bind_token)
                completion(self.bind_token)
            }
        }
        else if tokenType == .MANAGE {
            if (manage_token == nil) {
                self.getBoundDevices(completion: {
                    response, deviceArray in
                    print("In SampleCloud, about to return manage token", self.manage_token)
                    completion(self.manage_token)
                })
            } else {
                print("Returning earlier manage token", manage_token)
                completion(manage_token)
            }
        }
        else {
            if search_token != nil {completion(search_token)}
            else if bind_token != nil {completion(bind_token)}
            else {completion(manage_token)}
        }
    }
    
    public func bindDevice(deviceID:String, friendlyName:String?, completion: @escaping BindCompletionHandler) {
        let url = apiURL + "/bind/" + deviceID
        var params:[String:AnyObject] = [:]
        if friendlyName != nil && friendlyName! != "" {
            params = ["friendly_name" : friendlyName! as AnyObject]
        }
        
        sendPostRequest(url: url, parameters: params, completionHandler: {
            data, response, error in
            guard let _ = data, error == nil else {
                completion(nil, .ERROR)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                if httpStatus.statusCode == 401 {
                    LogService.sharedService.debug(data: "SampleCloud - Bind Device Failed - NOT_LOGGED_IN")
                    completion(nil, .NOT_LOGGED_IN)
                }
                else if httpStatus.statusCode == 404 {
                    LogService.sharedService.debug(data: "SampleCloud - Bind Device Failed - INVALID_DEVICE_ID")
                    completion(nil, .INVALID_DEVICE_ID)
                }
                else {
                    LogService.sharedService.debug(data: "SampleCloud - Bind Device Failed - INVALID_STATUS:\(httpStatus.statusCode)")
                    completion(nil, .ERROR)
                }
                return
            }
            
            let str = String(data: data!, encoding: .utf8)
            print("SampleCloud: bind returned ", str!)
            
            let jsonData = JSON(data: data!)
            
            self.bind_token = jsonData["token"].stringValue
            self.lastBoundDeviceID = deviceID

            // Clear manage token (as device list has changed)
            print("Clearing manage token as have bound device")
            self.manage_token = nil
            let logStr = "Type=BIND;value=" + self.bind_token!
            LogService.sharedService.log(event: .TOKEN_RECEIVED, data: logStr)
            LogService.sharedService.debug(data: "SampleCloud - Bound Device - deviceID=\(deviceID)")
            completion(self.bind_token, .SUCCESS)
        })
    }
    
    public func resetDevice(deviceID:String, completion: @escaping ResetCompletionHandler) {
        let url = apiURL + "/reset/" + deviceID
        
        sendDeleteRequest(url: url, completionHandler: {
            data, response, error in
            
            guard let _ = data, error == nil else {
                LogService.sharedService.log(event: .CLOUD_CONNECTION_ERROR, data: "")
                completion(nil, .ERROR)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                if httpStatus.statusCode == 401 {
                    LogService.sharedService.debug(data: "SampleCloud - Reset Device Failed - INVALID_TOKEN")
                    completion(nil, .ERROR)
                }
                else if httpStatus.statusCode == 404 {
                    LogService.sharedService.debug(data: "SampleCloud - Reset Device Failed - INVALID_DEVICE_ID")
                    completion(nil, .INVALID_DEVICE_ID)
                }
                else {
                    LogService.sharedService.debug(data: "SampleCloud - Reset Device Failed - INVALID_STATUS:\(httpStatus.statusCode)")
                    completion(nil, .ERROR)
                }
                return
            }
            
            let str = String(data: data!, encoding: .utf8)
            print("SampleCloud: reset returned ", str!)

            LogService.sharedService.debug(data: "SampleCloud - Reset Device - deviceID=\(deviceID)")
            completion(self.manage_token, .SUCCESS)
        })
    }
    
    private func getSearchToken(completion: @escaping GetTokenCompletionHandler) {
        sendGetRequest(url: tokenURL, completionHandler: {
            data, response, error in
            guard let data = data, error == nil else {
                LogService.sharedService.log(event: .TOKEN_ERROR, data: "Error=NO_RESPONSE")
                completion(nil, .ERROR)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                if httpStatus.statusCode == 401 {
                    LogService.sharedService.debug(data: "SampleCloud - Get Search Token Failed - NOT_LOGGED_IN")
                    completion(nil, .NOT_LOGGED_IN)
                }
                else {
                    LogService.sharedService.debug(data: "SampleCloud - Get Search Token Failed - INVALID_STATUS:\(httpStatus.statusCode)")
                    completion(nil, .ERROR)
                }
                return
            }
            
            let str = String(data: data, encoding: .utf8)
            print("SampleCloud: get token returned ", str!)

            let json = JSON(data: data)
            let token:String = String(describing: json["token"])
            self.search_token = token
            
            let logStr = "Type=SEARCH;value=" + token
            LogService.sharedService.log(event: .TOKEN_RECEIVED, data: logStr)
            completion(self.search_token, .SUCCESS)
        })
    }
    
    private func getSampleDeviceFromJson(data:JSON) -> SampleDevice {
        let device = SampleDevice()
        
        device.deviceID = data["cirrent_device_id"].stringValue
        device.friendlyName = data["friendly_name"].stringValue
        device.name = data["device_type_name"].stringValue
        device.imageURL = data["device_type_image"].stringValue
        
        return device
    }
    
    private func sendGetRequest(url: String, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let requestURL = URL(string:url)!
        var request = URLRequest(url: requestURL)
        request.httpMethod = "GET"
        request.setValue("Basic \(getAuthenticationString())", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: completionHandler)
        task.resume()
    }
    
    private func sendPostRequest(url: String, parameters: [String: AnyObject], completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let parameterString = parameters.stringFromHttpParameters()
        var request = URLRequest(url: URL(string: url)!)
        
        request.httpBody = parameterString.data(using: .utf8)
        request.httpMethod = "POST"
        request.setValue("Basic \(getAuthenticationString())", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: completionHandler)
        task.resume()
    }
    
    private func sendPostRequest(url: String, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        let task = URLSession.shared.dataTask(with: request, completionHandler: completionHandler)
        task.resume()
    }
    
    private func sendDeleteRequest(url:String, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "DELETE"
        request.setValue("Basic \(getAuthenticationString())", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request, completionHandler: completionHandler)
        task.resume()
    }
    
    private func getAuthenticationString() -> String {
        if username == nil || password == nil {
            return ""
        }
        
        let loginString = String(format: "%@:%@", username!, password!)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        return base64LoginString
    }
}

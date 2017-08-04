//
//  api.swift
//  ios
//
//  Created by Brandon Price on 8/3/17.
//  Copyright © 2017 Brandon Price. All rights reserved.
//

import Foundation

class API {
    
    // ROOT URL
    //static let environment = ProcessInfo().environment["ENV"] == nil ? "production" : ProcessInfo().environment["ENV"]!
    //static let rootURLString : String = environment != "development" ? "https://chatter-" + environment + ".herokuapp.com/" : "http://127.0.0.1:8080/"
    static let rootURLString : String = "http://127.0.0.1:8080/"
    
    // Users
    
    class func createUser(firstName: String, lastName: String, completion_handler: @escaping (URLResponse, Contact?) -> Void) {
        
        let json = ["first_name" : firstName, "last_name" : lastName]
        
        // Perform request.
        API.perform_request(request_type: "POST", url_path: "users", json: json, token: nil, completion_handler: {
            (response, data) in
            
            if let _ = data as? URLResponse {
                return completion_handler(URLResponse.ServerDown, nil)
            }
            
            if response == nil {
                return completion_handler(URLResponse.NotConnected, nil)
            }
            
            let data = data as! [String : Any]
            if data["error"] != nil {
                return completion_handler(URLResponse.Error, nil)
            }
            
            let user = data["user"] as! [String : String]
            let contact = Contact(firstName: user["first_name"]!, lastName: user["last_name"]!, id: user["_id"]!)
            completion_handler(URLResponse.Success, contact)
        })
    }
    
    // Chats
    class func getUsersChats(userId: String, completion_handler: @escaping (URLResponse, Contact?) -> Void) {
        
    }
    
    // HELPERS
    class func perform_request(request_type: String, url_path: String, json: [String: Any]?, token: String?,completion_handler: @escaping (HTTPURLResponse?, Any?) -> Void) {
        
        // Make url request.
        var request = URLRequest(url: URL(string: API.rootURLString + url_path)!)
        request.httpMethod = request_type
        if request_type == "POST" {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        // If json is not nil add it to the request.
        if json != nil {
            let jsonData = try? JSONSerialization.data(withJSONObject: json!)
            request.httpBody = jsonData
        }
        
        // If token is not nil, add it to the request.
        if token != nil {
            request.setValue("Token " + token!, forHTTPHeaderField: "Authorization")
        }
        
        // Perform request.
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) {
            
            (data, response, error) in
            
            DispatchQueue.main.async {
                
                // Handle errors.
                if (error != nil) {
                    
                    if error!.localizedDescription == "Could not connect to the server." {
                        print("couldnt connect to server")
                        return DispatchQueue.main.async {
                            completion_handler(nil, URLResponse.ServerDown)
                        }
                    }
                    
                    return DispatchQueue.main.async {
                        completion_handler(nil, nil)
                    }
                }
                
                if let http_response = response as? HTTPURLResponse {
                    
                    var json_response : Any?
                    
                    do {
                        json_response = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                    } catch {
                        json_response = nil
                    }
                    
                    return DispatchQueue.main.async {
                        completion_handler(http_response, json_response)
                    }
                }
                
            }
        }
        task.resume()
    }
}

enum URLResponse {
    case Success
    case ServerDown
    case Error
    case NotConnected
}

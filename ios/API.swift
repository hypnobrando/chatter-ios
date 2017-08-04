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
    
    class func createUser(firstName: String, lastName: String, completionHandler: @escaping (URLResponse, Contact?) -> Void) {
        let json = ["first_name" : firstName, "last_name" : lastName]
        
        // Perform request.
        API.performRequest(requestType: "POST", urlPath: "users", json: json, token: nil, completionHandler: {
            (response, data) in
            
            if let _ = data as? URLResponse {
                return completionHandler(URLResponse.ServerDown, nil)
            }
            
            if response == nil {
                return completionHandler(URLResponse.NotConnected, nil)
            }
            
            let data = data as! [String : Any]
            if data["error"] != nil {
                return completionHandler(URLResponse.Error, nil)
            }
            
            let userJson = data["user"] as! [String : String]
            let contact = Contact.deserialize(json: userJson)
            completionHandler(URLResponse.Success, contact)
        })
    }
    
    // Chats
    class func getUsersChats(userId: String, completionHandler: @escaping (URLResponse, [Chat]?) -> Void) {
        API.performRequest(requestType: "GET", urlPath: "users/" + userId + "/chats", json: nil, token: nil, completionHandler: {
            (response, data) in
            
            if let _ = data as? URLResponse {
                return completionHandler(URLResponse.ServerDown, nil)
            }
            
            if response == nil {
                return completionHandler(URLResponse.NotConnected, nil)
            }
            
            let data = data as! [String : Any]
            if data["error"] != nil {
                return completionHandler(URLResponse.Error, nil)
            }
            
            let chatsJson = data["chats"] as! [[String : Any]]
            let chats = chatsJson.map({ (chat) -> Chat in Chat.deserialize(json: chat)})
            completionHandler(URLResponse.Success, chats)
        })
    }
    
    // Messages
    
    class func getChatMessages(chatId: String, completionHandler: @escaping (URLResponse, Chat?) -> Void) {
        API.performRequest(requestType: "GET", urlPath: "chats/" + chatId + "/messages", json: nil, token: nil, completionHandler: {
            (response, data) in
            
            if let _ = data as? URLResponse {
                return completionHandler(URLResponse.ServerDown, nil)
            }
            
            if response == nil {
                return completionHandler(URLResponse.NotConnected, nil)
            }
            
            let data = data as! [String : Any]
            if data["error"] != nil {
                return completionHandler(URLResponse.Error, nil)
            }
            
            let chatJson = loadMessageFromData(data: data)

            let chat = Chat.deserialize(json: chatJson)
            
            completionHandler(URLResponse.Success, chat)
        })
    }
    
    class func createMessage(userId: String, chatId: String, message: String, completionHandler: @escaping (URLResponse, Chat?) -> Void) {
        let json = ["message": message]
        
        API.performRequest(requestType: "POST", urlPath: "users/" + userId + "/chats/" + chatId + "/messages", json: json, token: nil, completionHandler: {
            (response, data) in
            
            if let _ = data as? URLResponse {
                return completionHandler(URLResponse.ServerDown, nil)
            }
            
            if response == nil {
                return completionHandler(URLResponse.NotConnected, nil)
            }
            
            let data = data as! [String : Any]
            if data["error"] != nil {
                return completionHandler(URLResponse.Error, nil)
            }
            
            let chatJson = loadMessageFromData(data: data)
            let chat = Chat.deserialize(json: chatJson)
            
            completionHandler(URLResponse.Success, chat)
        })
    }
    
    // HELPERS
    
    class func loadMessageFromData(data: [String : Any]) -> [String : Any] {
        let messagesJson = data["messages"] as! [[String : Any]]
        var chatJson = data["chat"] as! [String : Any]
        let usersJson = data["users"] as! [[String : Any]]
        chatJson["messages"] = messagesJson
        chatJson["users"] = usersJson
        
        return chatJson
    }
    
    class func performRequest(requestType: String, urlPath: String, json: [String: Any]?, token: String?, completionHandler: @escaping (HTTPURLResponse?, Any?) -> Void) {
        
        // Make url request.
        var request = URLRequest(url: URL(string: API.rootURLString + urlPath)!)
        request.httpMethod = requestType
        if requestType == "POST" {
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
                            completionHandler(nil, URLResponse.ServerDown)
                        }
                    }
                    
                    return DispatchQueue.main.async {
                        completionHandler(nil, nil)
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
                        completionHandler(http_response, json_response)
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

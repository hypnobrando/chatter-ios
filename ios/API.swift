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
    //static let environment = ProcessInfo().environment["ENV"] == nil ? "development" : ProcessInfo().environment["ENV"]!
    //static let rootURLString : String = environment == "development" ? "http://127.0.0.1:8080/" : ProcessInfo().environment["URL"]!
    static let environment = ENV
    static let rootURLString = CHATTER_URL
    
    class func createUser(firstName: String, lastName: String, apnToken: String, completionHandler: @escaping (URLResponse, Contact?) -> Void) {
        let json = ["first_name" : firstName, "last_name" : lastName, "apn_token" : apnToken]

        // Perform request.
        API.performRequest(requestType: "POST", urlPath: "users", json: json, token: nil, completionHandler: {
            (response, data) in
            
            handleResponse(response: response, data: data, completionHandler: {
                response, json in
                
                if response != URLResponse.Success {
                    return completionHandler(response, nil)
                }
                
                let userJson = json!["user"] as! [String : String]
                let contact = Contact.deserialize(json: userJson)
                completionHandler(URLResponse.Success, contact)
            })
        })
    }
    
    // Chats
    class func getUsersChats(userId: String, completionHandler: @escaping (URLResponse, [Chat]?) -> Void) {
        API.performRequest(requestType: "GET", urlPath: "users/\(userId)/chats", json: nil, token: nil, completionHandler: {
            (response, data) in
            
            handleResponse(response: response, data: data, completionHandler: {
                response, json in
                
                if response != URLResponse.Success {
                    return completionHandler(response, nil)
                }
                
                let chatsJson = json!["chats"] as! [[String : Any]]
                let chats = chatsJson.map({ (chat) -> Chat in Chat.deserialize(json: chat)})
                completionHandler(URLResponse.Success, chats)
            })
        })
    }
    
    // Messages
    
    class func getChatMessages(chatId: String, completionHandler: @escaping (URLResponse, Chat?) -> Void) {
        API.performRequest(requestType: "GET", urlPath: "chats/\(chatId)/messages", json: nil, token: nil, completionHandler: {
            (response, data) in
            
            handleResponse(response: response, data: data, completionHandler: {
                response, json in
                
                if response != URLResponse.Success {
                    return completionHandler(response, nil)
                }
                
                let chatJson = loadMessageFromData(data: json!)
                let chat = Chat.deserialize(json: chatJson)
                completionHandler(URLResponse.Success, chat)
            })
        })
    }
    
    class func createMessage(userId: String, chatId: String, message: String, completionHandler: @escaping (URLResponse, Chat?) -> Void) {
        let json = ["message": message]
        
        API.performRequest(requestType: "POST", urlPath: "users/\(userId)/chats/\(chatId)/messages", json: json, token: nil, completionHandler: {
            (response, data) in
            
            handleResponse(response: response, data: data, completionHandler: {
                response, json in
                
                if response != URLResponse.Success {
                    return completionHandler(response, nil)
                }
                
                let chatJson = loadMessageFromData(data: json!)
                let chat = Chat.deserialize(json: chatJson)
                
                completionHandler(URLResponse.Success, chat)
            })
        })
    }
    
    class func createChat(userIds: [String], completionHandler: @escaping (URLResponse, Chat?) -> Void) {
        let json = ["user_ids": userIds]
        
        API.performRequest(requestType: "POST", urlPath: "chats", json: json, token: nil, completionHandler: {
            (response, data) in
            
            handleResponse(response: response, data: data, completionHandler: {
                response, json in
                
                if response != URLResponse.Success {
                    return completionHandler(response, nil)
                }
                
                let chat = Chat.deserialize(json: json!["chat"] as! [String : Any])
                completionHandler(URLResponse.Success, chat)
            })
        })
    }
    
    class func deleteUser(userId: String, completionHandler: @escaping (URLResponse) -> Void) {
        API.performRequest(requestType: "DELETE", urlPath: "users/\(userId)", json: nil, token: nil, completionHandler: {
            (response, data) in
            
            handleResponse(response: response, data: data, completionHandler: {
                response, _ in
                
                completionHandler(response)
            })
        })
    }
    
    class func patchUser(userId: String, firstName: String, lastName: String, completionHandler: @escaping (URLResponse, Contact?) -> Void) {
        let json = ["first_name": firstName, "last_name": lastName]
        API.performRequest(requestType: "PATCH", urlPath: "users/\(userId)", json: json, token: nil, completionHandler: {
            (response, data) in
            
            handleResponse(response: response, data: data, completionHandler: {
                response, json in
                
                if response != URLResponse.Success {
                    return completionHandler(response, nil)
                }
                
                let userJson = json!["user"] as! [String : String]
                let contact = Contact.deserialize(json: userJson)
                completionHandler(URLResponse.Success, contact)
            })
        })
    }
    
    class func patchChat(userId: String, chatId: String, title: String, completionHandler: @escaping (URLResponse) -> Void) {
        let json = ["title": title]
        API.performRequest(requestType: "PATCH", urlPath: "users/\(userId)/chats/\(chatId)", json: json, token: nil, completionHandler: {
            (response, data) in
            
            handleResponse(response: response, data: data, completionHandler: {
                response, _ in
                
                completionHandler(response)
            })
        })
    }
    
    class func patchChatAddUsers(userId: String, chatId: String, userIdsToAdd: [String], completionHandler: @escaping (URLResponse, Chat?) -> Void) {
        let json = ["user_ids" : userIdsToAdd]
        API.performRequest(requestType: "PATCH", urlPath: "users/\(userId)/chats/\(chatId)/add_users", json: json, token: nil, completionHandler: {
            (response, data) in
            
            handleResponse(response: response, data: data, completionHandler: {
                response, json in
                
                if response != URLResponse.Success {
                    return completionHandler(response, nil)
                }
                
                let chat = Chat.deserialize(json: json!["chat"] as! [String : Any])
                completionHandler(URLResponse.Success, chat)
            })
        })
    }
    
    class func removeUserFromChat(userId: String, chatId: String, completionHandler: @escaping (URLResponse) -> Void) {
        API.performRequest(requestType: "DELETE", urlPath: "users/\(userId)/chats/\(chatId)", json: nil, token: nil, completionHandler: {
            (response, data) in
            
            handleResponse(response: response, data: data, completionHandler: {
                response, _ in

                completionHandler(response)
            })
        })
    }
    
    // HELPERS
    
    private class func handleResponse(response: HTTPURLResponse?, data: Any?, completionHandler: (URLResponse, [String : Any]?) -> Void) {
        if response == nil {
            return completionHandler(URLResponse.Error, nil)
        }
        
        switch response!.statusCode {
        case 500:
            return completionHandler(URLResponse.ServerError, nil)
        case 400:
            return completionHandler(URLResponse.Error, nil)
        default:
            break
        }
        
        if let json = data as? [String : Any] {
            if json["error"] != nil {
                return completionHandler(URLResponse.Error, nil)
            }
            
            return completionHandler(URLResponse.Success, json)
        }
        
        completionHandler(URLResponse.Error, nil)
    }
    
    private class func loadMessageFromData(data: [String : Any]) -> [String : Any] {
        let messagesJson = data["messages"] as! [[String : Any]]
        var chatJson = data["chat"] as! [String : Any]
        let usersJson = data["users"] as! [[String : Any]]
        chatJson["messages"] = messagesJson
        chatJson["users"] = usersJson
        
        return chatJson
    }
    
    private class func performRequest(requestType: String, urlPath: String, json: [String: Any]?, token: String?, completionHandler: @escaping (HTTPURLResponse?, Any?) -> Void) {
        
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
                    return completionHandler(nil, nil)
                }
                
                if let http_response = response as? HTTPURLResponse {
                    
                    var json_response : Any?
                    
                    do {
                        json_response = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                    } catch {
                        json_response = nil
                    }
                    
                    return completionHandler(http_response, json_response)
                }
                
            }
        }
        task.resume()
    }
}

enum URLResponse {
    case Success
    case ServerDown
    case ServerError
    case Error
    case NotConnected
}

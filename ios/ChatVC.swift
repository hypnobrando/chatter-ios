//
//  Chat.swift
//  ios
//
//  Created by Brandon Price on 8/2/17.
//  Copyright © 2017 Brandon Price. All rights reserved.
//
import UIKit
import JSQMessagesViewController

class ChatVC: JSQMessagesViewController {
    
    let INFO_BUTTON_WIDTH : CGFloat = 45.0
    let RIGHT_MARGIN : CGFloat = 10.0
    
    var chat = Chat()
    var messages = [JSQMessage]()
    var enc = Encryption()
    var sending = false
    
    var chatInfoButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load encryption from cache.
        enc = Encryption(chat: chat)
        
        // Remove notifications count.
        Cache.removeNotifications(chatId: chat.id)
        
        // Set up background.
        view.backgroundColor = UIColor.white
        title = chat.users.count > 2 ? "" : chat.ChatNameGivenUser(user: Cache.loadUser())
        
        // Setup chat info button.
        chatInfoButton = UIButton(frame: CGRect(x: navigationController!.navigationBar.bounds.maxX - INFO_BUTTON_WIDTH - RIGHT_MARGIN, y: navigationController!.navigationBar.bounds.maxY - INFO_BUTTON_WIDTH, width: INFO_BUTTON_WIDTH, height: INFO_BUTTON_WIDTH))
        chatInfoButton.backgroundColor = .clear
        chatInfoButton.setTitle("info", for: .normal)
        chatInfoButton.addTarget(self, action: #selector(chatInfoButtonPressed), for: .touchUpInside)
        navigationController!.navigationBar.addSubview(chatInfoButton)
        
        // Setup messages.
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        inputToolbar.contentView?.leftBarButtonItem = nil
        
        // Load messages
        pushSpinner(message: "", frame: view.frame)
        loadMessages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        chatInfoButton.alpha = 1.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func addMessage(withId id: String, name: String, text: String) {
        let message = JSQMessage(senderId: id, displayName: name, text: text)
        messages.append(message)
    }
    
    func loadMessages() {
        API.getChatMessages(userId: Cache.loadUser().id, chatId: self.chat.id, completionHandler: {
            (response, chat) -> Void in
            self.removeSpinner()
            if response != URLResponse.Success {
                return
            }
                
            self.chat = chat!
            self.messages = self.chat.messages.map({
                (message) -> JSQMessage in
                JSQMessage(senderId: message.user.id, senderDisplayName: message.user.fullName(), date: message.timeStamp, text: self.enc.decrypt(message: message.message))
            })
            self.collectionView?.reloadData()
            self.finishReceivingMessage()
            
            // Set collection view inset top because JSQMessageVC is fucking buggy (only if there are <= than 10 messages...).
            let extra : CGFloat = self.messages.count <= 10 ? self.navigationController!.navigationBar.frame.height + 16.0 : 0.0
            self.collectionView?.contentInset.top = extra
        })
    }
    
    // JSQMessageViewController
    
    override func senderId() -> String {
        return Cache.loadUser().stringID()
    }
    
    override func senderDisplayName() -> String {
        return Cache.loadUser().fullName()
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageDataForItemAt indexPath: IndexPath) -> JSQMessageData {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageBubbleImageDataForItemAt indexPath: IndexPath) -> JSQMessageBubbleImageDataSource? {
        let message = messages[indexPath.item]
        if message.senderId == senderId() {
            return setupOutgoingBubble()
        } else {
            return setupIncomingBubble()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        
        if message.senderId == senderId() {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
        }
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath) -> NSAttributedString?
    {
        let message = messages[indexPath.item]
        
        if message.senderId == senderId() {
            return nil
        } else {
            
            return NSAttributedString(string: message.senderDisplayName)
            
        }
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForMessageBubbleTopLabelAt indexPath: IndexPath) -> CGFloat {
        
        let message = messages[indexPath.item]
        
        if message.senderId == senderId() {
            return 0.0
        } else {
            
            return 17.0
            
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, avatarImageDataForItemAt indexPath: IndexPath) -> JSQMessageAvatarImageDataSource? {
        return nil
    }
    
    override func didPressSend(_ button: UIButton, withMessageText text: String, senderId: String, senderDisplayName: String, date: Date) {
        if sending {
            return
        }
        
        // Send message to backend.
        sending = true
        self.addMessage(withId: senderId, name: senderDisplayName, text: text)
        self.finishSendingMessage()
        
        let encrypted = enc.encrypt(message: text)
        API.createMessage(userId: senderId, chatId: chat.id, message: encrypted, completionHandler: {
            (response, _) in
            self.sending = false
            
            if response != URLResponse.Success {
                self.pushAlertView(title: "Error", message: "Check your internet connection.")
                self.loadMessages()
                return
            }
        })
    }
    
    func chatInfoButtonPressed(sender: UIButton!) {
        chatInfoButton.alpha = 0.0
        
        let chatInfoVC = ChatInfoVC()
        chatInfoVC.chat = chat
        navigationController!.pushViewController(chatInfoVC, animated: true)
    }
    
    override func pushNotificationReceived(payload: [String:Any]) {
        if let type = payload["type"] as? String {
            if let chatId = payload["chat_id"] as? String {
                if chatId == self.chat.id {
                    if type == "new_message" || type == "users_added" {
                        loadMessages()
                    }
                }
            }
        }
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        chatInfoButton.removeFromSuperview()
    }
    
    /*
     // MARK: - Navigation
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

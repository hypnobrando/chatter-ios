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
    
    var chat = Chat()
    var messages = [JSQMessage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up background.
        view.backgroundColor = UIColor.white
        title = chat.getNamesExceptFor(user: cache().user)
        
        // Setup messages.
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        inputToolbar.contentView?.leftBarButtonItem = nil
        
        // Load messages
        loadMessages()
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
        API.getChatMessages(chatId: self.chat.id, completionHandler: {
            (response, chat) -> Void in
            
            if response != URLResponse.Success {
                print(response)
                return
            }
                
            self.chat = chat!
            self.messages = self.chat.messages.map({
                (message) -> JSQMessage in
                JSQMessage(senderId: message.user.id, senderDisplayName: message.user.fullName(), date: message.timeStamp, text:message.message)
            })
            self.collectionView?.reloadData()
            self.finishReceivingMessage()
            
            // Set collection view inset top because JSQMessageVC is fucking buggy.
            self.collectionView?.contentInset.top = (self.navigationController?.navigationBar.frame.height)! + 16.0
        })
    }
    
    // JSQMessageViewController
    
    override func senderId() -> String {
        return cache().user.stringID()
    }
    
    override func senderDisplayName() -> String {
        return cache().user.fullName()
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
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, avatarImageDataForItemAt indexPath: IndexPath) -> JSQMessageAvatarImageDataSource? {
        return nil
    }
    
    override func didPressSend(_ button: UIButton, withMessageText text: String, senderId: String, senderDisplayName: String, date: Date) {
        // TODO: Send message to backend.
        
        addMessage(withId: senderId, name: senderDisplayName, text: text)
        finishSendingMessage()
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

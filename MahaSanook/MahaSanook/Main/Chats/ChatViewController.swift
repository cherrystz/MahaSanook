//
//  ChatViewController.swift
//  MahaSanook
//
//  Created by Napassorn V. on 5/12/2563 BE.
//

import UIKit
import JSQMessagesViewController
import Firebase

class ChatViewController: JSQMessagesViewController {

    var messages = [JSQMessage]()
    let user = Auth.auth().currentUser!
    var receiver_id = String()
    var name = String()
    
    lazy var outgoingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }()

    lazy var incomingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        senderId = user.uid
        senderDisplayName = user.displayName
        navigationItem.title = name
        
        inputToolbar.contentView.leftBarButtonItem = nil
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero

        // Do any additional setup after loading the view.
        
        let query = Constants.refs.databaseChats.queryLimited(toLast: 10)

        _ = query.observe(.childAdded, with: { [weak self] snapshot in

            if  let data        = snapshot.value as? [String: String],
                let id          = data["sender_id"],
                let name        = data["name"],
                let text        = data["text"],
                let receiver    = data["receiver_id"],
                !text.isEmpty
            {
                if let message = JSQMessage(senderId: id, displayName: name, text: text)
                {
                    
                    guard let rv = self?.receiver_id else {
                        return
                    }
                    
                    guard let us = self?.user.uid else {
                        return
                    }
                    
                    guard (receiver == rv && id == us) ||
                        (receiver == us && id == rv) else {
                        return
                    }
                    self?.messages.append(message)

                    self?.finishReceivingMessage()
                }
            }
        })
    }
    
    
    // MARK: - Collection View
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData!
    {
        return messages[indexPath.item]
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource!
    {
        return messages[indexPath.item].senderId == senderId ? outgoingBubble : incomingBubble
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource!
    {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString!
    {
        return messages[indexPath.item].senderId == senderId ? nil : NSAttributedString(string: messages[indexPath.item].senderDisplayName)
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat
    {
        return messages[indexPath.item].senderId == senderId ? 0 : 15
    }
    
    // MARK: - Actions
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!)
    {
        let ref = Constants.refs.databaseChats.childByAutoId()

        let message = ["sender_id": senderId, "name": senderDisplayName, "text": text, "receiver_id": receiver_id]

        ref.setValue(message)

        finishSendingMessage()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

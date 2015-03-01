//
//  ViewController.swift
//  AsyncMessagesViewController
//
//  Created by Huy Nguyen on 17/02/15.
//  Copyright (c) 2015 Huy Nguyen. All rights reserved.
//

import UIKit

class ViewController: AsyncMessagesViewController {

    private let users: [User]
    private var currentUser: User? {
        return users.filter({$0.ID == self.dataSource.currentUserID()}).first
    }
    
    init() {
        var tempUsers = [User]()
        for i in 0..<5 {
            let avatarURL = LoremIpsum.URLForPlaceholderImageFromService(.LoremPixel, withSize: CGSizeMake(kAMMessageCellNodeAvatarImageSize, kAMMessageCellNodeAvatarImageSize))
            let user = User(ID: "user-\(i)", name: LoremIpsum.name(), avatarURL: avatarURL)
            tempUsers.append(user)
        }
        users = tempUsers
        
        super.init(dataSource: DefaultAsyncMessagesCollectionViewDataSource(currentUserID: users[0].ID))
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Change user", style: .Plain, target: self, action: "changeCurrentUser")
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        generateMessages()
    }
    
    override func didPressRightButton(sender: AnyObject!) {
        if let user = currentUser {
            let message = Message(
                contentType: kAMMessageDataContentTypeText,
                content: textView.text,
                date: NSDate(),
                sender: user)
            dataSource.collectionView(asyncCollectionView, insertMessages: [message]) {completed in
                self.scrollCollectionViewToBottom()
            }
        }
        super.didPressRightButton(sender)
    }

    private func generateMessages() {
        var messages = [Message]()
        for i in 0..<200 {
            let isTextMessage = arc4random_uniform(4) <= 2 // 75%
            let contentType = isTextMessage ? kAMMessageDataContentTypeText : kAMMessageDataContentTypeNetworkImage
            let content = isTextMessage
                ? LoremIpsum.wordsWithNumber((random() % 100) + 1)
                : LoremIpsum.URLForPlaceholderImageFromService(.LoremPixel, withSize: CGSizeMake(200, 200)).absoluteString

            let sender = users[random() % users.count]
            
            let previousMessage: Message? = i > 0 ? messages[i - 1] : nil
            let hasSameSender = sender.ID == previousMessage?.senderID() ?? false
            let date = hasSameSender ? previousMessage!.date().dateByAddingTimeInterval(5) : LoremIpsum.date()
            
            let message = Message(
                contentType: contentType,
                content: content,
                date: date,
                sender: sender)
            messages.append(message)
        }
        dataSource.collectionView(asyncCollectionView, insertMessages: messages, completion: nil)
    }
    
    func changeCurrentUser() {
        let otherUsers = users.filter({$0.ID != self.dataSource.currentUserID()})
        let newUser = otherUsers[random() % otherUsers.count]
        dataSource.collectionView(asyncCollectionView, updateCurrentUserID: newUser.ID)
    }

}

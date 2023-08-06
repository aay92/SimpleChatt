//
//  ChatViewController.swift
//  SimpleChat
//
//  Created by Aleksey Alyonin on 04.08.2023.
//

import UIKit
import MessageKit
import InputBarAccessoryView ///чтобы работать с кнопкой send в чате


///Sender - кто отправляет сообщение
struct Sender: SenderType {
    var senderId: String
    var displayName: String
}

///Message - само сообщение
struct Message: MessageType {
    var sender: MessageKit.SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKit.MessageKind
}

class ChatViewController: MessagesViewController {

    var chatID: String?
    var otherID: String?
    let service = Service.shared
    
    let selfSender = Sender(senderId: "1", displayName: "Me")
    let otherSender = Sender(senderId: "2", displayName: "Alex")
    var messages = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messages.append(Message(sender: selfSender, messageId: "1", sentDate: Date().addingTimeInterval(-11200), kind: .text("Привет")))
        messages.append(Message(sender: otherSender, messageId: "2", sentDate: Date().addingTimeInterval(-10200), kind: .text("Привет. Как дела?")))

        ///messagesCollectionView есть в классе MessagesViewController и мы можем обращаться к экземпляру данного класса
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self ///делегат кпопки send
        showMessageTimestampOnSwipeLeft = true ///показывать время по свайпу
    }

}

//MARK: - MessagesDisplayDelegate, MessagesLayoutDelegate, MessagesDataSource
extension ChatViewController: MessagesDisplayDelegate, MessagesLayoutDelegate, MessagesDataSource {
    
    ///currentSender - тот кто сейчас главный
    func currentSender() -> MessageKit.SenderType {
        return selfSender
    }
    ///messageForItem - сообщения
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }

}

extension ChatViewController: InputBarAccessoryViewDelegate {
    ///didPressSendButtonWith - отпрака сообщения
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let msg = Message(sender: selfSender, messageId: "124", sentDate: Date(), kind: .text(text))
        messages.append(msg) /// messages.append добавляем сообщение в масси
        service.sendMessage(otherID: self.otherID, convID: self.chatID, text: text, message: msg) {[weak self] isSend in
            DispatchQueue.main.async {
                inputBar.inputTextView.text = nil ///отчищаем поле
                self?.messagesCollectionView.reloadDataAndKeepOffset() /// обновляем коллекциюмм messages.append
            }
        }
    }
}

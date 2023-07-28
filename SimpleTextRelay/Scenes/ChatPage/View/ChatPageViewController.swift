//
//  ChatPageViewController.swift
//  SimpleTextRelay
//
//  Created by Ronald Chester Whigan on 7/2/23.
//

import UIKit
import Quickblox

class ChatPageViewController: UIViewController {
    
    var selectedUser = QBUUser()
    var currentUser = QBUUser()
    
    var chatItems:[QBChatMessage] = []
    
    var privateDialog = QBChatDialog(dialogID: "", type: .private)
    
    @IBOutlet weak var messageFld: UITextField!
    @IBOutlet weak var chatTable: UITableView!
    
    let message = QBChatMessage()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentUser = QBSession.current.currentUser!
        print("Users: \(currentUser.id) - \(selectedUser.id)")
        QBChat.instance.addDelegate(self)
        let nib = UINib(nibName: "ChatTableViewCell", bundle: nil)
        chatTable.register(nib, forCellReuseIdentifier: "ChatTableViewCell")
        connectServer()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        createPrivateDialog()
        
    }
    
    func connectServer() {
        QBChat.instance.connect(withUserID: currentUser.id, password: currentUser.password!) { error in
            print("Connection Error: ",error as Any)
        }
    }
    
    /// Send Message Function
    @IBAction func sendMessage(_ sender: Any) {
        guard let messageText = messageFld.text else {
            return
        }
        let chatMessage = QBChatMessage()
        chatMessage.text = messageText
        chatMessage.customParameters["save_to_history"] = true
        print("Sending to Dialog ID: ", privateDialog)
        privateDialog.send(chatMessage, completionBlock: { (error) in
            if let error = error {
                print("Error sending message:", error.localizedDescription)
            } else {
                print("Message sent successfully",error?.localizedDescription ?? "")
                DispatchQueue.main.async {
                    self.chatItems.append(chatMessage)
                    self.chatTable.reloadData()
                    self.messageFld.text = ""
                }
            }
        })
    }
    
    
    func createPrivateDialog() {
        privateDialog = QBChatDialog(dialogID: nil, type: .private)
        privateDialog.occupantIDs = [currentUser.id as NSNumber, selectedUser.id as NSNumber] // Set the occupant IDs for the private dialog
        
        QBRequest.createDialog(self.privateDialog, successBlock: { (response, createdDialog) in
            DispatchQueue.main.async {
                self.privateDialog = createdDialog
                self.retrieveMessages(dialog: createdDialog)
            }
            print("Line 84, Created Dialog:", createdDialog)
        }, errorBlock: { (response) in
            print("Failed to create dialog:", response.error?.error?.localizedDescription ?? "")
        })
    }
    
    func retrieveMessages(dialog:QBChatDialog) {
        let page = QBResponsePage(limit: 100,skip: 1)
        let extendedRequest = ["sort_desc": "date_sent"]
        print("Retrieve messages from Dialog: ",dialog.id!)
        QBRequest.messages(withDialogID: dialog.id!, extendedRequest: extendedRequest, for: page, successBlock: { (response, messages, page) in
            if response.isSuccess {
                print("Line 96, Response: ",response)
                print("Line 97, Messages Retrieved: ",messages.count)
                DispatchQueue.main.async {
                    self.chatItems = messages
                    self.chatTable.reloadData()
                }
            }

        }, errorBlock: { (response) in
            print("Failed: ",response.description)
        })
    }
    
    @IBAction func backToDashboard() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
}

extension ChatPageViewController: QBChatDelegate {
    func chatRoomDidReceive(_ message: QBChatMessage, fromDialogID dialogID: String) {
        DispatchQueue.main.async {
            //Do something
        }
    }
    func chatDidReceive(_ message: QBChatMessage) {
        DispatchQueue.main.async {
            self.chatItems.append(message)
            self.chatTable.reloadData()
            //When receive go at bottom table
            print("Chats: ",self.chatItems)
        }
    }
}


extension ChatPageViewController: UITableViewDelegate {

}

extension ChatPageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        chatItems.count
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        10
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTableViewCell") as? ChatTableViewCell else { return  UITableViewCell()}
        let chat = chatItems[indexPath.section]
        cell.textLabel?.text = chat.text
        cell.textLabel?.textAlignment = chat.senderID == currentUser.id ? .right : .left
        cell.backgroundColor = chat.senderID == currentUser.id ? .systemBlue : .systemGreen
        cell.layer.cornerRadius = 20
        
        
        return cell
    }
}

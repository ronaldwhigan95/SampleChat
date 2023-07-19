//
//  QBService.swift
//  SimpleTextRelay
//
//  Created by Ronald Chester Whigan on 7/11/23.
//

import Foundation
import Quickblox

class QBService {
    static var shared = QBService()
    
    func qbInitialize() {
        let key = QBConstants()
        Quickblox.initWithApplicationId(key.appId, authKey: key.authKey, authSecret: key.authSecret, accountKey: key.acctKey)
        QBSettings.enableXMPPLogging()
        QBSettings.autoReconnectEnabled = true
        QBSettings.carbonsEnabled = true
        QBSettings.keepAliveInterval = 20
        QBSettings.streamManagementSendMessageTimeout = 0
        QBSettings.networkIndicatorManagerEnabled = false
    }
    
    func connect(withUser user: QBUUser,connectSuccess completion: @escaping ()->(),_ completionError: @escaping (Error)->()) {
        QBChat.instance.connect(withUserID: user.id, password: user.password!) { error in
            if let error = error {
                completionError(error)
            } else {
                completion()
            }
        }
    }
    
    func signIn(whenSuccess completion: @escaping ()->(),_ completionWithSignInError: @escaping (Error)->()) {
        //replace temp values later for textfield values
        QBRequest.logIn(withUserLogin: /*usernameFld.text!*/ "johnDoe", password: /*passwordFld.text!*/ "password", successBlock: { (response, user) in
            //Block with response and user instances if the request is succeeded.
            print("Success")
            QBChat.instance.connect(withUserID: user.id, password: user.password!) { error in
                completion()
            }
            
        }, errorBlock: { (response) in
            completionWithSignInError(response as! Error)
        })
    }
    
    func getCurrentUser() -> QBUUser {
        guard let curr = QBSession.current.currentUser else {return QBUUser()}
        return curr
    }
}

protocol SomeProtocol {
    func thisProtocol()
}

extension SomeProtocol {
    func thisProtocol() {
        //do something
    }
}

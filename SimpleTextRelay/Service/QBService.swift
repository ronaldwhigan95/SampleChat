//
//  QBService.swift
//  SimpleTextRelay
//
//  Created by Ronald Chester Whigan on 7/11/23.
//

import Foundation
import Quickblox

class QBService {
    
    ///Shared Instance of QBService
    static var shared = QBService()
    
    
    ///Initializes QuickBlox for whole application
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
    
    /// Connects user to Chat server
    /// - Parameters:
    ///   - user: Pass in the Current User
    ///   - completion: Add necessary actions when success
    ///   - completionError: Add error handling
    func connect(withUser user: QBUUser,connectSuccess completion: @escaping ()->(),_ completionError: @escaping (Error)->()) {
        QBChat.instance.connect(withUserID: user.id, password: user.password!) { error in
            if let error = error {
                completionError(error)
            } else {
                completion()
            }
        }
    }
    
    /// Signs In user / Login User
    /// - Parameters:
    ///   - completionHandler: Add QBService.shared.connect here
    func signIn(with user: String, password: String, completionHandler: @escaping (Result<QBUUser, QBResponse>)->()) {
        //replace temp values later for textfield values
        QBRequest.logIn(withUserLogin: user, password: password, successBlock: { (response, user) in
            //Block with response and user instances if the request is succeeded.
            print("Success")
            completionHandler(.success(user))
        }, errorBlock: { (response) in
//            let qbResponse = QBResponseError(response: response)
//            completionHandler(.failure(qbResponse))
            completionHandler(.failure(response))
        })
    }
    
    ///Gets current user
    func getCurrentUser() -> QBUUser {
        guard let curr = QBSession.current.currentUser else {return QBUUser()}
        return curr
    }
    
    ///Signs up user
    /// - TODO: Fix parameters if needed
//    func signUp(newUser: QBUUser, completionHandler: @escaping (QBUUser?, String)->()){
//        QBRequest.signUp(newUser, successBlock: { response, user in
//            completionHandler(user, "")
//        }, errorBlock: { (response) in
//            if let error = response.error?.description {
//                completionHandler(nil,error)
//            }
//        })
//    }
    func signUp(newUser: QBUUser, completionHandler: @escaping (Result<QBUUser,Error>)->()){
        QBRequest.signUp(newUser, successBlock: { response, user in
            completionHandler(.success(user))
        }, errorBlock: { (response) in
            completionHandler(.failure(response))
        })
    }
}

struct QBResponseError: Error {
    let response: QBResponse
}

extension QBResponse: Error {
    
}

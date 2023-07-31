//
//  QBService.swift
//  SimpleTextRelay
//
//  Created by Ronald Chester Whigan on 7/11/23.
//

import Foundation
import Quickblox

final class QBService {
    
    ///Shared Instance of QBService
    static var shared = QBService()
    
    lazy var jsonService = JsonService.shared
    let user = QBSession.current.currentUser
    
    ///Initializes QuickBlox for whole application
    static func qbInitialize() {
        let key = QBConstants()
        Quickblox.initWithApplicationId(key.appId, authKey: key.authKey, authSecret: key.authSecret, accountKey: key.acctKey)
        QBSettings.applicationID = key.appId
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
    func getCurrentUser() -> QBUUser? {
        guard let curr = QBSession.current.currentUser else {return nil}
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
    
    func getUserCustomData(user: QBUUser, completionHandler: (UserCustomData)->()) {
        jsonService.decode(to: UserCustomData.self, source: user.customData?.data(using: .utf8)) { data in
            completionHandler(data)
        }
    }
    
    func getUserBlob(user: QBUUser, completionHandler:@escaping (Data)->()) {
        QBRequest.blob(withID: user.blobID, successBlock: { (response, blob) in
            
            guard let blobUID = blob.uid else {return}
            QBRequest.downloadFile(withUID: blobUID, successBlock: { (response, fileData)  in
                completionHandler(fileData)
//                if let image = UIImage(data: fileData) {
//                    self.profilePicture.image = image
//                }
            }, statusBlock: { (request, status) in
                print("Image being downloaded:",status)
            }, errorBlock: { (response) in
                print("Failed to download Image:",response)
            })
            
        }, errorBlock: { (response) in
            print("Failed to get blobId:",response)
        })
    }
    
    func logoutUser(completionHandler: @escaping ()->()) {
        QBRequest.logOut(successBlock: { (response) in
            print("Successfully Logged out",response)
            QBChat.instance.disconnect { (error) in
                completionHandler()
            }
            ///Maybe not necessary
            //            QBRequest.destroySession(successBlock: { (response) in
            //                print("Detroyed Session: ",response)
            //            }, errorBlock: { (response) in
            //                print("Session Destruction Error:",response)
            //            })
        }, errorBlock: { (response) in
            print("Log out error:",response)
        })
    }
    
    func updateUser(updatedUserParams: QBUpdateUserParameters, successBlock: @escaping ()->()) {
        QBRequest.updateCurrentUser(updatedUserParams, successBlock: {response, user in
            // Completion handler after user update
            successBlock()
        }, errorBlock: { (response) in
            // Error handling for user update
        })
    }
    
    func updateUserCustomData(userData: UserCustomData,completionHandler: (String)->()) {
        jsonService.encode(from: userData) { jsonString in
            guard let string = jsonString else { return }
            completionHandler(string)
        }
    }
    
    func updateProfileImage(imgData: Data?,completion: @escaping () -> Void) {
        guard let imageData = imgData else {
            return
        }
        
        let fileName = "avatar.png"
        let contentType = "image/png"
        let isPublic = true
        QBRequest.tUploadFile(imageData, fileName: fileName, contentType: contentType, isPublic: isPublic, successBlock: { (response, uploadedBlob) in
            let parameters = QBUpdateUserParameters()
            parameters.blobID = uploadedBlob.id
            
            QBRequest.updateCurrentUser(parameters, successBlock: { (response, user) in
                print("Success Update of Profile Picture")
    
                completion()
            }, errorBlock: { (response) in
                print("Error on Update of Profile Picture")
                completion()
            })
            
        }, statusBlock: { (request, status) in
            print("Uploading Picture")
        }, errorBlock: { (response) in
            print("Error on upload")
            completion()
        })
    }
}

struct QBResponseError: Error {
    let response: QBResponse
}

extension QBResponse: Error {
    
}

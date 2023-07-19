//
//  LoginViewModel.swift
//  SimpleTextRelay
//
//  Created by Ronald Chester Whigan on 7/11/23.
//

import Foundation
import Quickblox

class LoginViewModel {
    let qbService = QBService.shared
    
    var existingUser: QBUUser?
    
    func signIn(username: String, password: String) {
        //replace temp values later for textfield values
        QBRequest.logIn(withUserLogin: /*usernameFld.text!*/ "johnDoe", password: /*passwordFld.text!*/ "password", successBlock: { (response, user) in
            
            self.existingUser = user
            self.connect()
            

        }, errorBlock: { (response) in
            if response.status.rawValue == 401  {
                self.signUp(username: username, password: password)
            } else {
                //show alerts for Error for network
                print("Print signIn(), respone: ")
            }
        })
    }
    
    func connect() {
        QBChat.instance.connect(withUserID: self.existingUser!.id, password: self.existingUser!.password!) { error in
            if let error = error {
                print("Error Connect() : ",error.localizedDescription)
            } else {
                print("Loging In again")
//                let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
//                guard let usersVc = storyboard.instantiateViewController(identifier: "UsersListViewController") as? UsersListViewController else {return}
//                usersVc.currentUser = self.existingUser!
//                self.navigationController?.pushViewController(usersVc, animated: true)
            }
        }
    }
    
    func signUp(username: String, password: String) {
        let user = QBUUser()
        user.login = username
        user.password = password


//        QBRequest.signUp(user, successBlock: { response, user in
//            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
//            guard let usersVc = storyboard.instantiateViewController(identifier: "UsersListViewController") as? UsersListViewController else {return}
//            usersVc.currentUser = self.existingUser!
//            self.navigationController?.pushViewController(usersVc, animated: true)
//        }, errorBlock: { (response) in
//
//        })
    }
    
//    func isValid() -> Bool {
//        if (!usernameFld.text!.isEmpty && !passwordFld.text!.isEmpty) {
//            //add more validation stuff
//            return true
//        } else {
//            return false
//        }
//    }
}

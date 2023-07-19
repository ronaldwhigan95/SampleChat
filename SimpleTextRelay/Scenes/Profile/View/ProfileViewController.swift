//
//  ProfileViewController.swift
//  SimpleTextRelay
//
//  Created by Ronald Chester Whigan on 7/18/23.
//

import UIKit
import Quickblox

class ProfileViewController: UIViewController {
    
    var currentUser: QBUUser?

    @IBOutlet weak var fullNameLbl: UILabel!
    @IBOutlet weak var loginLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var websiteLbl: UILabel!
    @IBOutlet weak var pictureView: UIView!
    @IBOutlet var profilePicture: UIImageView!
    @IBOutlet var imgBg: UIImageView!
    @IBOutlet weak var profileForm: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentUser = QBSession.current.currentUser
        
        fullNameLbl.text = currentUser?.fullName
        loginLbl.text = currentUser?.login
        emailLbl.text = currentUser?.email ?? "No Email"
        websiteLbl.text = currentUser?.website ?? "No Website"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        customImgBg()
        addCustomDesign()
        customPictureView()
    }
    
    func addCustomDesign() {
        profileForm.roundCorners(corners: [.topLeft,.topRight], radius: 20)
    }
    
    func customImgBg() {
        let bgImg = UIImage(named: "loginBg")
        imgBg = UIImageView(frame: UIScreen.main.bounds)
        imgBg.contentMode = .scaleAspectFill
        imgBg.clipsToBounds = true
        imgBg.image = bgImg
        self.view.addSubview(imgBg)
        self.view.sendSubviewToBack(imgBg)
        self.view.bringSubviewToFront(pictureView)
        self.view.bringSubviewToFront(profilePicture)
    }
    
    func customPictureView() {
        profilePicture.clipsToBounds = true
        profilePicture.contentMode = .scaleAspectFill
        profilePicture.layer.masksToBounds = true
        profilePicture.image = UIImage(named: "loginBg")
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width/2
        pictureView.layer.cornerRadius = pictureView.frame.size.width/2
        pictureView.clipsToBounds = true
        pictureView.backgroundColor = .lightGray
    }
    
    
    func logout() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        
        QBRequest.logOut(successBlock: { (response) in
            print("Logged out",response)
            QBChat.instance.disconnect { (error) in
                let loginVc = sb.instantiateViewController(identifier: "LoginViewController")
                
                UIApplication.shared.windows.first?.rootViewController = loginVc
                UIApplication.shared.windows.first?.makeKeyAndVisible()
            }
//
//            QBRequest.destroySession(successBlock: { (response) in
//                print("Detroyed Session: ",response)
//            }, errorBlock: { (response) in
//                print("Session Destruction Error:",response)
//            })
        }, errorBlock: { (response) in
            print("Log out error:",response)
        })
    }
}

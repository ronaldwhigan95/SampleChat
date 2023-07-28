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
    @IBOutlet weak var phoneNumber: UILabel!
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
        phoneNumber.text = currentUser?.phone ?? "No Phone Number"
        emailLbl.text = currentUser?.email ?? "No Email"
        websiteLbl.text = currentUser?.website ?? "No Website"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        customImgBg()
        addCustomDesign()
        customPictureView()
    }
    @IBAction func navigateToEditProfile(_ sender: Any) {
        goToEditProfile()
    }
    
    func addCustomDesign() {
        profileForm.roundCorners(corners: [.topLeft,.topRight], radius: 20)
    }
    
    func customImgBg() {
        imgBg = UIImageView(frame: UIScreen.main.bounds)
        imgBg.contentMode = .scaleAspectFill
        imgBg.clipsToBounds = true
        self.view.addSubview(imgBg)
        self.view.sendSubviewToBack(imgBg)
        self.view.bringSubviewToFront(pictureView)
        self.view.bringSubviewToFront(profilePicture)
    }
    
    func customPictureView() {
        profilePicture.layer.masksToBounds = true
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width/2
        pictureView.layer.cornerRadius = pictureView.frame.size.width/2
        pictureView.clipsToBounds = true
        pictureView.backgroundColor = .lightGray
    }
    
//    func getUserCustomData() {
//        if let data = curUser.customData?.data(using: .utf8),
//           let currentUserCustomData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : String]  {
//            self.curUserCustomData = currentUserCustomData
//        }
//    }
    
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
    
    func navigateTo<T:UIViewController>(withStoryboard storyboard: String, to identifier: String, class: T.Type) {
        let storyBoard = UIStoryboard.init(name: storyboard, bundle: nil)
        guard let viewController = storyBoard.instantiateViewController(identifier: identifier) as? T else {return}
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func goToEditProfile() {
        self.navigateTo(withStoryboard: "Main", to: "EditProfileViewController", class: EditProfileViewController.self)
    }
    
    
}

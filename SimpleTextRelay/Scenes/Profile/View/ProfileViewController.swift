//
//  ProfileViewController.swift
//  SimpleTextRelay
//
//  Created by Ronald Chester Whigan on 7/18/23.
//

import UIKit
import Quickblox

class ProfileViewController: UIViewController {
    @IBOutlet weak var fullNameLbl: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var websiteLbl: UILabel!
    @IBOutlet weak var pictureView: UIView!
    @IBOutlet var profilePicture: UIImageView!
    @IBOutlet var imgBg: UIImageView!
    @IBOutlet weak var profileForm: UIView!
    @IBOutlet weak var jobLbl: UILabel!
    @IBOutlet weak var dobLbl: UILabel!
    @IBOutlet weak var hobbiesLbl: UILabel!
    @IBOutlet weak var bioLbl: UILabel!
    
    var currentUser: QBUUser? = nil
    var currentUserCustomData: UserCustomData = UserCustomData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentUser = QBSession.current.currentUser
        getUserProfilePicture()
        getUserCustomData()
        fullNameLbl.text = currentUser?.fullName
        phoneNumber.text = currentUser?.phone ?? "No Phone Number"
        emailLbl.text = currentUser?.email ?? "No Email"
        websiteLbl.text = currentUser?.website ?? "No Website"
        jobLbl.text = currentUserCustomData.jobTitle ?? "Job not provided"
        dobLbl.text = currentUserCustomData.dob ?? "Date of Birth not provided"
        hobbiesLbl.text = currentUserCustomData.hobbies ?? "Hobbies not provided"
        bioLbl.text = currentUserCustomData.bio ?? "Bio not provided"
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
    
    func getChangedImage() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "EditProfileViewController") as? EditProfileViewController
        if vc?.selectedImage != nil {
            vc?.profilePictureTransferDelegate = self
        }
    }
    
    func getUserCustomData() {
        if let data = currentUser!.customData?.data(using: .utf8) {
            let decoder = JSONDecoder()
            do {
                let currentUserCustomData = try decoder.decode(UserCustomData.self, from: data)
                self.currentUserCustomData = currentUserCustomData
            } catch {
                print("Error decoding custom data: \(error)")
            }
        }
    }
    
    func getUserProfilePicture() {
        QBRequest.blob(withID: currentUser!.blobID, successBlock: { (response, blob) in
            
            guard let blobUID = blob.uid else {return}
            QBRequest.downloadFile(withUID: blobUID, successBlock: { (response, fileData)  in
                if let image = UIImage(data: fileData) {
                    self.profilePicture.image = image
                }
            }, statusBlock: { (request, status) in
                print("Image being downloaded:",status)
            }, errorBlock: { (response) in
                print("Failed to download Image:",response)
            })
            
        }, errorBlock: { (response) in
            print("Failed to get blobId:",response)
        })
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
    
    func navigateTo<T:UIViewController>(withStoryboard storyboard: String, to identifier: String, class: T.Type) {
        let storyBoard = UIStoryboard.init(name: storyboard, bundle: nil)
        guard let viewController = storyBoard.instantiateViewController(identifier: identifier) as? T else {return}
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func goToEditProfile() {
        getChangedImage()
        self.navigateTo(withStoryboard: "Main", to: "EditProfileViewController", class: EditProfileViewController.self)
    }
    
    
}

extension ProfileViewController: ProfilePictureDelegate {
    func imgChange(image: UIImage) {
        DispatchQueue.main.async {
            self.profilePicture.image = image
        }
    }
    
    
}


class CustomTextBorder {
    
}

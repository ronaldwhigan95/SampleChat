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
    
    let qbService = QBService.shared
    let navController = Navigation()
    
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
    
    @IBAction func logout(_ sender: Any) {
        logoutAccount()
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
        qbService.getUserCustomData(user: currentUser!) { data in
            self.currentUserCustomData = data
        }
    }
    
    func getUserProfilePicture() {
        qbService.getUserBlob(user: currentUser!) { data in
            if let image = UIImage(data: data) {
                self.profilePicture.image = image
            }
        }
    }
    
    func logoutAccount() {
        qbService.logoutUser {
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let loginVc = sb.instantiateViewController(identifier: "LoginViewController")
            
            UIApplication.shared.windows.first?.rootViewController = loginVc
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
    }

    func goToEditProfile() {
        getChangedImage()
        navController.navigateTo(withStoryboard: "Main", to: "EditProfileViewController", class: EditProfileViewController.self, navController: self.navigationController)
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

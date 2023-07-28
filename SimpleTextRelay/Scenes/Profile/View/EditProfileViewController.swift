//
//  EditProfileViewController.swift
//  SimpleTextRelay
//
//  Created by Ronald Chester Whigan on 7/20/23.
//

import UIKit
import Quickblox

class EditProfileViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var editForm: UIView!
    @IBOutlet weak var profilePictureContainer: UIView!
    @IBOutlet var imgBg: UIImageView!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet var profilePicture: UIImageView!
    @IBOutlet weak var fullNameFld: UITextField!
    @IBOutlet weak var emailFld: UITextField!
    @IBOutlet weak var phoneFld: UITextField!
    @IBOutlet weak var dobFld: UITextField!
    @IBOutlet weak var jobTitleFld: UITextField!
    @IBOutlet weak var websiteLinkFld: UITextField!
    @IBOutlet weak var bioFld: UITextField!
    @IBOutlet weak var hobbiesFld: UITextField!
    
    let imagePicker = UIImagePickerController()
    let updateUserParameters = QBUpdateUserParameters()
    
    var curUser = QBUUser()
    var curUserCustomData: UserCustomData = UserCustomData(dob: "", hobbies: "", bio: "", jobTitle: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        curUser = QBService.shared.getCurrentUser()
        getUserCustomData()
        setTextFieldValues()
        assignDelegates()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        customImgBg()
        addCustomDesign()
        customPictureView()
    }
    
    func addCustomDesign() {
        editForm.roundCorners(corners: [.topLeft,.topRight], radius: 20)
    }
    
    func customImgBg() {
        imgBg = UIImageView(frame: UIScreen.main.bounds)
        imgBg.contentMode = .scaleAspectFill
        imgBg.clipsToBounds = true
        self.view.addSubview(imgBg)
        self.view.sendSubviewToBack(imgBg)
        self.view.bringSubviewToFront(profilePictureContainer)
        self.view.bringSubviewToFront(profilePicture)
    }
    
    func customPictureView() {
        profilePicture.layer.masksToBounds = true
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width/2
        profilePictureContainer.layer.cornerRadius = profilePictureContainer.frame.size.width/2
        profilePictureContainer.clipsToBounds = true
        profilePictureContainer.backgroundColor = .lightGray
    }
    
    @IBAction func choosePhoto(_ sender: Any) {
        choosePhotoFromPicker()
    }
    @IBAction func updateProfile(_ sender: Any) {
        updateAlert()
    }
    
    func assignDelegates() {
        imagePicker.delegate = self
        fullNameFld.delegate = self
        emailFld.delegate = self
        phoneFld.delegate = self
        dobFld.delegate = self
        jobTitleFld.delegate = self
        websiteLinkFld.delegate = self
        bioFld.delegate = self
        hobbiesFld.delegate = self
    }
    //Add another condition when user reverts back to old values
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let fullNameText = fullNameFld.text, !fullNameText.isEmpty, curUser.fullName != fullNameText {
            updateUserParameters.fullName = fullNameText
            updateButton.isEnabled = true
        }

        if let emailText = emailFld.text, !emailText.isEmpty, curUser.email != emailText {
            updateUserParameters.email = emailText
            updateButton.isEnabled = true
        }

        if let phoneText = phoneFld.text, !phoneText.isEmpty, curUser.phone != phoneText {
            updateUserParameters.phone = phoneText
            updateButton.isEnabled = true
        }

        if let webText = websiteLinkFld.text, !webText.isEmpty, curUser.website != webText {
            updateUserParameters.website = webText
            updateButton.isEnabled = true
        }
        
        if let dobText = dobFld.text, !dobText.isEmpty, curUserCustomData.dob != dobText {
            curUserCustomData.dob = dobText
            updateButton.isEnabled = true
        }

        if let jobText = jobTitleFld.text, !jobText.isEmpty, curUserCustomData.jobTitle != jobText {
            curUserCustomData.jobTitle = jobText
            updateButton.isEnabled = true
        }

        if let bioText = bioFld.text, !bioText.isEmpty, curUserCustomData.bio != bioText {
            curUserCustomData.bio = bioText
            updateButton.isEnabled = true
        }

        if let hobbyText = hobbiesFld.text, !hobbyText.isEmpty, curUserCustomData.hobbies != hobbyText {
            curUserCustomData.hobbies = hobbyText
            updateButton.isEnabled = true
        }
    }


    
    ///TODO -
    func updateUser() {
        updateUserCustomData()
        QBRequest.updateCurrentUser(updateUserParameters, successBlock: {response, user in
            self.goToProfile()
        }, errorBlock: { (response) in
            
        })
    }
    
    func updateAlert() {
        
        let alert = UIAlertController(title: "Updating Profile", message: "Are you sure you want to update?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default,handler: { _ in
            self.updateUser()
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        present(alert,animated: true)
        
    }
    
    func choosePhotoFromPicker() {
        showProfilePhotoSource()
        
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker,animated: true)
    }
    
    func showProfilePhotoSource() {
        let alert = UIAlertController(title: "Select source", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default))
        alert.addAction(UIAlertAction(title: "Album", style: .default))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert,animated: true)
    }
    
    func updateUserCustomData() {
        let encoder = JSONEncoder()
        do {
            encoder.outputFormatting = .prettyPrinted
            let customJSONData = try encoder.encode(curUserCustomData)
            updateUserParameters.customData = String(data: customJSONData, encoding: .utf8)
        } catch {
            print("Error encoding custom data: \(error)")
            return
        }
    }
    
    func getUserCustomData() {
        if let data = curUser.customData?.data(using: .utf8) {
            let decoder = JSONDecoder()
            do {
                let currentUserCustomData = try decoder.decode(UserCustomData.self, from: data)
                self.curUserCustomData = currentUserCustomData
            } catch {
                print("Error decoding custom data: \(error)")
            }
        }
    }
    
    func setTextFieldValues() {
        fullNameFld.text = curUser.fullName
        if let curUserEmail = curUser.email {
            emailFld.text = curUserEmail
        }
        if let curUserPhone = curUser.phone {
            phoneFld.text = curUserPhone
        }
        if let curUserDob = curUserCustomData.dob {
            dobFld.text = curUserDob
        }
        if let curUserWebsite = curUser.website {
            websiteLinkFld.text = curUserWebsite
        }
        if let curUserJobTitle = curUserCustomData.jobTitle {
            jobTitleFld.text = curUserJobTitle
        }
        if let curUserBio = curUserCustomData.bio {
            bioFld.text = curUserBio
        }
        if let curUserHobbies = curUserCustomData.hobbies {
            hobbiesFld.text = curUserHobbies
        }
    }
    
    func updateProfileImage() {
        let image = UIImage(systemName: "person.circle")
        guard let imageData = image?.pngData() else {
            return
        }

        let fileName = "avatar.png"
        let contentType = "image/png"
        let isPublic = true
        QBRequest.tUploadFile(imageData, fileName: fileName, contentType: contentType, isPublic: isPublic, successBlock: { (response, uploadedBlob) in
            let parameters = QBUpdateUserParameters()
            parameters.blobID = uploadedBlob.id
            
            QBRequest.updateCurrentUser(parameters, successBlock: { (response, user) in
                
            }, errorBlock: { (response) in
                
            })
            
        }, statusBlock: { (request, status) in
            
        }, errorBlock: { (response) in
            
        })
    }
    
    func navigateTo<T:UIViewController>(withStoryboard storyboard: String, to identifier: String, class: T.Type){
        let storyBoard = UIStoryboard.init(name: storyboard, bundle: nil)
        guard let viewController = storyBoard.instantiateViewController(identifier: identifier) as? T else {return}
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func goToProfile() {
        self.navigateTo(withStoryboard: "Main", to: "ProfileViewController", class: ProfileViewController.self)
    }
}

extension EditProfileViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.editedImage] as? UIImage else {
            //Use during production/real project
            //return
            //development only use fatal error
            fatalError("Image invalid")
        }
        
        profilePicture.image = image
        
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

extension EditProfileViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.x = 0.0
    }
}

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
    let qbService = QBService.shared
    
    var curUser = QBUUser()
    var curUserCustomData: UserCustomData = UserCustomData(dob: "", hobbies: "", bio: "", jobTitle: "")
    var selectedImage: UIImage? = nil
    var didSelectPicture: Bool = false
    var profilePictureTransferDelegate: ProfilePictureDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        curUser = QBService.shared.getCurrentUser()!
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
        showProfilePhotoSource()
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
    
    
    func updateUser() {
        if didSelectPicture {
            let alert = updateAlertWithProfilePicture()
            present(alert, animated: true)
            updateProfileImage { [weak self] in
                self?.updateUserCustomData()
                self?.qbService.updateUser(updatedUserParams: self!.updateUserParameters, successBlock: {
                    alert.dismiss(animated: true)
                    self?.goToProfile()
                })
            }
        } else {
            updateUserCustomData()
            self.qbService.updateUser(updatedUserParams: updateUserParameters, successBlock: {
                self.profilePictureTransferDelegate?.imgChange(image: self.selectedImage!)
                self.goToProfile()
            })
        }
    }
    
    func updateAlertWithProfilePicture() -> UIAlertController {
        return UIAlertController(title: "Updating Profile", message: "Uploading image", preferredStyle: .alert)
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
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker,animated: true)
    }
    
    func showProfilePhotoSource() {
        let alert = UIAlertController(title: "Select source", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default))
        alert.addAction(UIAlertAction(title: "Album", style: .default, handler: { _ in
            self.choosePhotoFromPicker()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert,animated: true)
    }
    
    func updateUserCustomData() {
        qbService.updateUserCustomData(userData: curUserCustomData) { string in
            updateUserParameters.customData = string
        }
    }
    
    //Add to constructor
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
    
    //Add to constructor
    func getUserProfilePicture() {
        QBRequest.blob(withID: curUser.blobID, successBlock: { (response, blob) in
            
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
    
    func setTextFieldValues() {
        getUserProfilePicture()
        
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
    
    func updateProfileImage(completion: @escaping () -> Void) {
        qbService.updateProfileImage(imgData: selectedImage?.pngData(), completion: completion)
    }
    
    func navigateTo<T:UIViewController>(withStoryboard storyboard: String, to identifier: String, class: T.Type) {
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
        didSelectPicture = true
        profilePicture.image = image
        selectedImage = image
        updateButton.isEnabled = true
        
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


protocol ProfilePictureDelegate {
    func imgChange(image: UIImage)
}


///Redo for Error handling on func updateProfileImage
//        guard let imageData = selectedImage?.pngData() else {
//            return
//        }
//
//        let fileName = "avatar.png"
//        let contentType = "image/png"
//        let isPublic = true
//        QBRequest.tUploadFile(imageData, fileName: fileName, contentType: contentType, isPublic: isPublic, successBlock: { (response, uploadedBlob) in
//            let parameters = QBUpdateUserParameters()
//            parameters.blobID = uploadedBlob.id
//
//            QBRequest.updateCurrentUser(parameters, successBlock: { (response, user) in
//                print("Success Update of Profile Picture")
//                completion()
//            }, errorBlock: { (response) in
//                print("Error on Update of Profile Picture")
//                completion()
//            })
//
//        }, statusBlock: { (request, status) in
//            print("Uploading Picture")
//        }, errorBlock: { (response) in
//            print("Error on upload")
//            completion()
//        })

//
//  ViewController.swift
//  SimpleTextRelay
//
//  Created by Ronald Chester Whigan on 7/2/23.
//

import UIKit
import Quickblox

class LoginViewController: UIViewController {
    @IBOutlet weak var usernameFld: UITextField!
    @IBOutlet weak var passwordFld: UITextField!
    @IBOutlet weak var formView: UIView!
    @IBOutlet var signInBG: UIImageView!
    
    
    var qbService = QBService.shared
    var existingUser: QBUUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        customImgBg()
        addCustomDesign()
    }
    
    @IBAction func signUpAction(_ sender: Any) {
        self.goToRegistration()
    }
    @IBAction func signInAction(_ sender: Any) {
        self.signIn()
    }
    
    func addCustomDesign() {
        formView.roundCorners(corners: [.topLeft,.topRight], radius: 20)
    }
    
    ///sets Custom Image for Background
    func customImgBg() {
        let bgImg = UIImage(named: "loginBg")
        signInBG = UIImageView(frame: UIScreen.main.bounds)
        signInBG.contentMode = .scaleAspectFill
        signInBG.clipsToBounds = true
        signInBG.image = bgImg
        self.view.addSubview(signInBG)
        self.view.sendSubviewToBack(signInBG)
    }
    
    
    ///replace temp values later for textfield values
    func signIn() {
        qbService.signIn(with: "johnDoe", password: "password") { result in
            switch result {
            case .success(let user):
                self.existingUser = user
                self.qbService.connect(withUser: user) {
                    self.goToUserList()
                } _: { error in
                    print("Connect Server Error: ",error)
                }
                
            case .failure(let error):
                print("Sign In Error: ",error)
                //                if response.status.rawValue == 401  {
                //                    self.signUp()
                //                } else {
                //                    //show alerts for Error for network
                //                    print("Print signIn(), respone: ")
                //                }
            }
        }
    }
    
    ///Navigates to Registration
    func goToRegistration() {
        self.navigateTo(withStoryboard: "Main", to: "SignUpViewController", class: SignUpViewController.self)
    }
    
    func navigateTo<T:UIViewController>(withStoryboard storyboard: String, to identifier: String, class: T.Type){
        let storyBoard = UIStoryboard.init(name: storyboard, bundle: nil)
        guard let viewController = storyBoard.instantiateViewController(identifier: identifier) as? T else {return}
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func goToUserList() {
        self.navigateTo(withStoryboard: "Main", to: "UITabBarController", class: UITabBarController.self)
    }
    
    func isValid() -> Bool {
        if (!usernameFld.text!.isEmpty && !passwordFld.text!.isEmpty) {
            //add more validation stuff
            return true
        } else {
            return false
        }
    }
}



extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

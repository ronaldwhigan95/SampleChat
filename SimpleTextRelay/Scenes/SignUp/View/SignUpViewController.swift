//
//  SignUpViewController.swift
//  SimpleTextRelay
//
//  Created by Ronald Chester Whigan on 7/14/23.
//

import UIKit
import Quickblox

class SignUpViewController: UIViewController {
    @IBOutlet var signUpBG: UIImageView!
    @IBOutlet weak var usernameFld: UITextField!
    @IBOutlet weak var fullNameFld: UITextField!
    @IBOutlet weak var passwordFld: UITextField!
    @IBOutlet weak var signUpForm: UIView!
    
    var qbService = QBService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        customImgBg()
        addCustomDesign()
    }
    
    @IBAction func navigateToLogin(_ sender: Any) {
        popToRoot(from: self)
    }
    @IBAction func signUp(_ sender: Any) {
        qbSignUp()
    }
    
    func addCustomDesign() {
        signUpForm.roundCorners(corners: [.topLeft,.topRight], radius: 20)
    }
    
    func customImgBg() {
        let bgImg = UIImage(named: "loginBg")
        signUpBG = UIImageView(frame: UIScreen.main.bounds)
        signUpBG.contentMode = .scaleAspectFill
        signUpBG.clipsToBounds = true
        signUpBG.image = bgImg
        self.view.addSubview(signUpBG)
        self.view.sendSubviewToBack(signUpBG)
    }
    
    func getNewUserDetails() -> QBUUser {
        var user = QBUUser()
        user.login = usernameFld.text!
        user.password = passwordFld.text!
        return user
    }
    
    func qbSignUp() {
        let registerUser = getNewUserDetails()
        
        qbService.signUp(newUser: registerUser) { result in
            switch result {
            case .success(let user):
                self.qbService.signIn(with: user.login!, password: user.password!) { result in
                    switch result {
                        
                    case .success(let user):
                        self.qbService.connect(withUser: user) {
                            self.goToUserList()
                        } _: { error in
                            print("Connect Server Error: ",error)
                        }
                        
                    case .failure(let error):
                        print("Sign In Error: ",error)
                    }
                }
                //                self.goToChatController(user: user)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func navigateTo<T:UIViewController>(withStoryboard storyboard: String, to identifier: String, class: T.Type){
        let storyBoard = UIStoryboard.init(name: storyboard, bundle: nil)
        guard let viewController = storyBoard.instantiateViewController(identifier: identifier) as? T else {return}
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func goToUserList() {
        self.navigateTo(withStoryboard: "Main", to: "UsersListViewController", class: UsersListViewController.self)
    }
    
    
    func handlerOnSuccessRegistration() {
        displayAlert()
    }
    
    func displayAlert(){
        let alert = UIAlertController(title: "Successfully Registered", message: "Welcome to STR, Enjoy", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Continue", style: .default,handler: { action in
            self.goToUsersPage()
        }))
        
        present(alert, animated: true)
    }
    
    func goToUsersPage() {
        pushToNewRoot(withStoryboard: "Main", toNewRoot: "UsersListViewController", class: UsersListViewController.self)
    }
    
    func pushTo<T:UIViewController>(withStoryboard storyboard: String, to identifier: String, class: T.Type){
        let storyBoard = UIStoryboard.init(name: storyboard, bundle: nil)
        guard let viewController = storyBoard.instantiateViewController(identifier: identifier) as? T else {return}
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func pushToNewRoot<T:UIViewController>(withStoryboard storyboard: String, toNewRoot identifier: String, class: T.Type) {
        let storyBoard = UIStoryboard.init(name: storyboard, bundle: nil)
        guard let viewController = storyBoard.instantiateViewController(identifier: identifier) as? T else {return}
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate,
              let window = sceneDelegate.window else {
            return
        }
        
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }
    
    func popToRoot<T:UIViewController>(from viewController: T) {
        if let navigationController = viewController.navigationController {
            navigationController.popToRootViewController(animated: true)
        }
    }
}

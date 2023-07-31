//
//  UsersListViewController.swift
//  SimpleTextRelay
//
//  Created by Ronald Chester Whigan on 7/5/23.
//

import UIKit
import Quickblox

class UsersListViewController: UIViewController {
    
    @IBOutlet weak var usersTable: UITableView!
    @IBOutlet weak var usersForm: UIView!
    @IBOutlet var imgBg: UIImageView!
    
    var currentUser = QBUUser()
    var users: [QBUUser] = []
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getUsers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        customImgBg()
        addCustomDesign()
    }
    
    func addCustomDesign() {
        usersForm.roundCorners(corners: [.topLeft,.topRight], radius: 20)
    }
    
    func customImgBg() {
        let bgImg = UIImage(named: "loginBg")
        imgBg = UIImageView(frame: UIScreen.main.bounds)
        imgBg.contentMode = .scaleAspectFill
        imgBg.clipsToBounds = true
        imgBg.image = bgImg
        self.view.addSubview(imgBg)
        self.view.sendSubviewToBack(imgBg)
    }
    
    func getUserDetail() {
        currentUser = QBSession.current.currentUser!
    }
    
    func getUsers() {
        users = []
        let extendedRequest: [String: String] = [:]
        let page = QBGeneralResponsePage(currentPage: 1, perPage: 100)
        getUserDetail()
        QBRequest.users(withExtendedRequest: extendedRequest, page: page, successBlock: { [weak self] (response, page, users) in
            self?.users = users
            self?.users.removeAll(where: {$0 == self?.currentUser})
            DispatchQueue.main.async {
                self?.usersTable.reloadData()
            }
            print(users.count)
        }, errorBlock: { response in
            print(response)
        })
    }
}

extension UsersListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let chatVC = sb.instantiateViewController(withIdentifier: "ChatPageViewController") as! ChatPageViewController
        chatVC.selectedUser = users[indexPath.row]
        navigationController?.pushViewController(chatVC, animated: true)
    }
}

extension UsersListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else { return  UITableViewCell()}
        cell.textLabel?.text = users[indexPath.section].fullName
        cell.detailTextLabel?.text = String(users[indexPath.row].id)
        cell.backgroundColor = #colorLiteral(red: 0.5354288816, green: 0.6929528117, blue: 0.8018425107, alpha: 1)
        cell.layer.cornerRadius = 20
        
        return cell
    }
}

//extension UIColor {
//    convenience init(_ r: Double,_ g: Double,_ b: Double,_ a: Double) {
//        self.init(red: r/255, green: g/255, blue: b/255, alpha: a)
//    }
//}

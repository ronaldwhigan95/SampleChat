//
//  Navigation.swift
//  SimpleTextRelay
//
//  Created by Ronald Chester Whigan on 7/31/23.
//

import Foundation
import UIKit

class Navigation{
    func navigateTo<T:UIViewController>(withStoryboard storyboard: String, to identifier: String, class: T.Type, navController: UINavigationController?) {
        let storyBoard = UIStoryboard.init(name: storyboard, bundle: nil)
        guard let viewController = storyBoard.instantiateViewController(identifier: identifier) as? T else {return}
        navController?.pushViewController(viewController, animated: true)
    }
    //Some Change
}

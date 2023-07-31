//
//  CurrentUser.swift
//  SimpleTextRelay
//
//  Created by Ronald Chester Whigan on 7/27/23.
//

import Foundation

struct UserCustomData: Encodable, Decodable {
    var dob: String?
    var hobbies: String?
    var bio: String?
    var jobTitle: String?
}

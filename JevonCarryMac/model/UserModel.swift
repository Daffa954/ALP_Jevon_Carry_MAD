//
//  UserModel.swift
//  JevonCarryMac
//
//  Created by Daffa Khoirul on 03/06/25.
//

import Foundation
struct MyUser: Codable {
    var uid: String = ""
    var name: String = ""
    var password: String = ""
    var email: String = ""
    var hobbies: [String] = []
    
}

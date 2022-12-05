//
//  PostmanApp.swift
//  Postman
//
//  Created by 胡家睿 on 2021/8/13.
//

import SwiftUI
import Firebase

@main
struct PostmanApp: App {
    @ObservedObject var postman = AppPostman()
    
    init() {
        FirebaseApp.configure()
        
        var counter = UserDefaults.standard.integer(forKey: "appOpened")
        counter += 1
        var scanned = false
        
        if counter == 1 {
            var userID = postman.getUserID()
            FirebaseViewModel().getAllUserIDs()
            var existings: [String] = []
            for i in FirebaseViewModel().users {
                existings.append(i.userID)
            }
            
            for i in existings {
                if userID == i {
                    userID = postman.getUserID()
                    scanned = true
                    
                    break
                }
            }
            
            if !scanned {
                UserDefaults.standard.set("POSTMAN_USER_\(userID)", forKey: "myUserID")
            }
        }
        
        UserDefaults.standard.set(counter, forKey: "appOpened")
        
        UserDefaults.standard.register(defaults: [
            "knownFriends": [],
            "intro_showed": false,
            "name": "",
            "nickname": "",
            "password": "",
            "chat_upload": true,
            "total_friends": 0,
            "myUserID": "",
            "appOpened": 0,
            "canChangeInfo": true
        ])
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

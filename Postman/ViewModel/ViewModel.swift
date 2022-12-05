//
//  ViewModel.swift
//  ChatExample
//
//  Created by 胡家睿 on 2021/8/11.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import CoreImage.CIFilterBuiltins

struct ViewModel {
    var id: String
    let msg: String
    let time: Date
    let senderSelf: Bool
}

struct User {
    var id: String
    let name: String
    let profilePicture: String
    var isOnline: Bool
    let userID: String
    var nickname: String
}

struct FirebaseUser: Identifiable {
    var id = UUID().uuidString
    var isOnline: Bool
    var name: String
    var nickname: String
    var profilePicture: String
    var userID: String
}

class AppPostman: ObservableObject {
    func resetApp(rememberName: Bool) {
        if !rememberName {
            let domain = Bundle.main.bundleIdentifier!
            UserDefaults.standard.removePersistentDomain(forName: domain)
            UserDefaults.standard.synchronize()
        } else {
            let name = UserDefaults.standard.string(forKey: "name")!
            let nickname = UserDefaults.standard.string(forKey: "nickname")!
            let password = UserDefaults.standard.string(forKey: "password")!
            
            let domain = Bundle.main.bundleIdentifier!
            UserDefaults.standard.removePersistentDomain(forName: domain)
            UserDefaults.standard.synchronize()
            
            UserDefaults.standard.set(name, forKey: "name")
            UserDefaults.standard.set(nickname, forKey: "nickname")
            UserDefaults.standard.set(password, forKey: "password")
            UserDefaults.standard.set(true, forKey: "intro_showed")
        }
        
        var scanned = false
        var userID = AppPostman().getUserID()
        FirebaseViewModel().getAllUserIDs()
        var existings: [String] = []
        for i in FirebaseViewModel().users {
            existings.append(i.userID)
        }
        
        for i in existings {
            if userID == i {
                userID = AppPostman().getUserID()
                scanned = true
                
                break
            }
        }
        
        if !scanned {
            UserDefaults.standard.set("POSTMAN_USER_\(userID)", forKey: "myUserID")
        }
    }
    
    func getUserID() -> String {
        let digit1 = Int.random(in: 1..<9)
        let digit2 = Int.random(in: 1..<9)
        let digit3 = Int.random(in: 1..<9)
        let digit4 = Int.random(in: 1..<9)
        let digit5 = Int.random(in: 1..<9)
        let digit6 = Int.random(in: 1..<9)
        let digit7 = Int.random(in: 1..<9)
        let digit8 = Int.random(in: 1..<9)
        let digit9 = Int.random(in: 1..<9)
        let digit10 = Int.random(in: 1..<9)
        
        let userID = "\(digit1)\(digit2)\(digit3)\(digit4)\(digit5)\(digit6)\(digit7)\(digit8)\(digit9)\(digit10)"
        
        return userID
    }
    
    func formatMessageTime(timeString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d hh:mm:ss"
        
        let date = formatter.date(from: timeString)
        return date ?? Date()
    }
    
    func getDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d hh:mm:ss"
        let stringTime = formatter.string(from: date)
        
        return stringTime
    }
    
    func generateQrCode(from string: String) -> UIImage {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")
        
        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }
        
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}

class FirebaseViewModel: ObservableObject {
    @Published var users = [FirebaseUser]()
    @Published var allusers = [FirebaseUser]()
    
    private var db = Firestore.firestore()
    
    func fetchData() {
        db.collection(AccountViewModel().getInfo(.email) as! String).addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents: \(String(describing: error?.localizedDescription))")
                return
            }
            
            self.users = documents.map { (queryDocumentSnapshot) -> FirebaseUser in
                let data = queryDocumentSnapshot.data()
                let name = data["name"] as? String ?? ""
                let profilePicture = data["profilePicture"] as? String ?? ""
                let isOnline = data["isOnline"] as? Bool ?? false
                let userID = data["userID"] as? String ?? AppPostman().getUserID()
                let nickname = data["nickname"] as? String ?? ""
                
                return FirebaseUser(isOnline: isOnline, name: name, nickname: nickname, profilePicture: profilePicture, userID: userID)
            }
        }
    }
    
    func fetchAllDakk ta() {
        db.collection("allUsers").addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents: \(String(describing: error?.localizedDescription))")
                return
            }
            
            self.allusers = documents.map { (queryDocumentSnapshot) -> FirebaseUser in
                let data = queryDocumentSnapshot.data()
                let name = data["name"] as? String ?? ""
                let profilePicture = data["profilePicture"] as? String ?? ""
                let isOnline = data["isOnline"] as? Bool ?? false
                let userID = data["userID"] as? String ?? AppPostman().getUserID()
                let nickname = data["nickname"] as? String ?? ""
                
                return FirebaseUser(isOnline: isOnline, name: name, nickname: nickname, profilePicture: profilePicture, userID: userID)
            }
        }
    }
    
    func add(_ user: FirebaseUser) {
        let data: [String: Any] = [
            "name": user.name,
            "nickname": user.nickname,
            "profilePicture": user.profilePicture,
            "isOnline": user.isOnline,
            "userID": user.userID
        ]
        
        db.collection(AccountViewModel().getInfo(.email) as! String).document(user.userID).setData(data, merge: true)
    }
    
    func addToAllUsers(_ user: FirebaseUser) {
        let data: [String: Any] = [
            "name": user.name,
            "nickname": user.nickname,
            "profilePicture": user.profilePicture,
            "isOnline": user.isOnline,
            "userID": user.userID
        ]
        
        db.collection("allUsers").document(user.userID).setData(data, merge: true)
    }
    
    func delete(documentName: String, collectionName: String) {
        let docRef = db.collection(collectionName).document(documentName)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.db.collection(collectionName).document(documentName).delete() { err in
                    if let err = err {
                        print(err.localizedDescription)
                    }
                }
            } else {
                print("Document \"\(documentName)\" does not exists.")
            }
        }
    }
    
    func getAllUserIDs() {
        db.collection("allUsers").addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents: \(String(describing: error?.localizedDescription))")
                return
            }
            
            self.users = documents.map { (queryDocumentSnapshot) -> FirebaseUser in
                let data = queryDocumentSnapshot.data()
                let name = data["name"] as? String ?? ""
                let profilePicture = data["profilePicture"] as? String ?? ""
                let isOnline = data["isOnline"] as? Bool ?? false
                let userID = data["userID"] as? String ?? AppPostman().getUserID()
                let nickname = data["nickname"] as? String ?? ""
                
                return FirebaseUser(isOnline: isOnline, name: name, nickname: nickname, profilePicture: profilePicture, userID: userID)
            }
        }
    }
}

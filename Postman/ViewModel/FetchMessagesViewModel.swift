//
//  FetchMessagesViewModel.swift
//  Postman
//
//  Created by 胡家睿 on 2021/8/20.
//

import SwiftUI
import FirebaseFirestore

struct Message: Identifiable, Equatable {
    var id: String
    var msg: String
    var senderUserID: String
    var receiverUserID: String
    var time: String
}

class FetchMessagesViewModel: ObservableObject {
    @Published var messages = [Message]()
    @Published var lastID = ""
    
    private var db = Firestore.firestore()
    
    func fetchMessages(_ channelName: String) {
        db.collection(channelName).order(by: "time", descending: false).addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents: \(String(describing: error?.localizedDescription))")
                return
            }
            
            self.messages = documents.map { (queryDocumentSnapshot) -> Message in
                let data = queryDocumentSnapshot.data()
                let id = data["id"] as? String ?? ""
                let msg = data["msg"] as? String ?? ""
                let senderUserID = data["senderUserID"] as? String ?? ""
                let receiverUserID = data["receiverUserID"] as? String ?? ""
                let time = data["time"] as? String ?? ""
                self.lastID = id
                
                if receiverUserID == UserDefaults.standard.string(forKey: "myUserID")! {
                    FirebaseViewModel().getAllUserIDs()
                    let ids = FirebaseViewModel().allusers
                    
                    for i in ids {
                        if i.userID == senderUserID {
                            let content = UNMutableNotificationContent()
                            content.title = "Postman"
                            content.subtitle = i.nickname
                            content.body = msg
                            
                            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                            
                            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                            
                            UNUserNotificationCenter.current().add(request)
                            print("done")
                        }
                    }
                }
                
                return Message(id: id, msg: msg, senderUserID: senderUserID, receiverUserID: receiverUserID, time: time)
            }
        }
    }
    
    func sendMessage(_ message: Message) {
        let data: [String: Any] = [
            "id": message.id,
            "msg": message.msg,
            "senderUserID": message.senderUserID,
            "receiverUserID": message.receiverUserID,
            "time": message.time
        ]
        
        db.collection(message.senderUserID).document(message.id).setData(data, merge: false)
        
        db.collection(message.receiverUserID).document(message.id).setData(data, merge: false)
    }
    
    func recall(collectionName: String, message: String) {
        db.collection(collectionName).document(message).delete() { err in
            if let err = err {
                print(err.localizedDescription)
            }
        }
    }
    
    func clearHistory(_ collectionName: String) {
        for i in messages {
            if i.senderUserID == UserDefaults.standard.string(forKey: "myUserID")! {
                let docRef = db.collection(collectionName).document(i.msg)
                docRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        self.db.collection(collectionName).document(i.msg).delete() { err in
                            if let err = err {
                                print(err.localizedDescription)
                            }
                        }
                    } else {
                        print("Document \"\(i.msg)\" does not exists.")
                    }
                }
            }
        }
    }
}

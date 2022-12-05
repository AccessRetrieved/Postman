//
//  ContentView.swift
//  Postman
//
//  Created by 胡家睿 on 2021/8/18.
//

import SwiftUI
import RNCryptor

struct ContentView: View {
    @AppStorage("log_status") var status = false
    
    func encryptMessage(message: String, encryptionKey: String) throws -> String {
        let messageData = message.data(using: .utf8)!
        let cipherData = RNCryptor.encrypt(data: messageData, withPassword: encryptionKey)
        return cipherData.base64EncodedString()
    }
    
    var body: some View {
        Group {
            if status {
                Home()
//                    .onAppear {
//                        do {
//                            print(try encryptMessage(message: "work.jerrywu@gmail.com", encryptionKey: "1"))
//                            print(try encryptMessage(message: "Bestway1234", encryptionKey: "1"))
//                        } catch {
//
//                        }
//                    }
                
            } else {
                Welcome()
                    .navigationBarHidden(true)
                    .navigationBarBackButtonHidden(true)
            }
            
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//
//  SigninViewModel.swift
//  Postman
//
//  Created by 胡家睿 on 2021/7/28.
//

import SwiftUI
import Firebase

class AccountViewModel: ObservableObject {
    @AppStorage("log_status") var status = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var isLoading = false
    @Published var reset = false
    enum type {
        case email
        case password
        case uid
        case isEmailVerified
    }
    
    // Credencials
    @Published var email = ""
    @Published var password = ""

    func signin() {
        AppPostman().resetApp(rememberName: true)
        
        self.isLoading = true
        Auth.auth().signIn(withEmail: self.email, password: self.password) { result, error in
            if error != nil {
                // Failed
                self.status = false
                self.errorMessage = error!.localizedDescription
                self.showError = true
                self.isLoading = false
            } else {
                // Success
                self.status = true
                self.showError = false
                self.isLoading = false
                self.setPassword(self.password)
            }
        }
    }
    
    func signinCredencials(Email: String, Password: String) {
        AppPostman().resetApp(rememberName: true)
        
        self.isLoading = true
        Auth.auth().signIn(withEmail: Email, password: Password) { result, error in
            if error != nil {
                // Failed
                self.status = false
                self.errorMessage = error!.localizedDescription
                self.showError = true
                self.isLoading = false
            } else {
                // Success
                self.status = true
                self.showError = false
                self.isLoading = false
                self.setPassword(self.password)
            }
        }
    }
    
    func sendVerificationEmail(_ email: String, _ password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if error == nil {
                Auth.auth().currentUser?.sendEmailVerification { error in print(error?.localizedDescription) }
            }
        }
    }
    
    func signup() {
        isLoading = true
        Auth.auth().createUser(withEmail: email, password: password) { account, error in
            if error != nil {
                self.status = false
                self.errorMessage = error?.localizedDescription ?? ""
                self.showError = true
                self.isLoading = false
                print(error?.localizedDescription ?? "")
            } else {
                self.status = true
                AppPostman().resetApp(rememberName: false)
                FirebaseViewModel().addToAllUsers(FirebaseUser(isOnline: true, name: UserDefaults.standard.string(forKey: "name")!, nickname: UserDefaults.standard.string(forKey: "nickname")!, profilePicture: "defaultUser", userID: UserDefaults.standard.string(forKey: "myUserID")!))
                self.setPassword(self.password)
                
                
                // Send email verification
                Auth.auth().currentUser?.sendEmailVerification { error in print(error?.localizedDescription) }
            }
        }
    }
    
    func resetPassword() {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if error != nil {
                self.showError = true
                self.errorMessage = error?.localizedDescription ?? "Please try again later."
                self.reset = false
            } else {
                self.reset = true
            }
        }
    }
    
    func signout() {
        do {
            try Auth.auth().signOut()
            self.status = false
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteUser() {
        Auth.auth().currentUser?.delete { error in
            if error != nil {
                self.errorMessage = error?.localizedDescription ?? "Cannot delete this account, please try again later."
                self.showError = true
            } else {
                FirebaseViewModel().delete(documentName: UserDefaults.standard.string(forKey: "myUserID")!, collectionName: "allUsers")
                
                self.status = false
            }
        }
    }
    
    func setPassword(_ password: String) {
        UserDefaults.standard.set(password, forKey: "password")
    }
    
    func updatePassword(_ password: String) {
        self.isLoading = true
        Auth.auth().signIn(withEmail: self.getInfo(.email) as! String, password: password) { result, error in
            if error == nil {
                Auth.auth().currentUser?.updatePassword(to: password) { error in
                    if error == nil {
                        self.setPassword(password)
                    }
                }
            }
        }
        
        self.isLoading = false
    }
    
    func getInfo(_ infoType: type) -> Any {
        let user = Auth.auth().currentUser
        if let user = user {
            let uid = user.uid
            let email = user.email
            let password = UserDefaults.standard.string(forKey: "password")!
            let isEmailVerified = user.isEmailVerified
            
            if infoType == .email {
                return email!
            } else if infoType == .password {
                return password
            } else if infoType == .isEmailVerified {
                return isEmailVerified
            } else {
                return uid
            }
        }
        
        return ""
    }
}

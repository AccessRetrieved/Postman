//
//  Settings.swift
//  ChatExample
//
//  Created by 胡家睿 on 2021/8/12.
//

import SwiftUI
import RNCryptor
import MobileCoreServices
import Firebase

struct SettingsAccount: View {
    @ObservedObject var account = AccountViewModel()
    @Binding var isPresented: Bool
    @Environment(\.presentationMode) var presentation
    @State var writer = NFCWriter()
    @State var password = ""
    @State var showPassword = false
    @State var changePassword = false
    @State var reverifyUser = false
    @State var verifyPassword = ""
    
    func encryptMessage(message: String, encryptionKey: String) throws -> String {
        let messageData = message.data(using: .utf8)!
        let cipherData = RNCryptor.encrypt(data: messageData, withPassword: encryptionKey)
        return cipherData.base64EncodedString()
    }
    
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    var body: some View {
        Form {
            Section {
                Text(account.getInfo(.email) as! String)
                    .foregroundColor(.gray)
                
                Button(action: {
                    self.changePassword.toggle()
                }) {
                    Text("Change Password")
                }
            }
            .sheet(isPresented: $changePassword) {
                ChangePassword()
                    .interactiveDismissDisabled()
            }
            
            Section {
                Button(action: {
                    self.showPassword.toggle()
                }) {
                    Text("Log in with NFC")
                }
                
                if showPassword {
                    Section {
                        TextField("Verify your identity - Enter your password", text: $password)
                            .overlay(
                                HStack {
                                Spacer()
                                
                                if !password.isEmpty {
                                    Button(action: {
                                        self.password = ""
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                    }
                                }
                            }
                            )
                        
                        Button(action: {
                            if password == account.getInfo(.password) as! String {
                                do {
                                    let encryption = randomString(length: 2)
                                    let email = try encryptMessage(message: AccountViewModel().getInfo(.email) as! String, encryptionKey: encryption)
                                    let password = try encryptMessage(message: password, encryptionKey: encryption)
//                                    let email = AccountViewModel().getInfo(.email)
//                                    let password = password
                                    let data = "postman://postmanUser?email=\(email)&password=\(password)&encryption=\(encryption)"
                                    writer.scanWrite(data: data)
                                } catch {
                                    print(error.localizedDescription)
                                    self.presentation.wrappedValue.dismiss()
                                }
                            } else {
                                let view = SPAlertView(title: "Error", message: "Incorrect password", preset: .error)
                                view.dismissByTap = false
                                view.present(duration: 1, haptic: .error) {
                                    self.password = ""
                                }
                            }
                        }) {
                            Text("Write to NFC")
                        }
                        .disabled(password.isEmpty)
                    }
                }
            }
            
            Section {
                Button(action: {
                    account.signout()
                    self.isPresented = false
                }) {
                    Text("Sign out")
                }
                
                Button(action: {
                    self.reverifyUser.toggle()
                }) {
                    Text("Delete account")
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
            }
            .alert(isPresented: $account.showError) {
                Alert(title: Text("Error"), message: Text(account.errorMessage), dismissButton: .default(Text("Ok")))
            }
            .sheet(isPresented: $reverifyUser) {
                EnterPassword(password: $verifyPassword, title: "Authenticate", subtitle: "This action is sensitive. Please sign in again.")
                    .onDisappear {
                        if verifyPassword == account.getInfo(.password) as! String {
                            Auth.auth().signIn(withEmail: account.getInfo(.email) as! String, password: verifyPassword) { result, error in
                                if error != nil {
                                    let view = SPAlertView(title: "Error", message: error?.localizedDescription, preset: .error)
                                    view.dismissByTap = true
                                    view.present(duration: 1.5, haptic: .error)
                                } else {
                                    account.deleteUser()
                                    self.presentation.wrappedValue.dismiss()
                                }
                            }
                        } else {
                            let view = SPAlertView(title: "Error", message: "Wrong password", preset: .error)
                            view.dismissByTap = true
                            view.present(duration: 1.5, haptic: .error)
                            self.verifyPassword = ""
                        }
                    }
            }
        }
    }
}

struct SettingsGeneral: View {
    @State var uploadChatHistory = UserDefaults.standard.bool(forKey: "chat_upload")
    
    var body: some View {
        Form {
            Section(footer: Text("Your chat history needs to be uploaded to sync with your other devices. This information is encrypted and cannot be read by anyone.")) {
                Toggle(isOn: $uploadChatHistory) {
                    Text("Sync your chat history")
                }
                .padding([.leading, .trailing], 10)
                .onChange(of: uploadChatHistory) { value in
                    UserDefaults.standard.set(uploadChatHistory, forKey: "chat_upload")
                }
            }
        }
    }
}

struct ChangePassword: View {
    @State var currentPage = 1
    @ObservedObject var account = AccountViewModel()
    @Environment(\.presentationMode) var presentation
    @State var oldPassword = ""
    @State var newPassword = ""
    @State var newPassword2 = ""
    
    func foundInt(_ string: String) -> Bool {
        let decimalCharacters = CharacterSet.decimalDigits
        let decimalRange = string.rangeOfCharacter(from: decimalCharacters)
        
        if decimalRange != nil {
            return true
        } else {
            return false
        }
    }
    
    func disableNext(_ string: String) -> Bool {
        let int = foundInt(string)
        
        if int == true && string.count >= 6 && newPassword == newPassword2 && !account.isLoading {
            // Undisable
            return false
        } else {
            // Disable
            return true
        }
    }
    
    var body: some View {
        VStack {
            if currentPage == 1 {
                tab1
            } else {
                tab2
            }
            
            Spacer()
            
            VStack(spacing: 10) {
                if currentPage == 2 {
                    HStack(spacing: 30) {
                        Button(action: {
                            self.presentation.wrappedValue.dismiss()
                        }) {
                            Text("Cancel")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                                .background(Color.red)
                        }
                        .frame(width: UIScreen.main.bounds.width / 2 - 50, height: 60)
                        .background(Color.red)
                        .cornerRadius(15)
                        .padding(.leading, 20)
                        
                        Spacer()
                        
                        Button(action: {
                            if oldPassword != newPassword {
                                if newPassword == newPassword2 {
                                    if newPassword.count < 6 {
                                        let view = SPAlertView(title: "Error", message: "Password cannot be shorter than 6 characters", preset: .error)
                                        view.dismissByTap = true
                                        view.present(duration: 1.5, haptic: .error)
                                    } else {
                                        account.updatePassword(newPassword)
                                        
                                        let view = SPAlertView(title: "Success", message: "Password Updated", preset: .done)
                                        view.dismissByTap = true
                                        view.present(duration: 1.5, haptic: .success)
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                            if currentPage == 2 {
                                                self.presentation.wrappedValue.dismiss()
                                            }
                                        }
                                    }
                                } else {
                                    let view = SPAlertView(title: "Error", message: "Confirmed password has to be the same", preset: .error)
                                    view.dismissByTap = true
                                    view.present(duration: 1.5, haptic: .error)
                                }
                            } else {
                                let view = SPAlertView(title: "Erro", message: "Same as old password", preset: .error)
                                view.dismissByTap = true
                                view.present(duration: 1.5, haptic: .error)
                            }
                        }) {
                            if account.isLoading {
                                ProgressView()
                            } else {
                                Text("Save")
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(.white)
                                    .background(disableNext(newPassword) ? Color.gray : Color.blue)
                            }
                        }
                        .frame(width: UIScreen.main.bounds.width / 2 - 50, height: 60)
                        .background(disableNext(newPassword) ? Color.gray : Color.blue)
                        .cornerRadius(15)
                        .disabled(disableNext(newPassword))
                        .padding(.trailing, 20)
                    }
                    .padding(.bottom, 50)
                } else {
                    Button(action: {
                        let old = account.getInfo(.password)
                        
                        if oldPassword == old as! String {
                            withAnimation(.spring()) {
                                currentPage += 1
                            }
                        } else {
                            let view = SPAlertView(title: "Error", message: "Wrong password", preset: .error)
                            view.dismissByTap = true
                            view.present(duration: 1, haptic: .error)
                        }
                    }) {
                        Text("Next")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .background(Color.blue)
                    }
                    .frame(width: 325, height: 50)
                    .background(Color.blue)
                    .cornerRadius(15)
                }
            }
            .padding(.bottom, 40)
        }
    }
    
    var tab1: some View {
        VStack {
            Text("Authentication")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.top, 40)
            
            Text("Enter your old password")
                .foregroundColor(.gray)
                .font(.subheadline)
                .padding(.top, 10)
            
            Spacer()
            
            CustomStyledSecureTextField(text: $oldPassword, placeholder: "Old Password", symbolName: "key.fill", onCommit: {})
                .padding([.leading, .trailing])
                .padding(.bottom, 250)
            
            Spacer()
        }
    }
    
    var tab2: some View {
        VStack {
            Text("Creating a new password")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.top, 40)
            
            Text("Now create a new password")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top, 10)
            
            Spacer()
            
            VStack {
                CustomStyledSecureTextField(text: $newPassword, placeholder: "New Password", symbolName: "key.fill", onCommit: {})
                    .padding([.leading, .trailing])
                
                CustomStyledSecureTextField(text: $newPassword2, placeholder: "Confirm Password", symbolName: "key.fill", onCommit: {})
                    .padding([.leading, .trailing])
                
                Spacer(minLength: 30)
                
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        VStack(alignment: .leading, spacing: 15) {
                            HStack(spacing: 10) {
                                Image(systemName: "checkmark.circle")
                                
                                Text("Longer than 6 characters")
                            }
                            .font(.subheadline)
                            .foregroundColor(newPassword.count <= 6 ? .red : .green)
                            
                            HStack {
                                Image(systemName: "checkmark.circle")
                                
                                Text("Contains at lease 1 digit")
                            }
                            .font(.subheadline)
                            .foregroundColor(foundInt(newPassword) ? .green : .red)
                            
                            HStack {
                                Image(systemName: "checkmark.circle")
                                
                                Text("Passwords are same")
                            }
                            .font(.subheadline)
                            .foregroundColor(newPassword == newPassword2 ? .green : .red)
                        }
                        .padding()
                        
                        Spacer()
                    }
                }
            }
            .padding(.bottom, 250)
            
            Spacer()
        }
    }
}

struct Settings: View {
    @Binding var isPresented: Bool
    @State var isAnimating = false
    @State var showSetup = false
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentation
    @ObservedObject var account = AccountViewModel()
    @ObservedObject var firebase = FirebaseViewModel()
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: SettingsAccount(isPresented: $isPresented).navigationTitle("Account")) {
                    Text("Account and security")
                }
                
                NavigationLink(destination: SettingsGeneral().navigationTitle("General")) {
                    Text("General")
                }
                
                HStack {
                    Spacer()
                    
                    VStack(spacing: 10) {
                        Text("Postman v\((Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String)!) - Build \((Bundle.main.infoDictionary?["CFBundleVersion"] as? String)!)")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                    }
                    
                    Spacer()
                }
                .listRowBackground(colorScheme == .dark ? Color(red: 28/255, green: 27/255, blue: 29/255) : .white)
            }
            .listStyle(InsetListStyle())
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        self.isPresented = false
                    }) {
                        Image(systemName: "chevron.down.circle.fill")
                    }
                }
            }
            .onAppear {
                self.isAnimating = true
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showSetup) {
                Intro(isPresented: $showSetup)
                    .interactiveDismissDisabled()
            }
            
            HStack {
                Spacer()
                
                VStack(spacing: 10) {
                    Text("Postman v\((Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String)!) - Build \((Bundle.main.infoDictionary?["CFBundleVersion"] as? String)!)")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                }
                
                Spacer()
            }
        }
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings(isPresented: .constant(false))
    }
}

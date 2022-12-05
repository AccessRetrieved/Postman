//
//  Settings.swift
//  ChatExample
//
//  Created by 胡家睿 on 2021/8/12.
//

import SwiftUI

struct Intro: View {
    @Binding var isPresented: Bool
    @State var currentPage = 1
    @State var name = UserDefaults.standard.string(forKey: "name")!
    @State var nickname = UserDefaults.standard.string(forKey: "nickname")!
    @State var titleOffset: CGFloat = 0
    @State var buttonDisabled = true
    @State var showDescription = false
    @ObservedObject var firebase = FirebaseViewModel()
    @State var readyText = "Postman is making sure everything is ready..."
    
    func simpleSuccess() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    var tab1: some View {
        VStack {
            Spacer()
            
            Text("Let's get you set up")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .offset(y: titleOffset)
            
            if showDescription {
                VStack {
                    Button(action: {
                        withAnimation {
                            currentPage = 2
                        }
                    }) {
                        Image(systemName: "arrow.right.circle")
                            .font(.custom("Calibri", size: 100))
                            .foregroundColor(.orange)
                    }
                    
                    Text("Click Next or swipe to continue.")
                        .foregroundColor(.gray)
                        .padding()
                }
                .padding(.top, 75)
            }
            
            Spacer()
        }
    }
    
    var tab2: some View {
        VStack {
            Text("Postman's Privacy notice")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.top, 40)
            
            Spacer()
            
            AreaToCard(show: false, title: "Privacy notice", message: "Your chat history are automatically uploaded to Postman's backend server for cloud syncing. This information is encrypted and cannot be read by anyone. Your camera and microphone is used to send pictures and videos.")
                .padding([.leading, .trailing], 25)
            
            Spacer()
        }
    }
    
    var tab3: some View {
        VStack {
            Text("About You")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.top, 40)
            
            Spacer()
            
            VStack {
                CustomStyledTextField(text: $name, placeholder: "Fullname", symbolName: "person.fill", onCommit: {}, uppercased: false, email: false)
                    .padding([.leading, .trailing])
                
                CustomStyledTextField(text: $nickname, placeholder: "Nickname", symbolName: "person.crop.square.fill", onCommit: {}, uppercased: false, email: false)
                    .padding([.leading, .trailing])
            }
            .padding(.bottom, 250)
            
            Spacer()

        }
    }
    
    var tab4: some View {
        VStack(spacing: 20) {
            Spacer()
            
            HStack(spacing: 10) {
                Text("You're all set!")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                ProgressView()
            }
            
            Text(readyText)
                .foregroundColor(.gray)
                .font(.headline)
            
            Spacer()
        }
        .onAppear {
            self.readyText = "Gathering permissions..."
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound, .carPlay]) { success, error in
                if !success {
                    print(error?.localizedDescription)
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.readyText = "Preparing your name..."
                UserDefaults.standard.set(name, forKey: "name")
                UserDefaults.standard.set(nickname, forKey: "nickname")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.readyText = "Waiting for server response..."
                    firebase.addToAllUsers(FirebaseUser(isOnline: true, name: UserDefaults.standard.string(forKey: "name")!, nickname: UserDefaults.standard.string(forKey: "nickname")!, profilePicture: "defaultUser", userID: UserDefaults.standard.string(forKey: "myUserID")!))
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                        self.readyText = "All done!"
                        
                        if currentPage == 4 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                if currentPage == 4 {
                                    UserDefaults.standard.set(true, forKey: "intro_showed")
                                    self.isPresented = false
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                tab1
                    .tag(1)
                
                tab2
                    .tag(2)
                
                tab3
                    .tag(3)
                
                tab4
                    .tag(4)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .disabled(currentPage == 4)
            
            Spacer()
            
            if currentPage != 4 {
                VStack(spacing: 10) {
                    Button(action: {
                        withAnimation {
                            currentPage += 1
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
                    .disabled(buttonDisabled)
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring()) {
                    titleOffset = -160
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                        withAnimation(.spring()) {
                            self.showDescription.toggle()
                        }
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.buttonDisabled = false
                }
            }
        }
    }
}

struct Intro_Previews: PreviewProvider {
    static var previews: some View {
        Intro(isPresented: .constant(false))
    }
}

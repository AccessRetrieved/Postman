//
//  Home.swift
//  ChatExample
//
//  Created by 胡家睿 on 2021/8/11.
//

import SwiftUI
import Firebase

struct Home: View {
    @State var showIntro = false
    @State var showSettings = false
    @State var addFriend = false
    @State var searchText = ""
    @ObservedObject var viewModel = FirebaseViewModel()
    @ObservedObject var account = AccountViewModel()
    @State var showVerify = false
    private func deleteItems(offsets: IndexSet) {
        let user = offsets.map { viewModel.users[$0] }[0]
        if user.userID != "POSTMAN_OFFICIAL" && user.userID != "POSTMAN_WORLD" {
            viewModel.delete(documentName: user.userID, collectionName: AccountViewModel().getInfo(.email) as! String)
        }
    }
    
    func simpleSuccess() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    init() {
        account.email = account.getInfo(.email) as! String
        account.password = account.getInfo(.password) as! String
        account.signin()
        
        if account.getInfo(.isEmailVerified) as! Bool == false {
            account.sendVerificationEmail(account.getInfo(.email) as! String, account.getInfo(.password) as! String)
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                VStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)

                        TextField("Search Postman", text: $searchText)
                            .onChange(of: searchText) { text in
                                simpleSuccess()
                            }
                            .padding(7)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .disableAutocorrection(true)
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 10) {
                                            Button(action: {
                                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                            }) {
                                                Image(systemName: "keyboard.chevron.compact.down")
                                                    .foregroundColor(.black)
                                            }
                                            
                                            Divider()
                                                .padding([.leading, .trailing, .top, .bottom], 5)
                                            
                                            ForEach(viewModel.users) { user in
                                                Button(action: {
                                                    if self.searchText == user.nickname {
                                                        self.searchText = ""
                                                    } else {
                                                        self.searchText = user.nickname
                                                    }
                                                }) {
                                                    if self.searchText == user.nickname {
                                                        Image(systemName: "xmark.circle.fill")
                                                            .foregroundColor(.secondary)
                                                            .padding([.leading, .trailing, .top, .bottom], 7)
                                                            .background(
                                                                RoundedRectangle(cornerRadius: 8, style: .circular)
                                                                    .foregroundColor(Color(.secondarySystemFill))
                                                            )
                                                    } else {
                                                        Text(user.nickname)
                                                            .foregroundColor(.black)
                                                            .padding([.leading, .trailing, .top, .bottom], 7)
                                                            .background(
                                                                RoundedRectangle(cornerRadius: 8, style: .circular)
                                                                    .foregroundColor(Color(.secondarySystemFill))
                                                            )
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .overlay(
                                HStack {
                                Spacer()
                                
                                if !searchText.isEmpty {
                                    Button(action: {
                                        self.searchText = ""
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .padding()
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            )
                    }
                    .padding(8)
                }
                
                ForEach(viewModel.users.filter({"\($0)".lowercased().contains(searchText.lowercased()) || searchText.isEmpty })) { user in
                    NavigationLink(destination: Chat(user: User(id: UUID().uuidString, name: user.name, profilePicture: user.profilePicture, isOnline: user.isOnline, userID: user.userID, nickname: user.nickname)).navigationBarHidden(true).navigationBarBackButtonHidden(true)) {
                        HStack {
                            VStack {
                                RoundedRectangle(cornerRadius: 7)
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.clear)
                                    .overlay(
                                        Image(user.profilePicture)
                                            .resizable()
                                            .frame(width: 51, height: 51)
                                            .clipShape(RoundedRectangle(cornerRadius: 7))
                                    )
                            }
                            .padding()
                            
                            VStack(alignment: .leading)  {
                                Text(user.nickname)
                                    .font(.title3)
                                
                                HStack {
                                    Text(user.isOnline ? "Online" : "Offline")
                                        .foregroundColor(.gray)
                                        .font(.subheadline)
                                    
                                    if user.isOnline {
                                        Circle()
                                            .frame(width: 10, height: 10)
                                            .foregroundColor(.green)
                                    } else {
                                        Circle()
                                            .frame(width: 10, height: 10)
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Postman")
            .onAppear {
                viewModel.fetchData()
                
                if !UserDefaults.standard.bool(forKey: "intro_showed") {
                    self.showIntro.toggle()
                }
                
                viewModel.add(FirebaseUser(isOnline: true, name: "Postman", nickname: "Postman Support", profilePicture: "postman", userID: "POSTMAN_OFFICIAL"))
                
                viewModel.add(FirebaseUser(isOnline: true, name: "World Channel", nickname: "World", profilePicture: "globe", userID: "POSTMAN_WORLD"))
            }
            .sheet(isPresented: $showIntro) {
                Intro(isPresented: $showIntro)
                    .interactiveDismissDisabled()
            }
            .popover(isPresented: $showSettings) {
                Settings(isPresented: $showSettings)
            }
            .fullScreenCover(isPresented: $addFriend) {
                Add()
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button(action: {
                        self.showSettings.toggle()
                    }) {
                        Image(systemName: "gear")
                    }
                }
                
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        self.addFriend.toggle()
                    }) {
                        Image(systemName: "plus.circle")
                    }
                }
            }
        }
        .alert(isPresented: $showVerify) {
            Alert(title: Text("Verify"), message: Text("Check your inbox for a verification email from Postman Support."), primaryButton: .default(Text("Resend")) {
                AccountViewModel().sendVerificationEmail(AccountViewModel().getInfo(.email) as! String, AccountViewModel().getInfo(.password) as! String)
            }, secondaryButton: .default(Text("Dismiss")))
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}

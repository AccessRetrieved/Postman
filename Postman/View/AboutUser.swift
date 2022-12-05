//
//  AboutUser.swift
//  Postman
//
//  Created by 胡家睿 on 2021/8/13.
//

import SwiftUI

struct AboutUser: View {
    var user: User
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentation
    @State var share = false
    @ObservedObject var firebase = FirebaseViewModel()
    
    var body: some View {
        VStack {
            Section {
                HStack {
                    Spacer()
                    
                    VStack {
                        Circle()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.clear)
                            .overlay(
                                Image(user.profilePicture)
                                    .resizable()
                                    .frame(width: 101, height: 101)
                                    .clipShape(Circle())
                            )
                        
                        Text(user.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding()
                        
                        Text(user.userID)
                            .foregroundColor(.gray)
                            .font(.title2)
                            .padding()
                    }
                    
                    Spacer()
                }
                .padding(.top, 150)
            }
            .listRowBackground(colorScheme == .dark ? Color(red: 28/255, green: 27/255, blue: 29/255) : Color(red: 242/255, green: 241/255, blue: 245/255))
            
            Section {
                HStack {
                    Spacer()
                    
                    VStack(spacing: 10) {
                        HStack {
                            Button(action: {
                                if user.userID != "POSTMAN_OFFICIAL" && user.userID != "POSTMAN_WORLD" {
                                    firebase.delete(documentName: user.userID, collectionName: AccountViewModel().getInfo(.email) as! String)
                                    presentation.wrappedValue.dismiss()
                                }
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.white)
                                    .background(Color.red)
                                    .frame(maxWidth: .infinity)
                                    .font(.title2)
                            }
                            .frame(width: 161, height: 50)
                            .background(Color.red)
                            .cornerRadius(15)
                            
                            Button(action: {
                                self.share.toggle()
                            }) {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(.white)
                                    .background(Color.yellow)
                                    .frame(maxWidth: .infinity)
                                    .font(.title2)
                            }
                            .frame(width: 161, height: 50)
                            .background(Color.yellow)
                            .cornerRadius(15)
                        }
                        
                        Button(action: {
                            self.presentation.wrappedValue.dismiss()
                        }) {
                            Text("Close")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                                .background(Color.blue)
                        }
                        .frame(width: 325, height: 50)
                        .background(Color.blue)
                        .cornerRadius(15)
                    }
                    .sheet(isPresented: $share) {
                        ShareSheet(activityItems: [user.userID])
                    }
                    
                    Spacer()
                }
                .padding(.top, 250)
            }
            .listRowBackground(colorScheme == .dark ? Color(red: 28/255, green: 27/255, blue: 29/255) : Color(red: 242/255, green: 241/255, blue: 245/255))
        }
    }
}

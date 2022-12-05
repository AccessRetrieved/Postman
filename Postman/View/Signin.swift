//
//  Signup.swift
//  Postman
//
//  Created by 胡家睿 on 2021/7/28.
//

import SwiftUI

struct Signin: View {
    @ObservedObject var viewModel = AccountViewModel()
    @Environment(\.presentationMode) var presentation
    @Environment(\.colorScheme) var color
    @State var reset = false
    @State var isAnimating = false
    @State var showNFC = false
    
    var body: some View {
        VStack {
            VStack {
                VStack {
                    Titlebar(title: "Sign in", subTitle: "", withArrow: true)
                        .padding(.top, 20)
                    
                    VStack(alignment: .leading) {
                        Text("Please enter your email and password.")
                            .padding(.bottom, 80)
                        
                        CustomStyledTextField(text: $viewModel.email, placeholder: "Email", symbolName: "person.circle.fill", onCommit: {}, uppercased: false, email: true)
                            .autocapitalization(.none)
                        
                        CustomStyledSecureTextField(text: $viewModel.password, placeholder: "Password", symbolName: "key.fill", onCommit: {})
                        
                        CustomStyledButton(title: "Sign in", action: viewModel.signin, loading: $viewModel.isLoading)
                            .disabled(viewModel.email.isEmpty)
                            .disabled(viewModel.password.isEmpty)
                            .padding(.top, 20)
                            .opacity(isAnimating ? 1 : 0)
                            .animation(Animation.spring())
                        
                        HStack {
                            Spacer()
                            
                            if viewModel.email.isEmpty {
                                Button(action: {
                                    reset = true
                                }) {
                                    Text(reset ? "Please enter your email" : "I forgot my password")
                                        .fontWeight(.bold)
                                }
                                .padding(.top, 20)
                            } else {
                                Button(action: {
                                    viewModel.resetPassword()
                                }) {
                                    Text(viewModel.reset ? "Instructions sent to \(viewModel.email)." : "I forgot my password")
                                        .fontWeight(.bold)
                                }
                                .disabled(viewModel.email.isEmpty)
                                .padding(.top, 20)
                                .disabled(viewModel.reset)
                            }
                            
                            Spacer()
                        }
                        
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                withAnimation(.spring().delay(0.1)) {
                                    self.showNFC.toggle()
                                }
                            }) {
                                Text("Login with NFC")
                                    .fontWeight(.bold)
                            }
                            .padding(.top, 5)
                            
                            Spacer()
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .padding(.bottom, 350)
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                    
                    Spacer()
                }
                .padding(.top, 25)
                .alert(isPresented: $viewModel.showError) {
                    Alert(title: Text("An unexpected error occurred"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("Close")))
                }
                
                Spacer()
            }
            .animation(.spring().delay(0.1), value: showNFC)
            .sheet(isPresented: $showNFC) {
                NFCReader()
                    .animation(.spring().delay(0.1), value: showNFC)
            }
        }
        .onAppear {
            isAnimating = true
            
            print(showNFC)
            if !showNFC {
                self.presentation.wrappedValue.dismiss()
            }
        }
    }
}

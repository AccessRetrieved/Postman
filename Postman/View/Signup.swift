//
//  Signin.swift
//  Postman
//
//  Created by 胡家睿 on 2021/7/28.
//

import SwiftUI

struct Signup: View {
    @ObservedObject var viewModel = AccountViewModel()
    @Environment(\.presentationMode) var presentation
    @State var reset = false
    @State var isAnimating = false
    
    func foundInt(_ string: String) -> Bool {
        let decimalCharacters = CharacterSet.decimalDigits
        let decimalRange = string.rangeOfCharacter(from: decimalCharacters)
        
        if decimalRange != nil {
            return true
        } else {
            return false
        }
    }
    
    func disableNext(_ email: String, _ password: String) -> Bool {
        let int = foundInt(password)
        
        if int == true && password.count > 6 && checkEmail(email) == true {
            // Undisable
            return false
        } else {
            // Disable
            return true
        }
    }
    
    func checkEmail(_ string: String) -> Bool {
        if string.count > 100 {
            return false
        }
        
        let emailFormat = "(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}" + "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" + "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-" + "z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5" + "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" + "9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" + "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: string)
    }
    
    var body: some View {
        ZStack {
            VStack {
                Titlebar(title: "Sign up", subTitle: "", withArrow: true)
                    .padding(.top, 30)
                
                VStack(alignment: .leading) {
                    Text("Please enter a valid email and create a password.")
                        .padding(.bottom, 50)
                    
                    CustomStyledTextField(text: $viewModel.email, placeholder: "Email", symbolName: "person.circle.fill", onCommit: {}, uppercased: false, email: true)
                        .autocapitalization(.none)
                    
                    CustomStyledSecureTextField(text: $viewModel.password, placeholder: "Password", symbolName: "key.fill", onCommit: {})
                    
                    Spacer(minLength: 30)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            VStack(alignment: .leading, spacing: 15) {
                                HStack(spacing: 10) {
                                    Image(systemName: "checkmark.circle")
                                    
                                    Text("Longer than 6 characters")
                                }
                                .font(.subheadline)
                                .foregroundColor(viewModel.password.count <= 6 ? .red : .green)
                                
                                HStack {
                                    Image(systemName: "checkmark.circle")
                                    
                                    Text("Contains at lease 1 digit")
                                }
                                .font(.subheadline)
                                .foregroundColor(foundInt(viewModel.password) ? .green : .red)
                                
                                HStack {
                                    Image(systemName: "checkmark.circle")
                                    
                                    Text("Email is formatted correctly")
                                }
                                .font(.subheadline)
                                .foregroundColor(checkEmail(viewModel.email) ? .green : .red)
                            }
                            .padding()
                            
                            Spacer()
                        }
                    }
                    
                    CustomStyledButton(title: "Sign up", action: viewModel.signup, loading: $viewModel.isLoading)
                        .disabled(disableNext(viewModel.email, viewModel.password))
                        .padding(.top, 20)
                        .opacity(isAnimating ? 1 : 0)
                        .animation(Animation.spring())
                    
                    Spacer()
                }
                .padding()
                .padding(.bottom, 300)
                .ignoresSafeArea(.keyboard, edges: .bottom)
                
                Spacer()
            }
            .alert(isPresented: $viewModel.showError) {
                Alert(title: Text("An unexpected error occurred"), message: Text(viewModel.errorMessage), primaryButton: .default(Text("Try again")) {
                    viewModel.signup()
                }, secondaryButton: .cancel(Text("Close")))
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

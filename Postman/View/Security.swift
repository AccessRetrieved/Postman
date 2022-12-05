//
//  Security.swift
//  Postman
//
//  Created by 胡家睿 on 2021/8/30.
//

import SwiftUI

struct EnterPassword: View {
    @Binding var password: String
    var title: String
    var subtitle: String
    @Environment(\.presentationMode) var presentation
    
    var body: some View {
        VStack {
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.top, 40)
            
            Text(subtitle)
                .foregroundColor(.gray)
                .font(.subheadline)
                .padding(.top, 10)
            
            Spacer()
            
            CustomStyledSecureTextField(text: $password, placeholder: "Enter your password", symbolName: "key.fill", onCommit: {})
                .padding([.leading, .trailing])
                .padding(.bottom, 250)
            
            Spacer()
            
            Button(action: {
                self.presentation.wrappedValue.dismiss()
            }) {
                Text("Done")
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .background(Color.blue)
            }
            .frame(width: 325, height: 50)
            .background(Color.blue)
            .cornerRadius(15)
            .padding(.bottom, 50)
        }
    }
}

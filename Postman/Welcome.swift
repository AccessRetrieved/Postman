//
//  Welcome.swift
//  Postman
//
//  Created by 胡家睿 on 2021/7/28.
//

import SwiftUI

struct Welcome: View {
    @State var isAnimating = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.orange, .red, .blue]), startPoint: .top,endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("Postman")
                        .font(.custom("Marker Felt", size: 40))
                        .opacity(isAnimating ? 1 : 0)
                        .foregroundColor(.white)
                        .animation(Animation.spring().delay(0.5))
                    
                    Text("End-to-end conversations made easier")
                        .font(.custom("Marker Felt", size: 15))
                        .opacity(isAnimating ? 1 : 0)
                        .foregroundColor(.white)
                        .animation(Animation.spring().delay(2))
                        .padding(.top, 3)
                    
                    Spacer()
                    
                    HStack(spacing: 30) {
                        NavigationLink(destination: Signin().navigationBarHidden(true).navigationBarBackButtonHidden(true)) {
                            Text("Sign in")
                                .foregroundColor(.black)
                                .font(.custom("Avenir", size: 20))
                                .frame(width: UIScreen.main.bounds.width / 2 - 50, height: 60)
                                .background(Color("yellow"))
                                .cornerRadius(16)
                        }
                        .padding(.bottom, 55)
                        .opacity(isAnimating ? 1 : 0)
                        .animation(Animation.spring().delay(0.5))
                        
                        NavigationLink(destination: Signup().navigationBarHidden(true).navigationBarBackButtonHidden(true)) {
                            Text("Sign up")
                                .foregroundColor(.black)
                                .font(.custom("Avenir", size: 20))
                                .frame(width: UIScreen.main.bounds.width / 2 - 50, height: 60)
                                .background(Color("lightBlue"))
                                .cornerRadius(16)
                        }
                        .padding(.bottom, 55)
                        .opacity(isAnimating ? 1 : 0)
                        .animation(Animation.spring().delay(0.6))
                    }
                }
            }
            .onAppear {
                isAnimating = true
            }
        }
    }
}

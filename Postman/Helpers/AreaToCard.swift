//
//  AreaToCard.swift
//  Chat
//
//  Created by 胡家睿 on 2021/5/12.
//

import SwiftUI

struct AreaToCard : View {
    @State var show = false
    let title: String
    let message: String
    
    var body: some View {
        VStack() {
            Text(title)
                .foregroundColor(.white)
                .fontWeight(.bold)
                .font(.title)
                .padding(.top, show ? 30 : 20)
                .padding(.bottom, show ? 20 : 0)
            
            Spacer()
            
            Text(message)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .animation(.spring(), value: show)
                .cornerRadius(0)
                .lineLimit(.none)
            
            Spacer()
            
            Button(action: {
                self.show.toggle()
            }) {
                HStack {
                    Image(systemName: show ? "slash.circle.fill" : "slash.circle")
                        .foregroundColor(Color(hue: 0.498, saturation: 0.609, brightness: 1.0))
                        .font(Font.title.weight(.semibold))
                        .imageScale(.small)
                    Text(show ? "Hide" : "Show")
                        .foregroundColor(Color(hue: 0.498, saturation: 0.609, brightness: 1.0))
                        .fontWeight(.bold)
                        .font(.title)
                        .cornerRadius(0)
                }
            }
            .padding(.bottom, show ? 20 : 15)
            
        }
        .padding()
        .padding(.top, 15)
        .frame(width: show ? 350 : 290, height: show ? 420 : 260)
        .background(Color.blue)
        .cornerRadius(30)
        .animation(.spring())
    }
}

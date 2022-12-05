//
//  Test.swift
//  Postman
//
//  Created by 胡家睿 on 2021/8/16.
//

import SwiftUI

struct appView: View {
    let title: String
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                RoundedRectangle(cornerRadius: 5)
                    .frame(width: 45, height: 45)
                    .overlay(
                        Image("postman")
                            .resizable()
                            .frame(width: 46, height: 46)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                    )
                    .padding()
                
                Text(title)
                    .font(.title3)
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding([.leading, .trailing], 5)
            .padding(.top, 5)
        }
    }

}

struct Test: View {
    @State var text = ""
    @State var apps = ["Postman", "睿睿记账", "AirController"]
    
    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
                .opacity(0.2)
            
            VStack {
                TextField("App资源库", text: $text)
                    .multilineTextAlignment(.center)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 16.0, style: .circular)
                            .foregroundColor(Color(.secondarySystemFill))
//                            .opacity(0.6)
                            .blur(radius: 10)
                    )
                    .padding(.init(top: 20, leading: 10, bottom: 10, trailing: 10))
                
                VStack(alignment: .leading) {
                    appView(title: "Postman")
                    appView(title: "睿睿记账")
                    appView(title: "AirController")
                }
                            
                Spacer()
            }
        }
    }
}

struct Test_Previews: PreviewProvider {
    static var previews: some View {
        Test()
    }
}

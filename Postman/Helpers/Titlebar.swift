//
//  Titlebar.swift
//  RuiRuiJiZhang
//
//  Created by 胡家睿 on 2021/7/20.
//

import SwiftUI

struct Titlebar: View {
    var title : String = ""
    var subTitle : String = ""
    var withArrow = true
    @State var isAnimating = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                if withArrow {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20))
                        .offset(x: 0, y: 8)
                        .padding(.trailing, 5)
                        .opacity(self.isAnimating ? 1 : 0)
                        .animation(Animation.spring().delay(0.0))
                        .onTapGesture {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .modifier(BigTitle())
                        .padding(.bottom, 5)
                        .opacity(self.isAnimating ? 1 : 0)
                        .animation(Animation.spring().delay(0.1))
                    
                    Text(subTitle)
                        .modifier(SubTitle())
                        .opacity(self.isAnimating ? 1 : 0)
                        .animation(Animation.spring().delay(0.2))
                }
                
                Spacer()
            }
            .frame(width : UIScreen.main.bounds.width - 40)
            .onAppear {
                self.isAnimating = true
            }
            .padding(.top, 5)
            
            Spacer()
        }
    }
}

struct Titlebar_Previews: PreviewProvider {
    static var previews: some View {
        Titlebar(title: "iOS Programming", subTitle: "100 tutorials in the list.")
    }
}


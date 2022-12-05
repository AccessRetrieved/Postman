//
//  Titlebar.swift
//  RuiRuiJiZhang
//
//  Created by 胡家睿 on 2021/7/20.
//

import SwiftUI

struct ChatTitleBar: View {
    var title : String = ""
    var subTitle : String = ""
    var withArrow = true
    var profileImage: Image = Image(systemName: "person.fill")
    @Binding var showMoreMenu: Bool
    @State var isAnimating = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                if withArrow {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20))
                        .offset(x: 0, y: 8)
                        .padding(.top, 5)
                        .padding(.trailing, 5)
                        .opacity(self.isAnimating ? 1 : 0)
                        .animation(Animation.spring().delay(0.0))
                        .onTapGesture {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                }
                
                HStack {
                    RoundedRectangle(cornerRadius: 7)
                        .frame(width: 50, height: 50)
                        .foregroundColor(.clear)
                        .overlay(
                            profileImage
                                .resizable()
                                .frame(width: 51, height: 51)
                                .clipShape(RoundedRectangle(cornerRadius: 7))
                        )
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text(title)
                            .modifier(BigTitle())
                            .padding(.bottom, 5)
                            .opacity(self.isAnimating ? 1 : 0)
                            .animation(Animation.spring().delay(0.1), value: isAnimating)
                        
                        HStack {
                            Text(subTitle)
                                .modifier(SubTitle())
                                .opacity(self.isAnimating ? 1 : 0)
                                .animation(Animation.spring().delay(0.2), value: isAnimating)
                            
                            if subTitle == "Online" {
                                Circle()
                                    .frame(width: 10, height: 10)
                                    .foregroundColor(.green)
                                    .opacity(self.isAnimating ? 1 : 0)
                                    .animation(Animation.spring().delay(0.3), value: isAnimating)
                            } else {
                                Circle()
                                    .frame(width: 10, height: 10)
                                    .foregroundColor(.red)
                                    .opacity(self.isAnimating ? 1 : 0)
                                    .animation(Animation.spring().delay(0.4), value: isAnimating)
                            }
                        }
                    }
                    .onTapGesture {
                        self.showMoreMenu.toggle()
                    }
                }
                
                Spacer()
                
                HStack(spacing: 20) {
                    Button(action: {
                        
                    }) {
                        Image(systemName: "phone")
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .font(.title2)
                    }
                    
                    Button(action: {
                        showMoreMenu.toggle()
                    }) {
                        Image(systemName: "ellipsis")
                            .rotationEffect(Angle(degrees: -90))
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .font(.title2)
                    }
                }
                .padding()
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

struct ChatTitleBar_Previews: PreviewProvider {
    static var previews: some View {
        ChatTitleBar(title: "Jerry Hu", subTitle: "Online", showMoreMenu: .constant(false))
    }
}


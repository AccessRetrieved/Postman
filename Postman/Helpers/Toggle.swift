//
//  RoundCheckboxStyle.swift
//  lilos
//
//  Created by 胡家睿 on 2021/6/18.
//

import SwiftUI
import CryptoKit

struct CheckboxStyle: ToggleStyle {
    @Binding var enabled: Bool
    
    func makeBody(configuration: Self.Configuration) -> some View {
        return HStack {
            configuration.label
            
            Spacer()
            
            if enabled {
                Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(configuration.isOn ? .accentColor : .gray)
                    .font(.system(size: 20, weight: .bold, design: .default))
                    .onTapGesture {
                        configuration.isOn.toggle()
                    }
            } else {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.red)
                    .font(.system(size: 20, weight: .bold, design: .default))
            }
        }
    }
}

//
//  Add.swift
//  Postman
//
//  Created by 胡家睿 on 2021/8/13.
//

import SwiftUI
import CoreImage.CIFilterBuiltins
import FirebaseFirestore
import CodeScanner

struct Add: View {
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    @State var myCode = UserDefaults.standard.string(forKey: "myUserID")!
    @Environment(\.presentationMode) var presentation
    @Environment(\.colorScheme) var colorScheme
    @State var loading = true
    @State var showField = false
    @State var enterfriendCode = ""
    @State var blur = false
    @State var error = ""
    @State var showError = false
    @State var showSuccess = false
    @State var newFriend = FirebaseUser(isOnline: false, name: "", nickname: "", profilePicture: "", userID: "")
    @State var scanned = false
    @ObservedObject var postman = AppPostman()
    @ObservedObject var firebase = FirebaseViewModel()
    @State var retry = false
    @State var showScanner = false
    @State var isAnimatingLine = false

    func generateQrCode(from string: String) -> UIImage {
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")
        
        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }
        
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
    
    func format(with mask: String, phone: String) -> String {
        let numbers = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var result = ""
        var index = numbers.startIndex // numbers iterator

        for ch in mask where index < numbers.endIndex {
            if ch == "X" {
                result.append(numbers[index])

                index = numbers.index(after: index)

            } else {
                result.append(ch)
            }
        }
        return result
    }
    
    func simpleSuccess() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    func addFriend() {
        var users: [FirebaseUser] = []
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring().delay(0.2)) {
                self.blur = true
            }
            
            if enterfriendCode.count == 23 {
                if enterfriendCode != myCode {
                    firebase.fetchAllData()
                    
                    for i in firebase.allusers {
                        users.append(i)
                    }
                    
                    for i in users {
                        if enterfriendCode == i.userID {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                withAnimation(.spring().delay(0.1)) {
                                    self.blur = false
                                }
                            }
                            
                            self.newFriend = FirebaseUser(isOnline: i.isOnline, name: i.name, nickname: i.nickname, profilePicture: i.profilePicture, userID: i.userID)
                            self.showSuccess = true
                            self.scanned = true
                            break
                        }
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation(.spring().delay(0.1)) {
                            self.blur = false
                        }
                        
                        if !scanned {
                            if retry {
                                self.error = "This user does not exist."
                                self.showError = true
                            } else {
                                self.retry = true
                                addFriend()
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now()  + 1.5) {
                        withAnimation(.spring().delay(0.1)) {
                            self.blur = false
                        }
                        
                        self.error = "This friend code is invalid."
                        self.showError = true
                    }
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now()  + 1.5) {
                    withAnimation(.spring().delay(0.1)) {
                        self.blur = false
                    }
                    
                    self.error = "This friend code is invalid."
                    self.showError = true
                }
            }
        }
    }
    
    var body: some View {
        let gesture = DragGesture()
            .onChanged { gesture in
                if gesture.startLocation.x < CGFloat(50) {
                    self.presentation.wrappedValue.dismiss()
                }
            }
        
        ZStack {
            NavigationView {
                GeometryReader { reader in
                    VStack(spacing: 50) {
                        ZStack {
                            if loading {
                                Image(uiImage: generateQrCode(from: "POSTMAN_USER_XXXXXX"))
                                    .resizable()
                                    .interpolation(.none)
                                    .scaledToFit()
                                    .frame(width: 150, height: 150)
                                    .opacity(0.05)
                                
                                ProgressView()
                                    .frame(width: 30, height: 30)
                            } else {
                                Image(uiImage: generateQrCode(from: myCode))
                                    .resizable()
                                    .interpolation(.none)
                                    .scaledToFit()
                                    .frame(width: 150, height: 150)
                            }
                        }
                        
                        VStack(spacing: 10) {
                            Text("\(myCode)")
                            
                            if showField {
                                HStack(spacing: 10) {
                                    HStack {
                                        Image(systemName: "person.badge.plus")
                                            .imageScale(.large)
                                            .padding(.leading)
                                        
                                        TextField("POSTMAN_USER_", text: $enterfriendCode)
                                            .padding(.vertical)
                                            .accentColor(.orange)
                                            .autocapitalization(.none)
                                            .onChange(of: enterfriendCode) { value in
                                                enterfriendCode = format(with: "POSTMAN_USER_XXXXXXXXXX", phone: value)
                                                
                                                simpleSuccess()
                                                
                                                withAnimation(.spring()) {
                                                    self.showSuccess = false
                                                }
                                            }
                                            .keyboardType(.numberPad)
                                    }
                                    .background(
                                        RoundedRectangle(cornerRadius: 16.0, style: .circular)
                                            .foregroundColor(Color(.secondarySystemFill))
                                    )
                                    
                                    Button(action: {
                                        addFriend()
                                    }) {
                                        Text("Add")
                                            .foregroundColor(.white)
                                            .background(Color.blue)
                                            .frame(maxWidth: .infinity)
                                    }
                                    .frame(width: 85, height: 50)
                                    .background(Color.blue)
                                    .cornerRadius(15)
                                    .disabled(showSuccess)
                                }
                                .frame(width: 350)
                            } else {
                                Button(action: {
                                    withAnimation(.spring()) {
                                        self.showField.toggle()
                                    }
                                }) {
                                    Text("Enter a Postman Friend Code")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                    .alert(isPresented: $showError) {
                        Alert(title: Text(error), message: Text(""), primaryButton: .cancel(), secondaryButton: .default(Text("Try again")) {
                            self.retry = false
                            addFriend()
                        })
                    }
                    .position(x: reader.size.width / 2, y: reader.size.height / 3.5)
                    .navigationTitle("Add a friend")
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarTrailing) {
                            Button(action:{
                                self.presentation.wrappedValue.dismiss()
                            }) {
                                Image(systemName: "chevron.down.circle.fill")
                            }
                        }
                        
                        ToolbarItemGroup(placement: .navigationBarLeading) {
                            Button(action: {
                                self.showScanner.toggle()
                            }) {
                                Image(systemName: "qrcode.viewfinder")
                            }
                        }
                    }
                    .fullScreenCover(isPresented: $showScanner) {
                        scanner
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            self.loading = false
                        }
                    }
                }
            }
            .blur(radius: blur ? 30 : 0)
            .disabled(blur)
            
            if blur {
                ProgressView()
                    .font(.title)
            }
            
            if showSuccess {
                SlideOverCard(position: .middle) {
                    VStack {
                        Section {
                            HStack {
                                Spacer()
                                
                                VStack {
                                    Circle()
                                        .frame(width: 100, height: 100)
                                        .foregroundColor(.clear)
                                        .overlay(
                                            Image("defaultUser")
                                                .resizable()
                                                .frame(width: 101, height: 101)
                                                .clipShape(Circle())
                                        )
                                    
                                    Text(self.newFriend.nickname)
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
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
                                    Button(action: {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                            let db = Firestore.firestore()
                                            let docRef = db.collection("users").document(enterfriendCode)
                                            docRef.getDocument { (document, error) in
                                                if let document = document, document.exists {
                                                    self.error = "Friend already exists."
                                                    self.showError = true
                                                } else {
                                                    withAnimation {
                                                        let user = FirebaseUser(isOnline: newFriend.isOnline, name: newFriend.name, nickname: newFriend.nickname, profilePicture: newFriend.profilePicture, userID: newFriend.userID)
                                                        firebase.add(user)
                                                        
                                                        self.presentation.wrappedValue.dismiss()
                                                    }
                                                }
                                            }
                                        }
                                    }) {
                                        Text("Add")
                                            .frame(maxWidth: .infinity)
                                            .foregroundColor(.white)
                                            .background(Color.blue)
                                    }
                                    .frame(width: 325, height: 50)
                                    .background(Color.blue)
                                    .cornerRadius(15)
                                }
                                
                                Spacer()
                            }
                            .padding(.top, 250)
                        }
                        .listRowBackground(colorScheme == .dark ? Color(red: 28/255, green: 27/255, blue: 29/255) : Color(red: 242/255, green: 241/255, blue: 245/255))
                    }
                }
            }
        }
        .gesture(gesture)
    }
    
    var scanner: some View {
        NavigationView {
            let gesture = DragGesture()
                .onChanged { gesture in
                    if gesture.startLocation.x < CGFloat(50) {
                        self.showScanner = false
                    }
                }
            
            CodeScannerView(codeTypes: [.qr, .face], scanMode: .oncePerCode, scanInterval: 3, simulatedData: "POSTMAN_OFFICIAL", completion: { result in
                switch result {
                case .success(let code1):
                    self.enterfriendCode = code1
                    self.showField = true
                    self.showScanner = false
                case .failure(let error):
                    print(error.localizedDescription)
                    self.showScanner = false
                }
            })
                .gesture(gesture)
                .edgesIgnoringSafeArea(.all)
                .overlay(
                    VStack {
                    Spacer()
                    
                    Rectangle()
                        .trim()
                        .fill(.blue)
                        .frame(height: 2)
                        .edgesIgnoringSafeArea(.horizontal)
                        .offset(y: isAnimatingLine ? 125 : -125)
                        .animation(Animation.linear(duration: 2).repeatForever(), value: isAnimatingLine)
                        .shadow(color: .blue.opacity(0.4), radius: 5, x: 0, y: -1)
                        .shadow(color: .blue.opacity(0.4), radius: 5, x: 0, y: -2)
                        .shadow(color: .blue.opacity(0.4), radius: 5, x: 0, y: -3)
                        .shadow(color: .blue.opacity(0.4), radius: 5, x: 0, y: 1)
                        .shadow(color: .blue.opacity(0.4), radius: 5, x: 0, y: 2)
                        .shadow(color: .blue.opacity(0.4), radius: 5, x: 0, y: 3)
                        
                    Spacer()
                }
                )
                .onAppear {
                    isAnimatingLine.toggle()
                }
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button(action: {
                            self.showScanner = false
                        }) {
                            Image(systemName: "chevron.down.circle.fill")
                        }
                    }
                }
        }
    }
}

//
//  Chat.swift
//  ChatExample
//
//  Created by 胡家睿 on 2021/8/11.
//

import SwiftUI

struct Chat: View {
    @Environment(\.presentationMode) var presentation
    var user: User
    @State var text = ""
    @State var yoffset: CGFloat = 0
    @State var showMenu = false
    @ObservedObject var postman = AppPostman()
    @ObservedObject var chatMessageViewModel = FetchMessagesViewModel()
    enum Field: Hashable {
        case message
    }
//    @FocusState private var focusedField: Field?
    @State var viewImage = UIImage()
    
    func simpleSuccess() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    func getTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d hh:mm:ss"
        return formatter.string(from: Date())
    }
    
    var messagesForeach: some View {
        ScrollView {
            ScrollViewReader { reader in
                VStack {
                    HStack {
                        MessageView(message: "Welcome to channel #\(user.nickname.lowercased().replacingOccurrences(of: " ", with: "-")) 👋", time: postman.formatMessageTime(timeString: getTime()), senderSelf: false, userID: user.userID, messageID: "")
                        
                        
                        Spacer()
                    }
                    .padding([.leading, .trailing])
                    .padding([.top, .bottom])
                    
                    ForEach(chatMessageViewModel.messages, id: \.id) { message in
                        HStack {
                            if message.senderUserID == UserDefaults.standard.string(forKey: "myUserID")! {
                                VStack {
                                    HStack {
                                        Spacer()
                                        
                                        Text(postman.getDate(date: postman.formatMessageTime(timeString: message.time)))
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        
                                        Spacer()
                                    }
                                    
                                    HStack {
                                        Spacer()
                                        
                                        MessageView(message: message.msg, time: postman.formatMessageTime(timeString: message.time), senderSelf: message.senderUserID == UserDefaults.standard.string(forKey: "myUserID")! ? true : false, userID: user.userID, messageID: message.id)
                                    }
                                }
                            } else {
                                VStack {
                                    HStack {
                                        Spacer()
                                        
                                        Text(postman.getDate(date: postman.formatMessageTime(timeString: message.time)))
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        
                                        Spacer()
                                    }
                                    
                                    HStack {
                                        MessageView(message: message.msg, time: postman.formatMessageTime(timeString: message.time), senderSelf: message.senderUserID == UserDefaults.standard.string(forKey: "myUserID")! ? true : false, userID: user.userID, messageID: message.id)
                                        
                                        
                                        Spacer()
                                    }
                                }
                            }
                        }
                        .padding([.leading, .trailing])
                        .padding([.top, .bottom])
                        .id(chatMessageViewModel.messages.last?.id)
                    }
                    
                    Spacer()
                }
                .onChange(of: chatMessageViewModel.messages) { id in
                    withAnimation() {
                        reader.scrollTo(id.last?.id, anchor: .center)
                    }
                }
            }
        }
    }
    
    var card: some View {
        Rectangle()
            .frame(width: 600, height: 650)
            .foregroundColor(Color("bg"))
            .background(Color("bg"))
            .overlay(
                VStack {
                Text("\(UserDefaults.standard.string(forKey: "name")!) ~ \(user.nickname)")
                    .font(.custom("OpenSans-Regular", size: 20))
                
                Spacer()
                
                ForEach(chatMessageViewModel.messages.suffix(5), id: \.id) { message in
                    HStack {
                        if message.senderUserID == UserDefaults.standard.string(forKey: "myUserID")! {
                            VStack {
                                HStack {
                                    Spacer()
                                    
                                    MessageView(message: message.msg, time: postman.formatMessageTime(timeString: message.time), senderSelf: message.senderUserID == UserDefaults.standard.string(forKey: "myUserID")! ? true : false, userID: user.userID, messageID: message.id)
                                }
                            }
                        } else {
                            VStack {
                                HStack {
                                    MessageView(message: message.msg, time: postman.formatMessageTime(timeString: message.time), senderSelf: message.senderUserID == UserDefaults.standard.string(forKey: "myUserID")! ? true : false, userID: user.userID, messageID: message.id)
                                    
                                    
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding([.leading, .trailing])
                    .padding([.top, .bottom])
                }

                Spacer()
                
                VStack {
                    Divider()
                        .padding([.leading, .trailing], 20)
                    
                    HStack {
                        Image(uiImage: postman.generateQrCode(from: "https://accessretrieved.github.io"))
                            .resizable()
                            .frame(width: 45, height: 45)
                        
                        VStack(alignment: .leading) {
                            Text("Postman")
                                .font(.custom("Marker Felt", size: 17))
                            
                            Text("Making end-to-end conversations easier")
                                .foregroundColor(.gray)
                                .font(.footnote)
                        }
                        
                        Spacer()
                        
                        Image("appStore")
                            .resizable()
                            .frame(width: 120, height: 40)
                            .padding(.trailing, 10)
                    }
                    .padding([.leading, .trailing])
                    .padding(.top, 15)
                }
                .offset(y: -60)
            }
            )
    }
    
    var body: some View {
        VStack {
            VStack {
                ChatTitleBar(title: user.nickname, subTitle: user.isOnline ? "Online" : "Offline", withArrow: true, profileImage: Image(user.profilePicture), showMoreMenu: $showMenu)
                    .padding(.top, 20)
                    .padding(.bottom, 20)
            }
            
            VStack {
                messagesForeach
                
                Spacer()
            }
            .offset(y: -50)
            .frame(height: 680)
            .overlay(
                VStack {
                Spacer()
                
                HStack {
                    TextField("Send a msg...", text: $text, onCommit: {
                        yoffset = 0
                    })
//                        .focused($focusedField, equals: .message)
                        .onChange(of: text) { word in
                            simpleSuccess()
                        }
                        .onTapGesture {
                            yoffset = -165
//                            focusedField = .message
                        }
                        .padding()
                        .accentColor(.orange)
                        .background(
                            RoundedRectangle(cornerRadius: 16.0, style: .circular)
                                .foregroundColor(Color(.secondarySystemFill))
                        )
                    
                    Button(action: {
                        if text != "" {
                            chatMessageViewModel.sendMessage(Message(id: UUID().uuidString, msg: text, senderUserID: UserDefaults.standard.string(forKey: "myUserID")!, receiverUserID: user.userID, time: getTime()))
                            print(chatMessageViewModel.messages)
                        }
                        
                        text = ""
                    }) {
                        Circle()
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "arrow.up.circle")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            )
                            .foregroundColor(Color.blue)
                    }
                    .frame(width: 40, height: 40)
                }
                .padding(.bottom, 15)
                .padding(.top, 5)
                .padding([.leading, .trailing], 10)
                .offset(y: yoffset)
                .background(Color(UIColor.systemBackground))
            }
            )
        }
        .sheet(isPresented: $showMenu) {
            AboutUser(user: user)
        }
        .onAppear {
            chatMessageViewModel.fetchMessages(user.userID)
            chatMessageViewModel.fetchMessages(UserDefaults.standard.string(forKey: "myUserID")!)
            
            print(chatMessageViewModel.messages)
        }
        .contextMenu {
            Button(action: {
                chatMessageViewModel.clearHistory(user.userID)
                chatMessageViewModel.clearHistory(UserDefaults.standard.string(forKey: "myUserID")!)
            }) {
                Text("Clear History")
                    .foregroundColor(.red)
            }
            
            Button(action: {
                if chatMessageViewModel.messages.count < 5 {
                    let view = SPAlertView(title: "Error", message: "At lease 6 messages are needed", preset: .error)
                    view.dismissByTap = true
                    view.present(duration: 2.5, haptic: .error)
                } else {
                    self.viewImage = self.card.snapshot()
                    UIImageWriteToSavedPhotosAlbum(viewImage, nil, nil, nil)
                    
                    let view = SPAlertView(title: "Save", message: "Screenshot saved to photos", preset: .done)
                    view.dismissByTap = true
                    view.present(duration: 1.5, haptic: .success)
                    
                    let url = URL(string: "photos-redirect://")!
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                }
            }) {
                Text("Screenshot")
            }
        }
    }
}

struct Chat_Previews: PreviewProvider {
    static var previews: some View {
        Chat(user: User(id: "", name: "", profilePicture: "", isOnline: false, userID: "", nickname: ""))
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view
        
        let targetSize = controller.view.intrinsicContentSize
        let size = CGSize(width: targetSize.width, height: targetSize.height)
        view?.bounds = CGRect(origin: .zero, size: size)
        view?.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

struct MessageView: View {
    let message: String
    let time: Date
    let senderSelf: Bool
    let userID: String
    let messageID: String
    
    var body: some View {
        VStack {
            Text(message)
                .padding(10)
                .foregroundColor(senderSelf ? Color.white : Color.black)
                .background(senderSelf ? Color("self") : Color(UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)))
                .cornerRadius(10.0)
        }
        .contextMenu {
            if senderSelf {
                Button(action: {
                    FetchMessagesViewModel().recall(collectionName: userID, message: messageID)
                    FetchMessagesViewModel().recall(collectionName: UserDefaults.standard.string(forKey: "myUserID")!, message: messageID)
                }) {
                    Text("Recall")
                }
                .disabled(message == "Welcome to channel \"\(userID)\"👋")
            }
        }
    }
}

extension Array {
    func contains<T>(obj: T) -> Bool where T: Equatable {
        return self.filter({$0 as? T == obj}).count > 0
    }
}

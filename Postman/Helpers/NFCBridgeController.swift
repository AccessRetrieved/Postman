//
//  NFCBridgeController.swift
//  Postman
//
//  Created by 胡家睿 on 2021/8/25.
//

import UIKit
import SwiftUI

struct NFCReader: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIViewController
    
    func makeUIViewController(context: Context) -> UIViewController {
        let storyboard = UIStoryboard.init(name: "NFCReaderMain", bundle: .main)
        let viewController = storyboard.instantiateInitialViewController()!
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
}

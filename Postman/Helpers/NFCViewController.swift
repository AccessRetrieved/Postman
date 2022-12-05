//
//  ViewController.swift
//  NFC-Reader
//
//  Created by 胡家睿 on 2021/8/25.
//

import UIKit
import CoreNFC
import SwiftUI
import RNCryptor

class NFCViewController: UIViewController, NFCNDEFReaderSessionDelegate {
    var session: NFCNDEFReaderSession?
    @IBAction func `return`(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Begin scan
        guard NFCNDEFReaderSession.readingAvailable else {
            let alert = UIAlertController(title: "Scanning not supported", message: "This device doesn't support NFC scanning", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        scan()
    }
    
    func scan() {
        session = NFCNDEFReaderSession(delegate: self, queue: DispatchQueue.main, invalidateAfterFirstRead: true)
        session?.alertMessage = "Hold your iPhone near reader"
        session?.begin()
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        for message in messages {
            for record in message.records {
                if let string = String(data: record.payload, encoding: .ascii) {
                    if string.contains("postman://postmanUser?email=") {
                        print(string)
                        let encryptionMethod = getQueryStringParameter(url: string, param: "encryption")
                        
                        do {
                            let email = try decryptMessage(encryptedMessage: getQueryStringParameter(url: string, param: "email")!, encryptionKey: encryptionMethod!)
                            let password = try decryptMessage(encryptedMessage: getQueryStringParameter(url: string, param: "password")!, encryptionKey: encryptionMethod!)
                            
                            AccountViewModel().signinCredencials(Email: email, Password: password)
                            
                            self.navigationController?.popToRootViewController(animated: true)
                            self.dismiss(animated: true, completion: nil)
                        } catch {
                            exit(0)
                        }
                    } else {
                        DispatchQueue.main.async {
                            session.invalidate()
                            self.navigationController?.popToRootViewController(animated: true)
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                    
                    self.navigationController?.popToRootViewController(animated: true)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print(error.localizedDescription)
    }
}

extension NFCViewController {
    func getQueryStringParameter(url: String, param: String) -> String? {
      guard let url = URLComponents(string: url) else { return nil }
      return url.queryItems?.first(where: { $0.name == param })?.value
    }
    
    func decryptMessage(encryptedMessage: String, encryptionKey: String) throws -> String {
        let encryptedData = Data.init(base64Encoded: encryptedMessage)!
        let decryptedData = try RNCryptor.decrypt(data: encryptedData, withPassword: encryptionKey)
        let decryptedString = String(data: decryptedData, encoding: .utf8)!
        
        return decryptedString
    }
}

//
//  NFCReader.swift
//  Postman
//
//  Created by 胡家睿 on 2021/8/25.
//

import Foundation
import CoreNFC

class NFCWriter: NSObject, ObservableObject, NFCNDEFReaderSessionDelegate {
    var session: NFCNDEFReaderSession?
    var data = ""
    
    func scan() {
        session = NFCNDEFReaderSession(delegate: self, queue: DispatchQueue.main, invalidateAfterFirstRead: true)
        session?.alertMessage = "Hold your iPhone near NFC tag"
        session?.begin()
    }
    
    func scanWrite(data: String) {
        self.data = data
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        session?.alertMessage = "Hold your iPhone near NFC tag"
        session?.begin()
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        let str: String = data
        
        if tags.count > 1 {
            let retryInterval = DispatchTimeInterval.milliseconds(500)
            session.invalidate(errorMessage: "Please try again")
            DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval) {
                session.restartPolling()
            }
            
            return
        }
        
        let tag = tags.first!
        session.connect(to: tag) { (error: Error?) in
            if error != nil {
                session.invalidate(errorMessage: "Unable to connect to tag")
                return
            }
            
            tag.queryNDEFStatus { (ndefstatus: NFCNDEFStatus, capacity: Int, error: Error?) in
                guard error == nil else {
                    session.invalidate(errorMessage: "Unable to connect to tag")
                    return
                }
                
                switch ndefstatus {
                case .notSupported:
                    session.invalidate(errorMessage: "Unable to connect to tag")
                case .readWrite:
                    tag.writeNDEF(.init(records: [NFCNDEFPayload.wellKnownTypeURIPayload(string: "\(str)")!])) { (error: Error?) in
                        if error != nil {
                            session.invalidate(errorMessage: "Writing failed")
                        } else {
                            session.alertMessage = "Read Success"
                        }
                        
                        session.invalidate()
                    }
                case .readOnly:
                    session.invalidate(errorMessage: "Unable to write to tag")
                @unknown default:
                    session.invalidate(errorMessage: "Unknown error")
                }
            }
            
            
        }
    }
}

//
//  ConnectivityProvider.swift
//  Vibrations
//
//  Created by Antonio Tridente on 11/03/24.
//

import Foundation
import WatchConnectivity
import Combine

class ConnectivityProvider: NSObject, WCSessionDelegate{
    
    private let session: WCSession
    private var modelUpdates: PassthroughSubject<Value, Never>
    private var connectionEstablished: Bool = false
    
    init(session: WCSession = .default, modelUpdates: PassthroughSubject<Value, Never>) {
        self.session = session
        self.modelUpdates = modelUpdates
        super.init()
        self.session.delegate = self
    }
    
    func connect(){
        guard WCSession.isSupported() else {
            print("errore nella connectivity")
            return
        }
        
        session.activate()
    }
    
    func send(message: [String: Any]){
        if session.isReachable{
            session.sendMessage(message, replyHandler: nil){
                error in
                print(error.localizedDescription)
            }
        } else {
            print("Data not sent")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        
//        print("Messaggio: \(message["path"])")
        
        let value = Value(path: message["path"] as! String, value: message["value"] as! Double)
        
        DispatchQueue.main.async {
            self.modelUpdates.send(value)
        }
        
//        print(value)
        
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
        switch activationState{
        case .activated:
            connectionEstablished = true
        default:
            connectionEstablished = false
        }
        
    }
    
    
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
    }
    #endif
    
}

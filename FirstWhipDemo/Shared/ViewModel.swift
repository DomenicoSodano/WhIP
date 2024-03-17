//
//  ViewModel.swift
//  Vibrations
//
//  Created by Antonio Tridente on 11/03/24.
//


import Foundation
import Combine

var variableTest = 1

// MARK: - Value
struct Value: Codable {
    let path: String
    let value: Int
}

class ViewModel: ObservableObject{
    
    private var connectivityProvider: ConnectivityProvider
    
    @Published var scrollspeed: Int = 0
    @Published var acceleation: Int = 0
    @Published var maxAcceleration: Int = 0
    @Published var deltaY: Int = 0
    @Published var deltaX: Int = 0
    @Published var deltaZ: Int = 0
    @Published var trow: Int = 0
    @Published var avanti: Int = 0
    @Published var fineSimulazione: Int = -1
    @Published var inizioSimulazione: Int = -1
    @Published var canTrow: Int = 0
    
    @Published var vittoria: Int = 0
    
    @Published var pesca: Int = 0
    @Published var frDurability: Int = 100
    
    
    @Published var showProgressBar = false
    
    
    var valueModel: PassthroughSubject<Value, Never> = PassthroughSubject<Value, Never>()
    var requests: AnyCancellable?
    
    init (){
        self.connectivityProvider = ConnectivityProvider(modelUpdates: valueModel)
        self.connectivityProvider.connect()
        requests = valueModel.sink(receiveValue: {
            value in
            switch value.path{
            case "scrollSpeed":
                self.scrollspeed = value.value
            case "acceleration":
                self.acceleation = value.value
            case "deltaY":
                self.deltaY = value.value
            case "deltaX":
                self.deltaX = value.value
            case "deltaZ":
                self.deltaZ = value.value
                
            case "trow":
                self.trow = value.value
            case "canTrow":
                self.canTrow = value.value
            case "maxAcceleration":
                self.maxAcceleration = value.value
            case "Avanti":
                self.avanti = value.value
            case "FineSimulazione":
                self.fineSimulazione = value.value
            case "InizioSimulazione":
                self.inizioSimulazione = value.value
            case "Vittoria":
                self.vittoria = value.value
            case "Pesca":
                self.pesca = value.value
            case "frDurability":
                self.frDurability = value.value
                
            default:
                print("Error. Path = \(value.path). Value = \(value.value)")
            }
        })
        
    }
    
    func sendMessage(key: String, value: Any){
        let message = ["path": key, "value": value]
        connectivityProvider.send(message: message)
    }
    // Aggiungi questo metodo nella classe ViewModel
    
  



    
    
}

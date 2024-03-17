
import SpriteKit
import Foundation
import SwiftUI




class GameSceneScript: SKScene, SKPhysicsContactDelegate{
    
    var autolock = true
    var viewModel: ViewModel!
    var simulation: SimulazionePesce!
    
    override func sceneDidLoad() {
        // Setto il backGround a trasparente
        self.backgroundColor = UIColor.black
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if viewModel.canTrow == 1 {
            print("Reimposto la posibbilità di pescare")
            canTrow = true
            viewModel.canTrow = 0
            viewModel.sendMessage(key: "canTrow", value: 0)
        }
        
        //Autolocking function che esegue una sola volta la simulazione
        //Gli verrà permesso di
        if viewModel.inizioSimulazione == 1 && autolock {
            
            print("Inizio Simulazione")
            
            viewModel.inizioSimulazione = 0
            viewModel.sendMessage(key: "InizioSimulazione", value: 0)
            
            autolock = false
            simulation.simulate()
            
            viewModel.trow = 0
            viewModel.sendMessage(key: "trow", value: 0)
            
            
        }
        
        
        if condizioneVittoria == 0 || condizioneVittoria == 1 || condizioneVittoria == 2 {
            //Si resetta il valore iniziale della condizione di vittoria
            autolock = true
            
            switch condizioneVittoria {
                
            case 0:
                print("Invio il segnale di Vittoria.")
                viewModel.sendMessage(key: "FineSimulazione", value: 0)
                
            case 1:
                print("Invio il segnale di Sconfitta.")
                viewModel.sendMessage(key: "FineSimulazione", value: 1)
                
            case 2:
                print("Invio del segnale di rottura lenza.")
                viewModel.sendMessage(key: "FineSimulazione", value: 2)
                
            default:
                print("CondizioneVittoria Buggata. Valore \(condizioneVittoria)")

            }

            condizioneVittoria = -1
            viewModel.fineSimulazione = -1

        }
    }
    
    func setViewModel(viewModel: ViewModel ){
        
        self.viewModel = viewModel
        
        self.simulation = SimulazionePesce(viewModel: viewModel)
//        self.simulation = SimulazionePesce()
    }
    
}

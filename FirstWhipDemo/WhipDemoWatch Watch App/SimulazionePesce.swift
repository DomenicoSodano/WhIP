//
//  SimulazionePesce.swift
//  Vibrations Watch App
//
//  Created by Antonio Tridente on 05/03/24.
//

import Foundation
import WatchKit
import SwiftUI

var strenghtGlobal = 0

class SimulazionePesce {
    
    
    private let fish: HapticFish = HapticFish()
    private var fishing: HapticFishing
    private let hapticFeedback: HapticFeedback = HapticFeedback()
    var viewModel: ViewModel!
    private var initialTimer: Timer = Timer()
    private var simulationTimer: Timer = Timer()
    private var nearness: Int = 0
    private var baiting: Bool = false
    private var fishSpawned: Int = 0
    
    init(viewModel: ViewModel){
        
        self.viewModel = viewModel
        self.fishing = HapticFishing(viewModel: viewModel)
        
    }
    
    func simulate(){
        
        self.fishSpawned = Int.random(in: 0...4)
        self.initialTimer = Timer.scheduledTimer(withTimeInterval: Double.random(in: 4...10), repeats: false){ initialTimer in
            self.startSimulation()
            self.initialTimer.invalidate()
        }
    }
    
    private func startSimulation(){
        
        //si genera un numero randomico rappresentante il numero di iterazioni massime che il pesce può fare
        let iterations = Int.random(in: 5...20)
        var iterationCount = 0
        
        simulationTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true){ simulationTimer in
            
            //si genera una nuova vicinanza
            let sinRand = Int.random(in: 4...5)
            print("Ho generato il pesce numero \(sinRand)")
            //Si invalida la vicinanza precedente
            self.fish.invalidateTimer()
            
            //Si genera la nuova vicinanza sulla base della sinRand()
            switch sinRand {
                case 1:
                self.setNearness(caso: 1)
                break
                
                case 2:
                self.setNearness(caso: 2)
                break
                
                case 3: 
                self.setNearness(caso: 3)
                break
                
                case 4:
                self.setNearness(caso: 4)
                break
                
                case 5: 
                self.tryToFish()
                self.baiting = true
                break
                
                default: self.baiting = false
            }
            print("La nearness vale \(self.nearness)")
            //Si esegue una nuova vibrazione di vicinanza sulla base
            if !self.baiting {
                self.fish.aboccaPesce(nearness: Double(self.nearness), fishStrenght: self.nearness)
            }
            //Viene aumentato il contatore di iterazione, se questo supera le iterazioni massime
            //il timer attuale viene invalidato e viene iniziata una nuova simulazione ricorsivamente
            iterationCount += 1
            if iterationCount > iterations {
                self.simulationTimer.invalidate()
                self.fish.invalidateTimer()
                self.simulate()
                print("Ho fatto l'intera simulazione, ne eseguo una nuova.")
            }
        }
    }
    
    private func tryToFish(){
        
        self.baiting = false
        hapticFeedback.doVibration(timeInterval: 0.01, chooseVibration: 3, nroVibrazioni: 180)
        
        if previousScroll > scroll {
            print("Pesce abbocato")
            self.simulationTimer.invalidate()
            self.fishing.simulaForzaPesce(timeToChange: Double(self.fishSpawned))
            //Si invia il segnale di avvenuta pesca
            viewModel.sendMessage(key: "Pesca", value: 1)
        }

    }


    private func setNearness(caso: Int){
        self.nearness = 5 - caso
        self.baiting = false
    }
}


//This last class represents the fish captured who's trying to get away. It's based on the creation of a random number
//Representing the fish strenght, the time between the vibrations is managed by a switch case "casing" on the strenght variable

var condizioneVittoria = -1



class HapticFishing {
    
    var timerInterno: Timer?
    var timerEsterno: Timer?
    var observerTimer: Timer?
    var tempoIinterno = 0.0
    let hapticFeedback: HapticFeedback = HapticFeedback()
    var vittoria = 400
    var scrolling: Int = 0
    var fihsingRodDurability = 100
    var flag: Bool = false
    
    var viewModel: ViewModel
    
    init(viewModel: ViewModel){
        
        self.viewModel = viewModel
    }
    
    func simulaForzaPesce (timeToChange: Double) {
        
        timerEsterno = Timer.scheduledTimer(withTimeInterval: timeToChange + 1, repeats: true){ timerEsterno in
            
            self.timerInterno?.invalidate()
            self.observerTimer?.invalidate()
            
            let strenght = Int.random(in: 0...5)
            strenghtGlobal = strenght
            
            switch strenght {
                
            case 0:
                self.tempoIinterno = 1.0
                self.getRope(caso: 0)
                break
                
            case 1:
                self.tempoIinterno = 0.8
                self.getRope(caso: 1)
                break
                
            case 2:
                self.tempoIinterno = 0.6
                self.getRope(caso: 2)
                break
                
            case 3:
                self.tempoIinterno = 0.4
                self.getRope(caso: 3)
                break
                
            case 4:
                self.tempoIinterno = 0.2
                self.getRope(caso: 4)
                break
                
            case 5:
                self.tempoIinterno = 0.1
                self.getRope(caso: 5)
                break
                
                
                
            default: print("Errore nella generazione della forza")
                
                
            }
        }
    }
    
    private func getRope(caso: Int){
        
        self.timerInterno = Timer.scheduledTimer(withTimeInterval: self.tempoIinterno, repeats: true){ timerInterno in
            self.hapticFeedback.makeVibration(chooseVibration: 3)
            if caso == 4 || caso == 5 { self.vittoria += 2 }
            
        }
        
        self.observerTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true){ observerTimer in
            
            switch caso {
            case 0, 1 :
                self.manageCases(caso: caso)
                break
            case 2, 3 :
                self.manageCases(caso: caso)
                break
            case 4, 5 :
                self.manageCases(caso: caso)
                break
            default:
                print("Default case")
                break
                
            }
        }
    }
    
    //Funzione che gestisce i casi di scroll
    private func manageCases(caso: Int){
        
        //Se sto lasciando la lenza gestiscodi conseguenza
        if previousScroll < scroll {
            // print("Stai lanciando la lenza")
            
            // In base al caso andiamo ad allontanare la vittoria
            switch caso {
            case 0, 1 :
                print("Caso 0 1 aumento di 2: \(vittoria)")
                self.vittoria += 2
                break
                
            case 2, 3 :
                print("Caso 2 3 aumento di 4: \(vittoria)")
                self.vittoria += 4
                break
                
            case 4, 5 :
                print("Caso 4 5 aumento di 2: \(vittoria)")
                self.vittoria += 6
                break
                
            default:
                print("Default case")
                break
                
            }
            
        //Caso in cui tiriamo la lenza verso di noi
        } else if previousScroll > scroll {
            // print("Stai tirando la lenza")
            
            // In base al caso gestiamo l'avicinamento al punto di vittoria
            switch caso {
            case 0, 1 :
                print("Caso 0 1 diminuisco di 10: \(vittoria)")
                self.vittoria -= 10
                break
                
            case 2, 3 :
                print("Caso 2 3 siminuisco di 4: \(vittoria)")
                self.vittoria -= 4
                break
                
            case 4, 5 :
                print("Caso 4 5 siminuisco di 1: \(vittoria)")
                self.vittoria -= 1
                self.changeFRDurability()
                break
                
            default:
                print("Default case")
                break
                
            }
        }
        
        // Si invia l'attuale valore della vittoria per far aggiornare la barra nella scena spritekit
        viewModel.sendMessage(key: "Vittoria", value: self.vittoria)
        
        previousScroll = scroll
        
        self.checkVittoria()
        
    }
    
    
    func invalidateTimers(){
        self.timerEsterno?.invalidate()
        self.timerInterno?.invalidate()
        self.observerTimer?.invalidate()
        self.fihsingRodDurability = 100
        self.vittoria = 400
        viewModel.sendMessage(key: "frDurability", value: 100)
    }
    
    
    private func checkVittoria(){
        //Caso in cui vinciamo
        if self.vittoria <= 0 {
            condizioneVittoria = 0
            print("Hai vinto!")
            //Si resetta la variabile globale per permettere il lancio
            self.endSimulation()
        //Caso in cui perdiamo
        } else if self.vittoria > 600 {
            condizioneVittoria = 1
            print("Hai perso!")
            //Si resetta la variabile globale per permettere il lancio
            self.endSimulation()
        }
        
    }
    
    private func changeFRDurability(){
        
        self.fihsingRodDurability -= 3
        print("Diminuisco la durabilità della lenza: \(self.fihsingRodDurability)")
        if self.fihsingRodDurability <= 0 {
            condizioneVittoria = 2
            print("Hai Rotto la lenza, esco dalla simulazione")
            //Si resetta la variabile globale per permettere il lancio
            self.endSimulation()
        }
        
        // Viene inviata la attuale durabilità
        viewModel.sendMessage(key: "frDurability", value: self.fihsingRodDurability)
    }
    
    private func endSimulation(){
        canTrow = true
        self.invalidateTimers()
    }
}




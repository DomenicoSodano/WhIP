//
//  ContentView.swift
//  Vibrations Watch App
//
//  Created by Antonio Tridente on 27/02/24.
//

import Foundation
import SwiftUI
import WatchKit
import SpriteKit
import CoreMotion
import AVFoundation


var scroll = 0.0
var previousScroll = 0.0
var canTrow = true

struct Sview: View {
    
    var viewModel: ViewModel
    
    var scene: SKScene{
        let scene = SKScene (fileNamed: "GameScene") as! GameSceneScript
        scene.size = CGSize(width: 140, height: 170)
        scene.scaleMode = .aspectFill
        scene.setViewModel(viewModel: viewModel)
        return scene
    }

    var body: some View {
        SpriteView(scene: scene)
    }
}

struct ContentView: View {
    
    @State private var isVibrating = false
    @State var scrollAmount = 50000.0
    @State var previousScrollAmount = 0.0
    @State var startTime: Date = Date()
    @State var speed: Double = 0.0
    @State private var valore = 1
    @State private var contatore = 1
    
    @State private var levelAngle: Double = 0.0
    @State private var force: Double?
    let minAngle: Double = 0.0
    let maxAngle: Double = 100000
    let maxRotationSpeed: Double = 20.0
    
    private var hapticFeedback: HapticFeedback = HapticFeedback()
    private var fishes: HapticFish = HapticFish()
    
    @State var deltaZ: Double = 0.0
    @State var deltaX: Double = 0.0
    @State private var isThrowing = false
    @State private var currentValue: Double = 0
    @State private var previousAcceleration: CMAcceleration?
    @State private var maxAcceleration: Double = 0.0
    @State private var gyroData: CMGyroData?
    let motionManager = CMMotionManager()
    
    // Dichiarazione dell'istanza AVAudioPlayer
    let audioPlayer: AVAudioPlayer? = {
        guard let url = Bundle.main.url(forResource: "Lenza_lenta", withExtension: "mp3") else { return nil }
        
        let player = try? AVAudioPlayer(contentsOf: url)
        player?.enableRate = true
        player?.volume = 10.0 // Imposta il volume al massimo
        player?.numberOfLoops = -1 // Loop infinito
        return player
        
    }()
    
    @StateObject private var viewModel: ViewModel = ViewModel()

    var body: some View {
        
        let tempScrollAmount = scrollAmount
        
        
        ZStack {
            
            Text("")
                .focusable(true)
                .digitalCrownRotation($scrollAmount, from: minAngle, through: maxAngle, by:rotationSpeed())
                .onChange(of: scrollAmount) { newValue in
                    
                    scrollAmount = newValue
                    scroll = newValue
                    
                    previousScrollAmount = tempScrollAmount
                    previousScroll = tempScrollAmount
                    
                    // Calcolo e visualizzazione della velocità
                    let tempoTrascorso = Date().timeIntervalSince(startTime) // Calcola il tempo trascorso
                    speed = abs(scrollAmount - previousScrollAmount) / tempoTrascorso
                    
                    
                    startTime = Date()
                    
                    if force == nil {
                        force = calculateForce(leverAngle: newValue)
                    }
                    
                    viewModel.sendMessage(key: "vittoria", value: scrollAmount)
                    
                }
                .onAppear(perform:{
                    self.startGyroscopeUpdates()
                    self.startAccelerometerUpdates()
                    self.startCheckingAngle()
                })

            
            //vista spritekit
            Sview(viewModel: viewModel)
            //Vista della leva
            LevaView(angle: $scrollAmount)
            
        }
        .padding()
        
    }
    
    
    private func startAccelerometerUpdates() {
        motionManager.accelerometerUpdateInterval = 0.1
        if motionManager.isAccelerometerAvailable && canTrow {
            motionManager.startAccelerometerUpdates(to: .main) { (data, error) in
                guard let acceleration = data?.acceleration else { return }
                
                self.handleAcceleration(acceleration)

            }
        }
    }
    
    
    private func startGyroscopeUpdates() {
        motionManager.gyroUpdateInterval = 0.1
        if motionManager.isGyroAvailable && canTrow {
            motionManager.startGyroUpdates(to: .main) { (data, error) in
                guard let gyroData = data else { return }
                self.gyroData = gyroData
            }
        }
    }
    
    
    // Aggiorna il metodo handleAcceleration(_:) nel ContentView
    private func handleAcceleration(_ acceleration: CMAcceleration) {
        
        if canTrow {
            
            currentValue = 0
            
            if let previousAcceleration = self.previousAcceleration {
                let deltaX = acceleration.x - previousAcceleration.x
                let deltaY = acceleration.y - previousAcceleration.y
                let deltaZ = acceleration.z - previousAcceleration.z
                let magnitude = sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ)
                
                let maxAcceleration: Double = 2.0 // Massima accelerazione per raggiungere 100
                let speed = min(magnitude / maxAcceleration * 1000, 1000) // Calcolo della velocità
            
                currentValue = speed
                if currentValue > maxAcceleration {
                    self.maxAcceleration = currentValue
                }

                // Se il lancio è permesso e la forza è abbastanza elevata, viene segnalato
                // che il lancio è estato eseguito, andando a disattivare il lock a questo blocco
                // di codice per impedirne le future esecuzioni fin quando la flag non viene
                // resettata durante la fine della simulazione
                if canTrow && currentValue > 800 && deltaY > -0.50{
                    
                    print("Hai eseguito un lancio")
                    canTrow = false
                    currentValue = 0
                    print("Provo ad inviare i segnali di lancio")
                    viewModel.sendMessage(key: "trow", value: 1.0)
                    viewModel.sendMessage(key: "maxAcceleration", value: maxAcceleration)
                    viewModel.maxAcceleration = 0

                }
            }

            self.previousAcceleration = acceleration
        }

    }
    
    // Funzione per avviare il timer per controllare l'angolo della leva
    private func startCheckingAngle() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            let currentAngle = scroll
            let difference = abs(currentAngle - previousScroll)
            // Controllo se la differenza è significativa
            if difference > 0.135 {
                // Calcolo della velocità di riproduzione dell'audio in base a 'currentDifference'
                var rate: Float = 1.0
                if strenghtGlobal == 0 || strenghtGlobal == 1 {
                    rate = 3
                } else if strenghtGlobal == 3 || strenghtGlobal == 4 {
                    rate = 2
                } else if strenghtGlobal > 4 {
                    rate = 1
                }
    
                // Avvio della riproduzione dell'audio solo se non è già in riproduzione
                if let audioPlayer = audioPlayer, !audioPlayer.isPlaying {
                    print("Entro nella simulazione suono")
                    audioPlayer.stop()
                    audioPlayer.rate = rate
                    audioPlayer.play()
                }
            } else {
                // Ferma l'audio se l'angolo non cambia significativamente
                if let audioPlayer = audioPlayer {
                    audioPlayer.stop()
                }
            }
            // Aggiorna l'angolo precedente
            previousScroll = currentAngle
        }
    }
    
    private func calculateForce(leverAngle: Double) -> Double {
        let maxForce: Double = 100.0
        let force = maxForce * (leverAngle / maxAngle)
        return force
    }
    
    private func rotationSpeed() -> Double {
        if let force = force {
            return maxRotationSpeed * (1 - force)
        } else {
            return maxRotationSpeed
        }
    }
}


struct LevaView: View {
    
    @Binding var angle: Double
    @State private var difference = 0.0
    @State private var canPlaysound: Bool = false
    @State private var previousAngle: Double = 0.0
    let pivotPoint = CGPoint(x: 0.30, y: 3)
    
    // Dichiarazione dell'istanza AVAudioPlayer
    let audioPlayer: AVAudioPlayer? = {
        guard let url = Bundle.main.url(forResource: "Lenza_lenta", withExtension: "mp3") else { return nil }
        let player = try? AVAudioPlayer(contentsOf: url)
        player?.enableRate = true
        player?.volume = 10
        player?.numberOfLoops = 0
        return player
    }()
    
    var body: some View {
       
        
        Image("leva")
            .resizable()
            .scaledToFit()
            .offset(x: -pivotPoint.x, y: -pivotPoint.y)
            .rotationEffect(.degrees(angle), anchor: .center)
            .offset(x: pivotPoint.x, y: pivotPoint.y)
            .scaleEffect(1.2)
        
    }
            
}

#Preview {
    ContentView()
}


//
//  HapticFeedback.swift
//  Vibrations Watch App
//
//  Created by Antonio Tridente on 27/02/24.
//

import Foundation
import WatchKit

class HapticFeedback {

    var contatore = 0
    var timer: Timer?

    func doVibration(timeInterval: Double, chooseVibration: Int, nroVibrazioni: Int) {
//        Reset del contatore quando viene avviato un nuovo set di vibrazioni
        contatore = 0

//        Creazione del timer
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { timer in
            
            if self.contatore < nroVibrazioni {
                self.makeVibration(chooseVibration: chooseVibration)
                self.contatore += 1
                
            } else {
//                Blocco del timer quando il numero desiderato di vibrazioni è stato raggiunto
                timer.invalidate()
            }
            
        }
    }

    func makeVibration(chooseVibration: Int) {
        let dispositivo = WKInterfaceDevice.current()

        switch chooseVibration {
            
            case 1: dispositivo.play(.notification)
            case 2: dispositivo.play(.failure)
            case 3: dispositivo.play(.click)
            case 4: dispositivo.play(.directionDown)
            case 5: dispositivo.play(.directionUp)
            case 6: dispositivo.play(.success)
            case 7: dispositivo.play(.start)
            case 8: dispositivo.play(.stop)
            case 9: dispositivo.play(.retry)
                
            default: print("Invalid vibration type")
            
        }
    }

}

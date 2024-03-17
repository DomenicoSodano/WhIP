import Foundation
import WatchKit
import SwiftUI



//This class represents the fish getting near the bait, it has a function wich uses the lower hapitic feedback class
//to make vibretions based on the fish nearness, the time is based on the "tempo" variable sent by the user at runtime
//It has function to invalidat the timer
class HapticFish {
    
    var contatore = 0
    var timer: Timer?
    private var vibrazione: HapticFeedback = HapticFeedback()
    private var randomNumber: Int = 0
    
    func aboccaPesce(nearness: Double, fishStrenght: Int){
            
        timer = Timer.scheduledTimer(withTimeInterval: nearness, repeats: true){ timer in
            print("Eseguo un battito con nearness \(nearness)")
                
            if fishStrenght == 1 {
                    
                self.vibrazione.doVibration(timeInterval: 0.3, chooseVibration: 3, nroVibrazioni: 2)
                    
            }else if fishStrenght == 2 {
                    
                self.vibrazione.doVibration(timeInterval: 0.3, chooseVibration: 3, nroVibrazioni: 2)
                
            }else if fishStrenght == 3 {
                    
                self.vibrazione.doVibration(timeInterval: 0.3, chooseVibration: 3, nroVibrazioni: 2)
                    
            }else if fishStrenght == 4 {
                    
                self.vibrazione.doVibration(timeInterval: 0.3, chooseVibration: 3, nroVibrazioni: 2)
                    
            }else if fishStrenght == 5 {
                
                self.vibrazione.doVibration(timeInterval: 0.3, chooseVibration: 3, nroVibrazioni: 2)
                
            }
        }
    }
    
    func invalidateTimer(){
        self.timer?.invalidate()
    }
}


//This class represents the general Haptic feedback used in different ways trough all the other haptic classes.
//Therefore it's designed to be dynamic and comprehensive
//It also has a timer invalidate function
class HapticFeedback {

    var contatore = 0
    var contatoreLog = 0.0
    var timer: Timer?
    var timeInterval: TimeInterval = 0.1
    var choosedVibration = 0
    var nroVibrazioni = 0

    func doVibration(timeInterval: Double, chooseVibration: Int, nroVibrazioni: Int) {
        // Resetta il contatore quando viene avviato un nuovo set di vibrazioni
        contatore = 0

        // Crea il timer
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { timer in
            if self.contatore < nroVibrazioni {
                self.makeVibration(chooseVibration: chooseVibration)
                self.contatore += 1
            } else {
                // Invalida il timer quando il numero desiderato di vibrazioni è stato raggiunto
                timer.invalidate()
            }
        }
    }
    
    func logaritmicVibration(time: Double, chooseVibration: Int, nroVibrazioni: Int){
        
        self.timeInterval = time
        self.choosedVibration = chooseVibration
        self.nroVibrazioni = nroVibrazioni
        
        self.timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        
    }

    @objc func timerAction() {
        
        self.contatore = 0
        self.contatoreLog = 0.0
        // Esegui la tua funzione qui
        makeVibration(chooseVibration: 3)
            
        // Aumenta il tempo tra le esecuzioni
        self.contatore += 1
        self.contatoreLog += 0.1
        self.timeInterval += Double(contatoreLog) * 0.3
        
        //Il timer si ferma dopo un certo numero di iterazioni
        if self.contatore >= nroVibrazioni {
            self.timer?.invalidate()
            self.timer = nil
        }
            
        // Riavvia il timer con il nuovo intervallo
        timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(timerAction),userInfo: nil, repeats: true)
    }

    

    func makeVibration(chooseVibration: Int) {
        
        let dispositivo = WKInterfaceDevice.current()

        switch chooseVibration {
            
            case 1: dispositivo.play(.directionDown)
            case 2: dispositivo.play(.failure)
            case 3: dispositivo.play(.click)
            case 4: dispositivo.play(.directionDown)
            case 5: dispositivo.play(.directionUp)
            case 6: dispositivo.play(.success)
            case 7: dispositivo.play(.start)
            case 8: dispositivo.play(.stop)

            default: print("Invalid vibration type")
            
        }
        
    }
    
    func invalidateTimer(){
        self.timer?.invalidate()
    }

}

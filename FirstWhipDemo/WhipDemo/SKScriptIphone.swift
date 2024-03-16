
import SpriteKit
import Foundation
import SwiftUI


var autolockLancio = true
var autolockPesca = true
var autolockRotturaLenza = true
var autolockVittoria = true
var autolockPerdita = true
var autolockAtterraggio = true
var autolockPB = true
var contactCount = 0

var fishingProgress = 0.0

class SKScriptIphone: SKScene, SKPhysicsContactDelegate {
    
    var barraOrizzontale = SKSpriteNode()
    var galleggiante = SKSpriteNode()
    var barra = SKSpriteNode()
    var fishingRod = SKSpriteNode()
    var fishingRodAttachPoint = SKSpriteNode()
    
    var fishTrophy = SKSpriteNode()
    
    var backgroundTextures = [SKTexture]()
    var baitTextures = [SKTexture]()
    var backgroundNode: SKSpriteNode!
    
    var backGroundAnimation = SKAction()
    var landingBaitAnimation = SKAction()
    var wigglingBaitAnimation = SKAction()
    var baitBeeingTrown = SKAction()
    var baitGroupAnimation = SKAction()
    var infiniteBaitingAnimation = SKAction()
    var infiniteBaitIdle = SKAction()
    
    var trowingFishingRod = SKAction()
    var pullingFishingRod = SKAction()
    var infiniteIdleAnimation = SKAction()
    
    var oldLine = SKShapeNode()
    
    let velocitaOrizontale = -155.0
    let velocitaVerticale = Double.random(in: 1...100)
    var isMoving = false
    var autolockBG = true
    var showProgressBar = false
    var showRope = false
    var timer: Timer?
    
    var viewModel: ViewModel!
    
    override func didMove(to view: SKView) {
        self.inizialize()

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.animateTrophy(trophy: fishTrophy)
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        //Controllo sui corpi collisi, se sono barra e galleggiante viene inviato il segnale di inizio simulazione
        let sum = (contact.bodyA.node?.physicsBody?.collisionBitMask)! + (contact.bodyB.node?.physicsBody?.collisionBitMask)!
        
        contactCount += 1
        print("Contatore Contatti = \(contactCount)")
        //Se la somma è 3 l'amo è atterrato sull'acqua e viene inviato il segnale
        if sum == UInt32(3) && (viewModel.trow > 0.9 && viewModel.trow < 1.1) && autolockAtterraggio && contactCount >= 2{
           
            print("Invio il segnale di inizio simulazione")
            
            viewModel.sendMessage(key: "InizioSimulazione", value: 1.0)
            viewModel.trow = 0.0
            viewModel.sendMessage(key: "trow", value: 0.0)
            contactCount = 0
            autolockAtterraggio = false
            galleggiante.run(baitGroupAnimation)
            
        } else if contactCount == 1 {
            
            galleggiante.run(infiniteBaitIdle)
            
        }
    
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        //Disegnamo la lenza se ci troviamo nel giusto frame di animazione
        if self.showRope {
            drawLine(x: fishingRodAttachPoint.position.x, y: fishingRodAttachPoint.position.y, galleggiante: galleggiante.position)
        }
        
        if (viewModel.trow >= 0.9 && viewModel.trow <= 1.1) && autolockLancio == true {
            
            autolockLancio = false
            autolockAtterraggio = true
            
            //Vì Viene eseguita l'animazione del lancio quando si riceve il segnale
            print("Animazine lancio")
            self.fishingRod.run(trowingFishingRod)
            
        }
        
        //Controlli per vedere la fine della simulazione ed eseguire l'animazione adatta
        if viewModel.fineSimulazione >= -0.1 && viewModel.fineSimulazione <= 0.1 && autolockVittoria {
            print("Animazione vittoria")
            self.fishingRod.removeAllActions()
            self.animateTrophy(trophy: fishTrophy)
            autolockVittoria = false
            
            
        } else if viewModel.fineSimulazione >= 0.9 && viewModel.fineSimulazione <= 1.1 && autolockPerdita {
            print("Animazione Sconfitta")
            self.resetThings()
            autolockPerdita = false
            
        } else if viewModel.fineSimulazione >= 1.9 && viewModel.fineSimulazione <= 2.1 && autolockRotturaLenza {
            print("Animazione Rottura lenza")
            self.resetThings()
            autolockRotturaLenza = false
        }
        
        if viewModel.pesca >= 0.9 && viewModel.pesca <= 1.1 && autolockPB {
            
            print("Segnale di baiting arrivato")
            autolockPB = false
            self.setPesca()
            // Eseguo una nuova animazione per il galleggiante
            galleggiante.run(infiniteBaitingAnimation)
            fishingRod.run(pullingFishingRod)
            fishingRodAttachPoint.position = CGPoint(x: 207.759, y: 514.982)
        }
        
    }

    private func setPesca(){
        //si inizializzano le variabili per la pesca
        viewModel.pesca = 0.0
        viewModel.sendMessage(key: "Pesca", value: 0.0)
        viewModel.showProgressBar = true
        galleggiante.removeAllActions()
        
    }
    
    private func inizialize(){
        
        physicsWorld.contactDelegate = self
        self.barraOrizzontale = childNode(withName: "BarraOrizzontale") as! SKSpriteNode
        self.galleggiante = childNode(withName: "Galleggiante") as! SKSpriteNode
        self.fishTrophy = childNode(withName: "fishTrophy1") as! SKSpriteNode
        self.fishingRod = childNode(withName: "fishingRod") as! SKSpriteNode
        self.fishingRodAttachPoint = childNode(withName: "FRAttachPoint") as! SKSpriteNode

        barraOrizzontale.alpha = 0
        
        //Carichiamo le texture
        let bg1 = SKTexture(imageNamed: "sfondo0")
        let bg2 = SKTexture(imageNamed: "sfondo1")
        let bg3 = SKTexture(imageNamed: "sfondo2")
        let bg4 = SKTexture(imageNamed: "sfondo3")
        let bg5 = SKTexture(imageNamed: "sfondo4")
        let bg6 = SKTexture(imageNamed: "sfondo5")
        
        let gall1 = SKTexture(imageNamed: "galleggiante1")
        let gall2 = SKTexture(imageNamed: "galleggiante2")
        let gall3 = SKTexture(imageNamed: "galleggiante3")
        let gall4 = SKTexture(imageNamed: "galleggiante4")
        let gall5 = SKTexture(imageNamed: "galleggiante5")
        let gall6 = SKTexture(imageNamed: "galleggiante6")
        
        let fishingRod1 = SKTexture(imageNamed: "cdp1")
        let fishingRod2 = SKTexture(imageNamed: "cdp2")
        let fishingRod3 = SKTexture(imageNamed: "cdp3")
        let fishingRod4 = SKTexture(imageNamed: "cdp4")
        let fishingRod5 = SKTexture(imageNamed: "cdp5")
        let fishingRod6 = SKTexture(imageNamed: "cdp6")
        let fishingRod7 = SKTexture(imageNamed: "cdp7")
        let fishingRod8 = SKTexture(imageNamed: "cdp8")
        let fishingRod9 = SKTexture(imageNamed: "cdp9")
        let fishingRod10 = SKTexture(imageNamed: "cdp10")
        let fishingRod11 = SKTexture(imageNamed: "cpd11")
        
        backgroundTextures = [bg1, bg2, bg3, bg4, bg5, bg6]
        
        //Creiamo le diverse animazioni
        
        // Animazione per il backGround
        backGroundAnimation = SKAction.animate(with: backgroundTextures, timePerFrame: 0.3)
        // animazione per il landing del galleggiante
        landingBaitAnimation = SKAction.animate(with: [gall2, gall3, gall4, gall6, gall5], timePerFrame: 0.2)
        // Animazione di quando il galleggiante sta sull'acqua
        wigglingBaitAnimation = SKAction.animate(with: [gall6, gall4, gall6, gall5], timePerFrame: 0.2)
        // Animazione di quando il galleggiante sta venendo tirato
        baitBeeingTrown = SKAction.animate(with: [gall2, gall3, gall4, gall5], timePerFrame: 0.1)
        
        // Animazione di quando lanciamo la canna da pesca
        // !!! Questa è una azione speciale, viene eseguito del codice come fosse una azione spritekit !!!
        let scriptedAction = SKAction.run {
            self.movimentoAmoAlLancio()
            self.resetBools()
            self.showRope = true
        }
        let trowing = SKAction.animate(with: [fishingRod2, fishingRod3, fishingRod4, fishingRod5, fishingRod6, fishingRod7], timePerFrame: 0.1)
        let trowing2 = SKAction.animate(with: [fishingRod1, fishingRod8, fishingRod9, fishingRod1], timePerFrame: 0.1)
        trowingFishingRod = SKAction.sequence([trowing, scriptedAction, trowing2])
        infiniteIdleAnimation = SKAction.animate(with: [fishingRod1], timePerFrame: 1)
        infiniteIdleAnimation = SKAction.repeatForever(infiniteIdleAnimation)
        
        // Animazione di quando il pesce tira la lenza
        pullingFishingRod = SKAction.animate(with: [fishingRod10, fishingRod11], timePerFrame: 0.3)
        // ... Resa infinita
        pullingFishingRod = SKAction.repeatForever(pullingFishingRod)
        
        // Si crea l'animazione infinita per il galleggiante
        let infiniteWigglingBaitAnimation = SKAction.repeatForever(wigglingBaitAnimation)
        baitGroupAnimation = SKAction.group([landingBaitAnimation, infiniteWigglingBaitAnimation])
        // Si crea l'animazione infinita per il backGround
        let repeatActionBG = SKAction.repeatForever(backGroundAnimation)
        // Creo l'animazione infinita per  quando il pesce ha abboccato
        let baiting = SKAction.animate(with: [gall2, gall3, gall4, gall6, gall5], timePerFrame: 0.1)
        let baitingGroup = SKAction.group([baiting, SKAction.wait(forDuration: 0.8)])
        infiniteBaitingAnimation = SKAction.repeatForever(baiting)
        // Creo la animazione di idle
        infiniteBaitIdle = SKAction.animate(with: [gall1], timePerFrame: 1)
        infiniteBaitIdle = SKAction.repeatForever(infiniteBaitIdle)
        
        //Impostiamo il backGround
        backgroundNode = SKSpriteNode(texture: bg1)
        backgroundNode.position = CGPoint(x: 0, y: size.height / 2)
        backgroundNode.size = CGSize(width: 1634, height: 750)
        backgroundNode.zPosition = -5
        backgroundNode.run(repeatActionBG)
        
        addChild(backgroundNode)
        
    }

    private func resetThings() { 
        
        print("Resetto le cose")
        viewModel.fineSimulazione = -1.0
        viewModel.sendMessage(key: "FineSimulazione", value: -1.0)
        
        //Si invia il segnale di reset al watch dopo un breve ritardo
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false){ _ in
            autolockLancio = true
            self.viewModel.sendMessage(key: "canTrow", value: 1.0)
        }
        
        // reset dell'autolock sulla animazione di bait
        autolockPB = true
        // Si nasconde la progress bar
        showProgressBar = false
        // Si nasconde la'amo da pesca e si pulisce l'ultima lenza disegnata
        self.showRope = false
        oldLine.removeFromParent()
        
        // Si resettano le posizioni e le animazioni
        self.galleggiante.position.x = CGFloat(1120)
        self.galleggiante.position.y = CGFloat(120)
        self.galleggiante.size = CGSize(width: CGFloat(126.237), height: CGFloat(167.883))
        self.galleggiante.removeAllActions()
        
        self.barraOrizzontale.position.x = CGFloat(274.7510070800781)
        self.barraOrizzontale.position.y = CGFloat(-18.364999771118164)
        
        self.fishingRod.removeAllActions()
        self.fishingRodAttachPoint.position = CGPoint(x: 200, y: 586.41)
        self.fishingRod.run(infiniteIdleAnimation)
    }
    
    // Questa funzione anima un trofeo che gli viene mandato in ingresso
    private func animateTrophy(trophy: SKSpriteNode){
        
        self.fishingRod.removeAllActions()
        // Viene dichiarata l'azione che lo fa muovere in alto verso il centro
        let moveUpAction1 = SKAction.moveBy(x: trophy.position.x, y: 470, duration: 1.5)
        // Viene dichiarata l'azione che lo fa muovere verso l'alto dal centro
        let moveUpAction2 = SKAction.moveBy(x: trophy.position.x, y: 800, duration: 1.2)
        

        // Test
        let changeColorAction = SKAction.sequence([
            SKAction.colorize(with: .green, colorBlendFactor: 1.0, duration: 1.5),
            SKAction.wait(forDuration: 0.5),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.1)
        ])
        
        
        trophy.run(changeColorAction)
        // Si esegue 'azione 1
        trophy.run(moveUpAction1)
        
        // Dopo un ritardo l'azione 2
        Timer.scheduledTimer(withTimeInterval: 3.5, repeats: false){ _ in
            trophy.run(moveUpAction2)
        }
        // Dopo un breve lasso di tempo si resetta il trofeo in basso e si resetta la scena
        Timer.scheduledTimer(withTimeInterval: 6, repeats: false){ _ in
            trophy.position = CGPoint(x: 0, y: -110)
            self.resetThings()
        }
        
    }
    
    private func movimentoAmoAlLancio () {
        
        galleggiante.physicsBody?.applyImpulse(CGVector(dx: velocitaOrizontale - Double(Int.random(in: 60...80)), dy: velocitaVerticale + 500))
        
        //Connectivity
        let action = SKAction.scale(by: Double.random(in: 0.5...0.7), duration: 1)
        self.galleggiante.run(action)

        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
            self.barraOrizzontale.position.y = CGFloat(self.logaritmo(base: 1.01236, argomento: self.velocitaVerticale)) - 100
            
        }
        
    }
    
    // Funzione che mi permette di disegnare la lenza
    private func drawLine(x: Double, y: Double, galleggiante: CGPoint){
        
        let yourLine = SKShapeNode()
        let pathToDraw = CGMutablePath()
        
        oldLine.removeFromParent()
        
        pathToDraw.move(to: CGPoint(x: x, y: y))
        pathToDraw.addLine(to: galleggiante)
        yourLine.path = pathToDraw
        print("Vittoria: \(viewModel.vittoria)")
        
        //Si setta il colore del filo sulla base della durabilità
        yourLine.strokeColor = self.colorFromValue(viewModel.frDurability)
        
        addChild(yourLine)
        oldLine = yourLine
        
        
    }
    
    //Questa funzione genera il colore della lenza sulla base della sua durabilità
    func colorFromValue(_ value: CGFloat) -> UIColor {

        // Calcolo la componente rossa del colore
        let rosso = 1.0
         
         // Calcolo la componente verde del colore
         let verde = value / 100
         
         // Calcolo la componente blu del colore
        let blu = value / 100
        
        return UIColor(red: rosso, green: verde, blue: blu, alpha: 1.0)
    }

    private func resetBools(){
        autolockPerdita = true
        autolockVittoria = true
        autolockRotturaLenza = true
    }
    
    private func logaritmo (base: Double, argomento: Double) -> Double { // MANDA A ANTONIO
        return log(argomento) / log(base)
    }
    
    func setViewModel(viewModel: ViewModel){
        
        self.viewModel = viewModel
        
    }

}

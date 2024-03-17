
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
    
    // Nodi di BackEnd
    var barraOrizzontale = SKSpriteNode()
    var galleggiante = SKSpriteNode()
    var barra = SKSpriteNode()
    var fishingRod = SKSpriteNode()
    var fishingRodAttachPoint = SKSpriteNode()
    var progressionBar = SKSpriteNode()
    
    //Nodo del trofeo del pesce pescato
    var fishTrophy1 = SKSpriteNode()
    var fishTrophy2 = SKSpriteNode()
    
    //Nodi e texture di ambiente
    var backgroundTextures = [SKTexture]()
    var baitTextures = [SKTexture]()
    var backgroundNode: SKSpriteNode!
    
    //Animazioni canna da pesca e backGround
    var backGroundAnimation = SKAction()
    var landingBaitAnimation = SKAction()
    var wigglingBaitAnimation = SKAction()
    var baitBeeingTrown = SKAction()
    var baitGroupAnimation = SKAction()
    var infiniteBaitingAnimation = SKAction()
    var infiniteBaitIdle = SKAction()
    
    // Animaizone vittoria del pesce 1
    var infiniteFish1Animation = SKAction()
    var infiniteFish2Animation = SKAction()
    var pullingUPFish1 = SKAction()
    var pullingUPFish2 = SKAction()
    
    // Animazioni di lancio
    var trowingFishingRod = SKAction()
    var pullingFishingRod = SKAction()
    var infiniteIdleAnimation = SKAction()
    
    // Queste azioni ci permettono di far comparire e scomparire elementi dallo schermo
    var fadeIn = SKAction()
    var fadeOut = SKAction()
    
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
        self.animateTrophy(trophy: fishTrophy2, animation: infiniteFish2Animation)
        self.fishingRod.run(pullingUPFish2)
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        //Controllo sui corpi collisi, se sono barra e galleggiante viene inviato il segnale di inizio simulazione
        let sum = (contact.bodyA.node?.physicsBody?.collisionBitMask)! + (contact.bodyB.node?.physicsBody?.collisionBitMask)!
        
        contactCount += 1
        print("Contatore Contatti = \(contactCount)")
        //Se la somma è 3 l'amo è atterrato sull'acqua e viene inviato il segnale
        if sum == UInt32(3) && viewModel.trow == 1 && autolockAtterraggio && contactCount >= 2{
           
            print("Invio il segnale di inizio simulazione")
            
            viewModel.sendMessage(key: "InizioSimulazione", value: 1)
            viewModel.trow = 0
            viewModel.sendMessage(key: "trow", value: 0)
            contactCount = 0
            autolockAtterraggio = false
            galleggiante.run(baitGroupAnimation)
            
        } else if contactCount == 1 {
            
            galleggiante.run(infiniteBaitIdle)
            
        }
    
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        // Disegnamo la lenza se ci troviamo nel giusto frame di animazione
        if self.showRope {
            drawLine(x: fishingRodAttachPoint.position.x, y: fishingRodAttachPoint.position.y, galleggiante: galleggiante.position)
        }
        
        // Viene mostrata la barra di progressione se il pesce sta tirando
        if self.showProgressBar {
            updateProgressionBar()
        }
        
        // Controllo per osservare se sia stato eseguito un lancio
        if viewModel.trow == 1 && autolockLancio == true {
            // Script per eseguire il lancio
            self.trowAnimation()
        }
        
        //Controlli per vedere la fine della simulazione ed eseguire l'animazione adatta
        if viewModel.fineSimulazione == 0 && autolockVittoria {
            // Viene eseguito lo script per la vittoria
            self.victoryAnimation()
            
        } else if viewModel.fineSimulazione == 1 && autolockPerdita {
            // Viene eseguito lo script per la lose
            self.loseAnimation()
            
        } else if viewModel.fineSimulazione == 2 && autolockRotturaLenza {
            // Viene eseguito lo script per la rpttura lenza
            self.brokenRopeAnimation()
        }
        
        // Controllo per osservare se il pesce ha abboccato
        if viewModel.pesca == 1 && autolockPB {
            // Viene eseguito lo script per quando il pesce abbocca
            self.fishBaitedAnimation()
        }
        
    }

    private func setPesca(){
        //si inizializzano le variabili per la pesca
        viewModel.pesca = 0
        viewModel.sendMessage(key: "Pesca", value: 0)
        viewModel.showProgressBar = true
        galleggiante.removeAllActions()
        
    }
    
    private func inizialize(){
        
        physicsWorld.contactDelegate = self
        self.barraOrizzontale = childNode(withName: "BarraOrizzontale") as! SKSpriteNode
        self.galleggiante = childNode(withName: "Galleggiante") as! SKSpriteNode
        self.fishTrophy1 = childNode(withName: "fishTrophy1") as! SKSpriteNode
        self.fishTrophy2 = childNode(withName: "fishTrophy2") as! SKSpriteNode
        self.fishingRod = childNode(withName: "fishingRod") as! SKSpriteNode
        self.progressionBar = childNode(withName: "progressionBar") as! SKSpriteNode
        self.fishingRodAttachPoint = childNode(withName: "FRAttachPoint") as! SKSpriteNode

        barraOrizzontale.alpha = 0
        progressionBar.alpha = 0
        
        //Carichiamo le texture
        
        //Sprite backGround
        let bg1 = SKTexture(imageNamed: "sfondo0")
        let bg2 = SKTexture(imageNamed: "sfondo1")
        let bg3 = SKTexture(imageNamed: "sfondo2")
        let bg4 = SKTexture(imageNamed: "sfondo3")
        let bg5 = SKTexture(imageNamed: "sfondo4")
        let bg6 = SKTexture(imageNamed: "sfondo5")
        
        //Sprite del galleggiante
        let gall1 = SKTexture(imageNamed: "galleggiante1")
        let gall2 = SKTexture(imageNamed: "galleggiante2")
        let gall3 = SKTexture(imageNamed: "galleggiante3")
        let gall4 = SKTexture(imageNamed: "galleggiante4")
        let gall5 = SKTexture(imageNamed: "galleggiante5")
        let gall6 = SKTexture(imageNamed: "galleggiante6")
        
        //Sprite della canna da pesca
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
        
        //Sprite dei trofei dei pesci
        let fish11 = SKTexture(imageNamed: "fish11")
        let fish12 = SKTexture(imageNamed: "fish12")
        let fish21 = SKTexture(imageNamed: "fish21")
        let fish22 = SKTexture(imageNamed: "fish22")
        
        //Sprite di quando si tira su il pesce pescato
        let pescaPesce11 = SKTexture(imageNamed: "pescaPesce11")
        let pescaPesce12 = SKTexture(imageNamed: "pescaPesce12")
        let pescaPesce13 = SKTexture(imageNamed: "pescaPesce13")
        let pescaPesce21 = SKTexture(imageNamed: "pescaPesce21")
        let pescaPesce22 = SKTexture(imageNamed: "pescaPesce22")
        let pescaPesce23 = SKTexture(imageNamed: "pescaPesce23")
        
        backgroundTextures = [bg1, bg2, bg3, bg4, bg5, bg6]
        
        //Creiamo le diverse animazioni
        
        //Queste due azioni modificano l'alpha da 0 ad 1 e viceversa
        fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.5)
        fadeOut = SKAction.fadeAlpha(to: 0, duration: 0.7)
        
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
        var trowing = SKAction.animate(with: [fishingRod2, fishingRod3, fishingRod4, fishingRod5, fishingRod6, fishingRod7], timePerFrame: 0.1)
        let trowing2 = SKAction.animate(with: [fishingRod1, fishingRod8, fishingRod9, fishingRod8, fishingRod1], timePerFrame: 0.1)
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
        infiniteBaitingAnimation = SKAction.repeatForever(baiting)
        // Creo la animazione di idle
        infiniteBaitIdle = SKAction.animate(with: [gall1], timePerFrame: 1)
        infiniteBaitIdle = SKAction.repeatForever(infiniteBaitIdle)
        
        
        // Creo l'animazione di quando il pesce pescato viene mostrato a schermo
        infiniteFish1Animation = SKAction.animate(with: [fish11, fish12], timePerFrame: 0.14)
        infiniteFish2Animation = SKAction.animate(with: [fish21, fish22], timePerFrame: 0.14)
        infiniteFish1Animation = SKAction.repeatForever(infiniteFish1Animation)
        infiniteFish2Animation = SKAction.repeatForever(infiniteFish2Animation)
        
        // Creo l'animazione di quando si tira su il pesce
        let sequence1 = SKAction.animate(with: [pescaPesce11, pescaPesce12, pescaPesce13], timePerFrame: 0.3)
        let sequence2 = SKAction.animate(with: [pescaPesce21, pescaPesce22, pescaPesce23], timePerFrame: 0.3)
        pullingUPFish1 = SKAction.sequence([sequence1, trowing2])
        pullingUPFish2 = SKAction.sequence([sequence2, trowing2])
        
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
        viewModel.fineSimulazione = -1
        viewModel.sendMessage(key: "FineSimulazione", value: -1)
        
        //Si invia il segnale di reset al watch dopo un breve ritardo
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false){ _ in
            autolockLancio = true
            self.viewModel.sendMessage(key: "canTrow", value: 1)
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
    private func animateTrophy(trophy: SKSpriteNode, animation: SKAction){
    
        // Viene dichiarata l'azione che lo fa muovere in alto verso il centro
        let moveUpAction1 = SKAction.moveTo(y: 320, duration: 1.5)
        // Viene dichiarata l'azione che lo fa muovere verso l'alto dal centro
        let moveUpAction2 = SKAction.moveTo(y: 1100, duration: 1.2)
       
        trophy.run(animation)
        // Si esegue 'azione 1
        trophy.run(moveUpAction1)
        
        // Dopo un ritardo l'azione 2
        Timer.scheduledTimer(withTimeInterval: 3.5, repeats: false){ _ in
            trophy.run(moveUpAction2)
        }
        // Dopo un breve lasso di tempo si resetta il trofeo in basso e si resetta la scena
        Timer.scheduledTimer(withTimeInterval: 6, repeats: false){ _ in
            trophy.position = CGPoint(x: 0, y: -520)
            trophy.removeAllActions()
            self.resetThings()
        }
        
    }
    
    // Funzione che gestisce la vittoria
    private func victoryAnimation(){
        print("Animazione vittoria")
        self.fishingRod.removeAllActions()
        self.progressionBar.run(fadeOut)
        self.showFish()
        self.galleggiante.alpha = 0
        self.showRope = false
        self.oldLine.removeFromParent()
        
        autolockVittoria = false
    }
    
    // Funzione che gestisce la sconfitta
    private func loseAnimation(){
        print("Animazione Sconfitta")
        self.progressionBar.run(fadeOut)
        self.resetThings()
        autolockPerdita = false
    }
    
    // Funzione che gestisce la rottura lenza
    private func brokenRopeAnimation(){
        print("Animazione Rottura lenza")
        self.progressionBar.run(fadeOut)
        self.resetThings()
        autolockRotturaLenza = false
    }
    
    // funzione che gestisce lo script per quando il pesce abbocca
    private func fishBaitedAnimation(){
        print("Segnale di baiting arrivato")
        autolockPB = false
        self.showProgressBar = true
        self.setPesca()
        // Eseguo una nuova animazione per il galleggiante
        progressionBar.run(fadeIn)
        galleggiante.run(infiniteBaitingAnimation)
        fishingRod.run(pullingFishingRod)
        fishingRodAttachPoint.position = CGPoint(x: 207.759, y: 514.982)
    }
    
    // Funzione che gestisce il lancio della canna da pesca
    private func trowAnimation(){
        autolockLancio = false
        autolockAtterraggio = true
        //Vì Viene eseguita l'animazione del lancio quando si riceve il segnale
        print("Animazine lancio")
        self.fishingRod.run(trowingFishingRod)
    }
    
    // Funzione che mostra il pesce pescato, sia sulla canna da pesca che come trofeo
    private func showFish(){
        
        var tempoFRAnimation = SKAction()
        let randomFish = Int.random(in: 1...2)
        
        switch randomFish {
            
            case 1:
                self.animateTrophy(trophy: fishTrophy1, animation: infiniteFish1Animation)
                tempoFRAnimation = pullingUPFish1
                break
            case 2:
                self.animateTrophy(trophy: fishTrophy2, animation: infiniteFish2Animation)
                tempoFRAnimation = pullingUPFish2
                break
            default: print("Errore nella generazione del pesce")
            
            
        }
        
        self.fishingRod.run(tempoFRAnimation)
        
        
        
    }
    
    private func movimentoAmoAlLancio () {
        
        self.galleggiante.alpha = 1
        self.galleggiante.physicsBody?.applyImpulse(CGVector(dx: velocitaOrizontale - Double(Int.random(in: 60...80)), dy: velocitaVerticale + 500))
        
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
        yourLine.strokeColor = self.colorFromValue(CGFloat(viewModel.frDurability))
        
        addChild(yourLine)
        oldLine = yourLine
        
        
    }
    
    //Questa funzione genera il colore della lenza sulla base della sua durabilità
    private func colorFromValue(_ value: CGFloat) -> UIColor {
        // Calcolo la componente rossa del colore
        let rosso = 1.0
        // Calcolo la componente verde del colore
        let verde = value / 100
        // Calcolo la componente blu del colore
        let blu = value / 100
        
        return UIColor(red: rosso, green: verde, blue: blu, alpha: 1.0)
    }
    
    // Questa funzione cambia il colore alla barra di progressione
    // sulla base del valore del viewModel
    private func progressionBarColor(_ value: CGFloat) -> UIColor{
        
        // Creiamo le componenti sulla base del viewModel
        let red = value / 600
        let green = 1 - (value / 600)
        
        return UIColor(red: red, green: green, blue: 0.25, alpha: 1)
    }
    
    //Questa funzione modifica la lunghezza ed il colore della barra di progressione
    private func updateProgressionBar() {
        //Viene reso dinamico il size della barra
        self.progressionBar.size.width = CGFloat(950 - (( 950 * viewModel.vittoria) / 600))
        // Viene cambiato il colore sulla base della vittoria
        self.progressionBar.color = self.progressionBarColor(CGFloat(viewModel.vittoria))
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

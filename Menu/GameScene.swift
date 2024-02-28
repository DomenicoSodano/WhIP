import SpriteKit
import AVFoundation

// Definisci una variabile globale per tracciare lo stato dell'audio
var audioIsEnabled = true

class GameScene: SKScene {
    
    var backgroundMusic: AVAudioPlayer?
    var gameVolume: Float = 0.05
    var playSound: AVAudioPlayer?
    var optionSound: AVAudioPlayer?
    var optionsScene: OptionsScene?
    var processedTouches = Set<UITouch>()
    
    func touchIdentifier(for touch: UITouch) -> String {
        return "\(Unmanaged.passUnretained(touch).toOpaque())"
    }
    
    override func didMove(to view: SKView) {
        self.size = CGSize(width: 1920, height: 1080)
        self.scaleMode = .aspectFill
        setupUI()
        
        // Carica il file audio di sottofondo
        if audioIsEnabled, let url = Bundle.main.url(forResource: "mare", withExtension: "wav") {
            do {
                backgroundMusic = try AVAudioPlayer(contentsOf: url)
                backgroundMusic?.numberOfLoops = -1
                backgroundMusic?.volume = gameVolume
                backgroundMusic?.play()
            } catch {
                print("Error loading background music:", error)
            }
        }
        
        // Carica il suono del pulsante play
        if let url = Bundle.main.url(forResource: "Button", withExtension: "mp3") {
            do {
                playSound = try AVAudioPlayer(contentsOf: url)
                playSound?.volume = 1
            } catch {
                print("Error loading play button sound:", error)
            }
        }
        
        // Carica il suono del pulsante opzioni
        if let url = Bundle.main.url(forResource: "Button", withExtension: "mp3") {
            do {
                optionSound = try AVAudioPlayer(contentsOf: url)
                optionSound?.volume = 1
            } catch {
                print("Error loading options button sound:", error)
            }
        }
    }
    
    // Funzione per impostare il volume dei suoni
    func setVolume(newVolume: Float) {
        gameVolume = newVolume
        backgroundMusic?.volume = newVolume
        playSound?.volume = newVolume
        optionSound?.volume = newVolume
    }
    
    func setupUI() {
        // Add background
        let backgroundNode = SKSpriteNode(imageNamed: "b-1")
        backgroundNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        backgroundNode.size = size
        backgroundNode.zPosition = -1
        addChild(backgroundNode)
        
        // Setup logo animation
        var logoTextures: [SKTexture] = []
        var backgroundTextures: [SKTexture] = []
        for i in 0...3 {
            let logoTextureName = "pixil-frame-\(i)"
            let logoTexture = SKTexture(imageNamed: logoTextureName)
            logoTextures.append(logoTexture)
            let backgroundTextureName = "b-\(i + 1)"
            let backgroundTexture = SKTexture(imageNamed: backgroundTextureName)
            backgroundTextures.append(backgroundTexture)
        }
        
        // Setup background animation
        if !backgroundTextures.isEmpty {
            let animateBackgroundAction = SKAction.animate(with: backgroundTextures, timePerFrame: 0.20)
            backgroundNode.run(SKAction.repeatForever(animateBackgroundAction))
        }
        
        // Add settings button
        let settingsButton = SKSpriteNode(imageNamed: "option01")
        settingsButton.position = CGPoint(x: size.width / 2, y: size.height * 0.2)
        settingsButton.size = CGSize(width: 250, height: 120)
        settingsButton.zPosition = 2
        let xOffset = size.width - settingsButton.size.width / 2 - 800
        let yOffset = size.height - settingsButton.size.height / 2 - 700
        settingsButton.position = CGPoint(x: xOffset, y: yOffset)
        settingsButton.name = "SettingsButton"
        addChild(settingsButton)
        
        // Add play button
        let playButton = SKSpriteNode(imageNamed: "play01")
        playButton.position = CGPoint(x: size.width / 2, y: size.height * 0.4)
        playButton.size = CGSize(width: 250, height: 120)
        playButton.zPosition = 2
        let xOffsetP = size.width - settingsButton.size.width / 2 - 800
        let yOffsetP = size.height - settingsButton.size.height / 2 - 570
        playButton.position = CGPoint(x: xOffsetP, y: yOffsetP)
        playButton.name = "playButton"
        addChild(playButton)
        
        // Setup logo animation
        if !logoTextures.isEmpty {
            let logoNode = SKSpriteNode(texture: logoTextures.first)
            logoNode.position = CGPoint(x: size.width / 1.9, y: size.height * 0.65)
            logoNode.zPosition = 1
            logoNode.size = CGSize(width: 500, height: 500)
            addChild(logoNode)
            let animateLogoAction = SKAction.animate(with: logoTextures, timePerFrame: 0.20)
            logoNode.run(SKAction.repeatForever(animateLogoAction))
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)
            
            // Check if touch has already been processed
            guard !processedTouches.contains(touch) else { continue }
            
            if touchedNode.name == "SettingsButton" {
                if let settingsButton = touchedNode as? SKSpriteNode {
                    settingsButton.alpha = 0.5 // Riduci l'opacità quando toccato
                    optionSound?.play()
                    print("Options tapped")
                    
                    optionsScene = OptionsScene(size: self.size, backgroundTexture: nil, previousScene: self)
                    optionsScene?.scaleMode = .aspectFill
                    optionsScene?.backgroundMusic = backgroundMusic
                    if let optionsView = optionsScene?.view {
                        view?.addSubview(optionsView)
                    }
                }
            } else if touchedNode.name == "playButton" {
                if let playButton = touchedNode as? SKSpriteNode {
                    playButton.alpha = 0.5 // Riduci l'opacità quando toccato
                    playSound?.play()
                    print("Play tapped")
                }
            }
            
            processedTouches.insert(touch)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)
            
            if touchedNode.name == "playButton" {
                if let playButton = touchedNode as? SKSpriteNode {
                    playButton.alpha = 1.0 // Ripristina l'opacità quando il tocco termina
                    playSound?.play()
                    print("Play tapped")
                }
            } else if touchedNode.name == "SettingsButton" {
                if let settingsButton = touchedNode as? SKSpriteNode {
                    settingsButton.alpha = 1 // Ripristina l'opacità quando il tocco termina
                    optionSound?.play()
                    print("Options tapped")
                    
                    if optionsScene == nil {
                        optionsScene = OptionsScene(size: self.size)
                        optionsScene?.scaleMode = .aspectFill
                    }
                    if let optionsScene = optionsScene {
                        self.view?.presentScene(optionsScene)
                    }
                }
            }
            
            if touchedNode.name == "backarrow" {
                if let buttonSoundURL = Bundle.main.url(forResource: "Button", withExtension: "mp3") {
                    do {
                        let buttonSound = try AVAudioPlayer(contentsOf: buttonSoundURL)
                        buttonSound.volume = gameVolume
                        buttonSound.play()
                        print("Backarrow tapped")
                    } catch {
                        print("Error playing backarrow button sound:", error)
                    }
                } else {
                    print("Unable to find backarrow button audio file")
                }
            }
        }
    }
}

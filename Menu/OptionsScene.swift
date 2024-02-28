import SpriteKit
import AVFoundation

protocol AudioControllable: AnyObject {
    func toggleAudio()
}

class OptionsScene: SKScene {
    
    var backgroundTexture: SKTexture?
    var backgroundMusic: AVAudioPlayer?
    var buttonSound: AVAudioPlayer?
    var previousScene: SKScene?
    
    convenience init(size: CGSize, backgroundTexture: SKTexture?, previousScene: SKScene?) {
        self.init(size: size)
        self.backgroundTexture = backgroundTexture
        self.previousScene = previousScene
    }

    override func didMove(to view: SKView) {
        if let backgroundTexture = backgroundTexture {
            let backgroundNode = SKSpriteNode(texture: backgroundTexture)
            backgroundNode.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
            addChild(backgroundNode)
        } else {
            setupDefaultBackground()
        }

        let titleLabel = SKLabelNode(text: "Options")
        titleLabel.fontName = "VT323-Regular"
        titleLabel.fontSize = 64
        titleLabel.fontColor = .black
        titleLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height - 150)
        addChild(titleLabel)

        let audioButton = SKSpriteNode(imageNamed: "audio")
        audioButton.position = CGPoint(x: 1000, y: self.size.height - 500)
        audioButton.name = "AudioButton"
        audioButton.setScale(1.5)
        addChild(audioButton)

        let backButton = SKSpriteNode(imageNamed: "BackArrow")
        backButton.position = CGPoint(x: 150, y: self.size.height - 180)
        backButton.name = "BackButton"
        backButton.setScale(1.5)
        addChild(backButton)

        if let buttonSoundURL = Bundle.main.url(forResource: "Button", withExtension: "mp3") {
            do {
                buttonSound = try AVAudioPlayer(contentsOf: buttonSoundURL)
                buttonSound?.volume = 1.0
            } catch {
                print("Error loading button sound:", error)
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)

            if touchedNode.name == "AudioButton" {
                toggleAudio()
            } else if touchedNode.name == "BackButton" {
                toggleBackButton()
            }
        }
    }

    func toggleAudio() {
        audioIsEnabled.toggle()

        if let audioButton = childNode(withName: "AudioButton") as? SKSpriteNode {
            if audioIsEnabled {
                audioButton.texture = SKTexture(imageNamed: "audio")
                backgroundMusic?.play()
                print("Audio enabled")
            } else {
                audioButton.texture = SKTexture(imageNamed: "offaudio")
                backgroundMusic?.stop()
                print("Audio muted")
            }
        }

        buttonSound?.play()
    }

    
    func toggleBackButton() {
        if let previousScene = previousScene {
            view?.presentScene(previousScene)
        }

        buttonSound?.play()
    }

    func setupDefaultBackground() {
        var backgroundTextures: [SKTexture] = []
        for i in 1...4 {
            let backgroundTextureName = "b-\(i)"
            let backgroundTexture = SKTexture(imageNamed: backgroundTextureName)
            backgroundTextures.append(backgroundTexture)
        }

        if !backgroundTextures.isEmpty {
            let backgroundNode = SKSpriteNode(texture: backgroundTextures.first)
            backgroundNode.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
            backgroundNode.zPosition = -1
            backgroundNode.size = self.size
            addChild(backgroundNode)

            let animateBackgroundAction = SKAction.animate(with: backgroundTextures, timePerFrame: 0.20)
            backgroundNode.run(SKAction.repeatForever(animateBackgroundAction))
        }
    }
}

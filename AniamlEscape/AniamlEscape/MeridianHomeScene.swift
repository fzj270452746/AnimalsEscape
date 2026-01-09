//
//  MeridianHomeScene.swift
//  AniamlEscape
//
//  Mahjong Tap Rush - Home Scene with Grid View Layout
//

import SpriteKit

// MARK: - Navigation Protocol
protocol MeridianNavigationDelegate: AnyObject {
    func navigateToLudicArena(modality: LudicModality)
    func presentAchievementManifest()
}

// MARK: - Home Scene
class MeridianHomeScene: SKScene {

    // MARK: - Delegate
    weak var navigationDelegate: MeridianNavigationDelegate?

    // MARK: - Visual Components
    private var celestialBackdrop: SKNode!
    private var emblemContainer: SKNode!
    private var titleInscription: SKLabelNode!
    private var subtitleInscription: SKLabelNode!
    private var gridViewContainer: SKNode!
    private var decorativeElements: [SKNode] = []

    // MARK: - Layout Properties
    private var safeAreaInsets: UIEdgeInsets = .zero

    // MARK: - Lifecycle
    override func didMove(to view: SKView) {
        super.didMove(to: view)

        if let windowScene = view.window?.windowScene {
            safeAreaInsets = windowScene.windows.first?.safeAreaInsets ?? .zero
        }

        establishCelestialBackdrop()
        fabricateEmblemDisplay()
        constructGridViewInterface()
        initiateEntranceAnimation()
    }

    // MARK: - Background Setup
    private func establishCelestialBackdrop() {
        celestialBackdrop = SKNode()
        addChild(celestialBackdrop)

        // Gradient background using multiple layers
        let gradientColors: [UIColor] = [
            CelestialNexus.ChromaticPalette.midnightBlue,
            CelestialNexus.ChromaticPalette.jadeTint.withAlphaComponent(0.8),
            CelestialNexus.ChromaticPalette.verdantPrimary
        ]

        for (index, color) in gradientColors.enumerated() {
            let layerHeight = size.height / CGFloat(gradientColors.count)
            let yPosition = size.height - layerHeight * CGFloat(index) - layerHeight / 2

            let layerNode = SKShapeNode(rect: CGRect(x: 0, y: yPosition - layerHeight/2,
                                                     width: size.width, height: layerHeight + 10))
            layerNode.fillColor = color
            layerNode.strokeColor = .clear
            layerNode.zPosition = CelestialNexus.ZPositionHierarchy.backdrop
            celestialBackdrop.addChild(layerNode)
        }

        // Decorative patterns - Mahjong tile pattern
        createMahjongTilePattern()

        // Floating decorative elements
        createFloatingDecorations()
    }

    private func createMahjongTilePattern() {
        let patternContainer = SKNode()
        patternContainer.zPosition = CelestialNexus.ZPositionHierarchy.backdrop + 0.5
        patternContainer.alpha = 0.1

        let tileSize: CGFloat = 40
        let rows = Int(size.height / tileSize) + 1
        let cols = Int(size.width / tileSize) + 1

        for row in stride(from: 0, to: rows, by: 3) {
            for col in stride(from: 0, to: cols, by: 3) {
                let tilePath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: tileSize - 5, height: tileSize - 5),
                                           cornerRadius: 4)
                let tileNode = SKShapeNode(path: tilePath.cgPath)
                tileNode.fillColor = CelestialNexus.ChromaticPalette.lunarWhite
                tileNode.strokeColor = .clear
                tileNode.position = CGPoint(x: CGFloat(col) * tileSize, y: CGFloat(row) * tileSize)
                patternContainer.addChild(tileNode)
            }
        }

        celestialBackdrop.addChild(patternContainer)
    }

    private func createFloatingDecorations() {
        // Floating animal silhouettes
        let animalNames = ["dongwu-1", "dongwu-3", "dongwu-5", "dongwu-7"]

        for (index, animalName) in animalNames.enumerated() {
            let floatingAnimal = SKSpriteNode(imageNamed: animalName)
            floatingAnimal.size = CGSize(width: 35, height: 35)
            floatingAnimal.alpha = 0.15
            floatingAnimal.position = CGPoint(
                x: CGFloat.random(in: 30...(size.width - 30)),
                y: size.height * 0.3 + CGFloat(index) * 80
            )
            floatingAnimal.zPosition = CelestialNexus.ZPositionHierarchy.backdrop + 1

            // Floating animation
            let floatUp = SKAction.moveBy(x: 0, y: 15, duration: 2.0 + Double(index) * 0.3)
            let floatDown = SKAction.moveBy(x: 0, y: -15, duration: 2.0 + Double(index) * 0.3)
            floatUp.timingMode = .easeInEaseOut
            floatDown.timingMode = .easeInEaseOut
            let floatSequence = SKAction.sequence([floatUp, floatDown])
            floatingAnimal.run(SKAction.repeatForever(floatSequence))

            celestialBackdrop.addChild(floatingAnimal)
            decorativeElements.append(floatingAnimal)
        }
    }

    // MARK: - Emblem Display
    private func fabricateEmblemDisplay() {
        emblemContainer = SKNode()
        emblemContainer.position = CGPoint(x: size.width / 2, y: size.height - safeAreaInsets.top - 150)
        emblemContainer.zPosition = CelestialNexus.ZPositionHierarchy.interface
        addChild(emblemContainer)

        // Tiger mascot with glow effect
        let glowNode = SKShapeNode(circleOfRadius: 55)
        glowNode.fillColor = CelestialNexus.ChromaticPalette.celestialGold.withAlphaComponent(0.3)
        glowNode.strokeColor = .clear
        glowNode.position = CGPoint(x: 0, y: 30)
        glowNode.zPosition = 0

        let pulseUp = SKAction.scale(to: 1.15, duration: 1.5)
        let pulseDown = SKAction.scale(to: 1.0, duration: 1.5)
        pulseUp.timingMode = .easeInEaseOut
        pulseDown.timingMode = .easeInEaseOut
        glowNode.run(SKAction.repeatForever(SKAction.sequence([pulseUp, pulseDown])))
        emblemContainer.addChild(glowNode)

        // Tiger sprite
        let tigerSprite = SKSpriteNode(imageNamed: CelestialNexus.TaxonomicIdentifiers.protagonistEntity)
        tigerSprite.size = CGSize(width: 80, height: 80)
        tigerSprite.position = CGPoint(x: 0, y: 30)
        tigerSprite.zPosition = 1
        emblemContainer.addChild(tigerSprite)

        // Title
        titleInscription = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        titleInscription.text = "Animals Escape"
        titleInscription.fontSize = 32
        titleInscription.fontColor = CelestialNexus.ChromaticPalette.celestialGold
        titleInscription.position = CGPoint(x: 0, y: -50)
        titleInscription.zPosition = 2

        // Title shadow
        let titleShadow = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        titleShadow.text = "Animals Escape"
        titleShadow.fontSize = 32
        titleShadow.fontColor = UIColor.black.withAlphaComponent(0.4)
        titleShadow.position = CGPoint(x: 2, y: -52)
        titleShadow.zPosition = 1.5
        emblemContainer.addChild(titleShadow)
        emblemContainer.addChild(titleInscription)

        // Subtitle
        subtitleInscription = SKLabelNode(fontNamed: "AvenirNext-Medium")
        subtitleInscription.text = "Escape the Stampede!"
        subtitleInscription.fontSize = 16
        subtitleInscription.fontColor = CelestialNexus.ChromaticPalette.lunarWhite.withAlphaComponent(0.9)
        subtitleInscription.position = CGPoint(x: 0, y: -80)
        subtitleInscription.zPosition = 2
        emblemContainer.addChild(subtitleInscription)
    }

    // MARK: - Grid View Interface
    private func constructGridViewInterface() {
        gridViewContainer = SKNode()
        gridViewContainer.position = CGPoint(x: size.width / 2, y: size.height / 2 - 30)
        gridViewContainer.zPosition = CelestialNexus.ZPositionHierarchy.interface
        addChild(gridViewContainer)

        let buttonWidth = min(size.width - 60, 280)
        let buttonHeight: CGFloat = 65
        let buttonSpacing: CGFloat = 15
        let smallButtonHeight: CGFloat = 50

        // Grid items configuration
        let gridItems: [(title: String, icon: String?, color: UIColor, action: () -> Void)] = [
            ("Normal Mode", "tiger", CelestialNexus.ChromaticPalette.verdantPrimary, { [weak self] in
                self?.navigationDelegate?.navigateToLudicArena(modality: .standardProgression)
            }),
            ("Random Mode", "dongwu-1", CelestialNexus.ChromaticPalette.phoenixOrange, { [weak self] in
                self?.navigationDelegate?.navigateToLudicArena(modality: .stochasticChaos)
            }),
            ("Leaderboard", nil, CelestialNexus.ChromaticPalette.celestialGold, { [weak self] in
                self?.navigationDelegate?.presentAchievementManifest()
            }),
            ("How to Play", nil, CelestialNexus.ChromaticPalette.jadeTint, { [weak self] in
                self?.displayInstructionManifest()
            })
        ]

        // Create vertical stack - all buttons full width
        let smallButtonWidth = (buttonWidth - buttonSpacing) / 2

        for (index, item) in gridItems.enumerated() {
            var currentButtonWidth: CGFloat
            var currentButtonHeight: CGFloat
            var xPosition: CGFloat = 0
            var yPosition: CGFloat = 0

            if index < 2 {
                // Main mode buttons - full width
                currentButtonWidth = buttonWidth
                currentButtonHeight = buttonHeight
                yPosition = CGFloat(1 - index) * (buttonHeight + buttonSpacing)
            } else {
                // Bottom row - two smaller buttons side by side
                currentButtonWidth = smallButtonWidth
                currentButtonHeight = smallButtonHeight
                let col = index - 2
                xPosition = col == 0 ? -smallButtonWidth/2 - buttonSpacing/4 : smallButtonWidth/2 + buttonSpacing/4
                yPosition = -(buttonHeight + buttonSpacing) - smallButtonHeight/2 - buttonSpacing
            }

            let button = LuminousVesselButton(
                dimensionalExtent: CGSize(width: currentButtonWidth, height: currentButtonHeight),
                inscriptionText: item.title,
                chromaticHue: item.color,
                iconDesignation: item.icon
            )
            button.position = CGPoint(x: xPosition, y: yPosition)
            button.configureActivationHandler(item.action)
            button.name = "gridButton_\(index)"
            gridViewContainer.addChild(button)
        }

        // Best scores display
        createScoreDisplay(yOffset: -(buttonHeight + buttonSpacing) - smallButtonHeight - buttonSpacing * 2 - 50)
    }

    private func createScoreDisplay(yOffset: CGFloat) {
        let scoreContainer = SKNode()
        scoreContainer.position = CGPoint(x: 0, y: yOffset)

        // Background panel
        let panelWidth = min(size.width - 60, 280)
        let panelPath = UIBezierPath(roundedRect: CGRect(x: -panelWidth/2, y: -40, width: panelWidth, height: 80),
                                     cornerRadius: 15)
        let panel = SKShapeNode(path: panelPath.cgPath)
        panel.fillColor = UIColor.black.withAlphaComponent(0.2)
        panel.strokeColor = CelestialNexus.ChromaticPalette.celestialGold.withAlphaComponent(0.5)
        panel.lineWidth = 2
        panel.zPosition = 0
        scoreContainer.addChild(panel)

        // Best scores
        let normalBest = UserDefaults.standard.integer(forKey: CelestialNexus.PersistenceNomenclature.apexNormalScore)
        let randomBest = UserDefaults.standard.integer(forKey: CelestialNexus.PersistenceNomenclature.apexRandomScore)

        let normalLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        normalLabel.text = "Normal Best: \(normalBest)"
        normalLabel.fontSize = 14
        normalLabel.fontColor = CelestialNexus.ChromaticPalette.lunarWhite
        normalLabel.position = CGPoint(x: 0, y: 10)
        normalLabel.zPosition = 1
        scoreContainer.addChild(normalLabel)

        let randomLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        randomLabel.text = "Random Best: \(randomBest)"
        randomLabel.fontSize = 14
        randomLabel.fontColor = CelestialNexus.ChromaticPalette.lunarWhite
        randomLabel.position = CGPoint(x: 0, y: -15)
        randomLabel.zPosition = 1
        scoreContainer.addChild(randomLabel)

        gridViewContainer.addChild(scoreContainer)
    }

    // MARK: - Instructions Display
    private func displayInstructionManifest() {
        let instructionDialog = EtherealDialogOverlay(parentDimensions: size)
        instructionDialog.position = CGPoint(x: size.width / 2, y: size.height / 2)

        instructionDialog.manifestDialog(
            headerText: "How to Play",
            contentText: "Tap lanes to move the tiger.\nAvoid falling animals.\nScore +10 for each dodge!",
            actionButtons: [
                (title: "Got it!", color: CelestialNexus.ChromaticPalette.verdantPrimary, handler: { [weak instructionDialog] in
                    instructionDialog?.dissolveDialog()
                })
            ]
        )

        addChild(instructionDialog)
    }

    // MARK: - Entrance Animation
    private func initiateEntranceAnimation() {
        emblemContainer.alpha = 0
        emblemContainer.position.y += 30
        gridViewContainer.alpha = 0
        gridViewContainer.position.y -= 30

        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        let moveDown = SKAction.moveBy(x: 0, y: -30, duration: 0.5)
        let moveUp = SKAction.moveBy(x: 0, y: 30, duration: 0.5)
        moveDown.timingMode = .easeOut
        moveUp.timingMode = .easeOut

        emblemContainer.run(SKAction.group([fadeIn, moveDown]))
        gridViewContainer.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.15),
            SKAction.group([fadeIn, moveUp])
        ]))
    }

    // MARK: - Scene Update
    override func update(_ currentTime: TimeInterval) {
        // Background animation updates if needed
    }
}

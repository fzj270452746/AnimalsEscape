//
//  EtherealDialog.swift
//  AniamlEscape
//
//  Custom Mahjong-styled dialog component
//

import SpriteKit

// MARK: - Ethereal Dialog Component
class EtherealDialogOverlay: SKNode {

    // MARK: - Visual Components
    private var obscurationLayer: SKShapeNode!
    private var dialogueVessel: SKShapeNode!
    private var headerInscription: SKLabelNode!
    private var actionButtonContainer: SKNode!

    private var dismissalHandler: (() -> Void)?
    private let parentDimensions: CGSize

    // MARK: - Initialization
    init(parentDimensions: CGSize) {
        self.parentDimensions = parentDimensions
        super.init()
        self.zPosition = CelestialNexus.ZPositionHierarchy.overlay
        self.isUserInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Dialog Presentation
    func manifestDialog(headerText: String,
                       contentText: String,
                       actionButtons: [(title: String, color: UIColor, handler: () -> Void)],
                       dismissalHandler: (() -> Void)? = nil) {

        self.dismissalHandler = dismissalHandler
        removeAllChildren()

        // Obscuration background
        obscurationLayer = SKShapeNode(rect: CGRect(x: -parentDimensions.width,
                                                    y: -parentDimensions.height,
                                                    width: parentDimensions.width * 2,
                                                    height: parentDimensions.height * 2))
        obscurationLayer.fillColor = CelestialNexus.ChromaticPalette.shadowOverlay
        obscurationLayer.strokeColor = .clear
        obscurationLayer.zPosition = 0
        addChild(obscurationLayer)

        // Calculate dialog dimensions
        let dialogWidth = min(parentDimensions.width * 0.85, 320)
        let dialogHeight: CGFloat = 280

        // Main dialog vessel - Mahjong tile style
        let vesselPath = UIBezierPath(roundedRect: CGRect(x: -dialogWidth/2,
                                                          y: -dialogHeight/2,
                                                          width: dialogWidth,
                                                          height: dialogHeight),
                                      cornerRadius: 20)
        dialogueVessel = SKShapeNode(path: vesselPath.cgPath)
        dialogueVessel.fillColor = CelestialNexus.ChromaticPalette.ivoryBackground
        dialogueVessel.strokeColor = CelestialNexus.ChromaticPalette.celestialGold
        dialogueVessel.lineWidth = 4
        dialogueVessel.zPosition = 1
        addChild(dialogueVessel)

        // Decorative border inner
        let innerBorderPath = UIBezierPath(roundedRect: CGRect(x: -dialogWidth/2 + 8,
                                                               y: -dialogHeight/2 + 8,
                                                               width: dialogWidth - 16,
                                                               height: dialogHeight - 16),
                                           cornerRadius: 16)
        let innerBorder = SKShapeNode(path: innerBorderPath.cgPath)
        innerBorder.fillColor = .clear
        innerBorder.strokeColor = CelestialNexus.ChromaticPalette.dragonRed.withAlphaComponent(0.3)
        innerBorder.lineWidth = 2
        innerBorder.zPosition = 2
        addChild(innerBorder)

        // Header decoration bar
        let headerBarPath = UIBezierPath(roundedRect: CGRect(x: -dialogWidth/2 + 20,
                                                             y: dialogHeight/2 - 70,
                                                             width: dialogWidth - 40,
                                                             height: 50),
                                         cornerRadius: 10)
        let headerBar = SKShapeNode(path: headerBarPath.cgPath)
        headerBar.fillColor = CelestialNexus.ChromaticPalette.jadeTint
        headerBar.strokeColor = CelestialNexus.ChromaticPalette.bambooGreen
        headerBar.lineWidth = 2
        headerBar.zPosition = 3
        addChild(headerBar)

        // Header text
        headerInscription = SKLabelNode(fontNamed: "AvenirNext-Bold")
        headerInscription.text = headerText
        headerInscription.fontSize = 22
        headerInscription.fontColor = .white
        headerInscription.position = CGPoint(x: 0, y: dialogHeight/2 - 52)
        headerInscription.zPosition = 4
        addChild(headerInscription)

        // Content text - create multiple labels for each line
        let contentLines = contentText.components(separatedBy: "\n")
        let lineHeight: CGFloat = 24
        let startY = dialogHeight/2 - 100 - lineHeight * CGFloat(contentLines.count - 1) / 2

        for (index, line) in contentLines.enumerated() {
            let lineLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
            lineLabel.text = line
            lineLabel.fontSize = 16
            lineLabel.fontColor = CelestialNexus.ChromaticPalette.obsidianText
            lineLabel.position = CGPoint(x: 0, y: startY - CGFloat(index) * lineHeight)
            lineLabel.horizontalAlignmentMode = .center
            lineLabel.verticalAlignmentMode = .center
            lineLabel.zPosition = 4
            addChild(lineLabel)
        }

        // Action buttons
        actionButtonContainer = SKNode()
        actionButtonContainer.position = CGPoint(x: 0, y: -dialogHeight/2 + 70)
        actionButtonContainer.zPosition = 5
        addChild(actionButtonContainer)

        let buttonWidth = (dialogWidth - 60) / CGFloat(actionButtons.count)
        let buttonHeight: CGFloat = 50

        for (index, buttonConfig) in actionButtons.enumerated() {
            let xOffset = CGFloat(index) * (buttonWidth + 10) - CGFloat(actionButtons.count - 1) * (buttonWidth + 10) / 2

            let button = LuminousVesselButton(
                dimensionalExtent: CGSize(width: buttonWidth, height: buttonHeight),
                inscriptionText: buttonConfig.title,
                chromaticHue: buttonConfig.color
            )
            button.position = CGPoint(x: xOffset, y: 0)
            button.configureActivationHandler(buttonConfig.handler)
            actionButtonContainer.addChild(button)
        }

        // Entrance animation
        dialogueVessel.setScale(0.5)
        dialogueVessel.alpha = 0

        let fadeIn = SKAction.fadeIn(withDuration: 0.2)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.25)
        scaleUp.timingMode = .easeOut

        obscurationLayer.alpha = 0
        obscurationLayer.run(fadeIn)

        let groupAction = SKAction.group([fadeIn, scaleUp])
        dialogueVessel.run(groupAction)
        innerBorder.run(groupAction)
        headerBar.run(groupAction)
        headerInscription.run(fadeIn)
        actionButtonContainer.run(fadeIn)
    }

    // MARK: - Dialog Dismissal
    func dissolveDialog(completion: (() -> Void)? = nil) {
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let scaleDown = SKAction.scale(to: 0.8, duration: 0.2)

        run(SKAction.group([fadeOut, scaleDown])) { [weak self] in
            self?.removeFromParent()
            completion?()
            self?.dismissalHandler?()
        }
    }

    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Prevent touches from passing through
    }
}

// MARK: - Game Over Dialog
class TerminationDialogOverlay: EtherealDialogOverlay {

    func manifestGameOverDialog(finalScore: Int,
                               apexScore: Int,
                               isNewRecord: Bool,
                               retryHandler: @escaping () -> Void,
                               exitHandler: @escaping () -> Void) {

        let headerText = isNewRecord ? "🎉 New Record!" : "Game Over"
        let contentText = "Score: \(finalScore)\nBest: \(apexScore)"

        manifestDialog(
            headerText: headerText,
            contentText: contentText,
            actionButtons: [
                (title: "Retry", color: CelestialNexus.ChromaticPalette.verdantPrimary, handler: retryHandler),
                (title: "Exit", color: CelestialNexus.ChromaticPalette.dragonRed, handler: exitHandler)
            ]
        )
    }
}

// MARK: - Pause Dialog
class SuspensionDialogOverlay: EtherealDialogOverlay {

    func manifestPauseDialog(currentScore: Int,
                            resumeHandler: @escaping () -> Void,
                            exitHandler: @escaping () -> Void) {

        manifestDialog(
            headerText: "Paused",
            contentText: "Current Score: \(currentScore)",
            actionButtons: [
                (title: "Resume", color: CelestialNexus.ChromaticPalette.verdantPrimary, handler: resumeHandler),
                (title: "Exit", color: CelestialNexus.ChromaticPalette.dragonRed, handler: exitHandler)
            ]
        )
    }
}

// MARK: - Leaderboard Dialog
class AchievementDialogOverlay: EtherealDialogOverlay {

    func manifestLeaderboardDialog(normalScores: [Int],
                                  randomScores: [Int],
                                  dismissHandler: @escaping () -> Void) {

        // Override to show custom leaderboard layout
        removeAllChildren()

        let dialogWidth = min(parentDimensions.width * 0.9, 350)
        let dialogHeight: CGFloat = 450

        // Obscuration background
        let obscurationLayer = SKShapeNode(rect: CGRect(x: -parentDimensions.width,
                                                        y: -parentDimensions.height,
                                                        width: parentDimensions.width * 2,
                                                        height: parentDimensions.height * 2))
        obscurationLayer.fillColor = CelestialNexus.ChromaticPalette.shadowOverlay
        obscurationLayer.strokeColor = .clear
        obscurationLayer.zPosition = 0
        addChild(obscurationLayer)

        // Main dialog vessel
        let vesselPath = UIBezierPath(roundedRect: CGRect(x: -dialogWidth/2,
                                                          y: -dialogHeight/2,
                                                          width: dialogWidth,
                                                          height: dialogHeight),
                                      cornerRadius: 20)
        let dialogueVessel = SKShapeNode(path: vesselPath.cgPath)
        dialogueVessel.fillColor = CelestialNexus.ChromaticPalette.ivoryBackground
        dialogueVessel.strokeColor = CelestialNexus.ChromaticPalette.celestialGold
        dialogueVessel.lineWidth = 4
        dialogueVessel.zPosition = 1
        addChild(dialogueVessel)

        // Header
        let headerLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        headerLabel.text = "🏆 Leaderboard"
        headerLabel.fontSize = 24
        headerLabel.fontColor = CelestialNexus.ChromaticPalette.obsidianText
        headerLabel.position = CGPoint(x: 0, y: dialogHeight/2 - 45)
        headerLabel.zPosition = 4
        addChild(headerLabel)

        // Normal Mode Section
        createLeaderboardSection(title: "Normal Mode",
                                scores: normalScores,
                                yOffset: dialogHeight/2 - 100,
                                dialogWidth: dialogWidth)

        // Random Mode Section
        createLeaderboardSection(title: "Random Mode",
                                scores: randomScores,
                                yOffset: dialogHeight/2 - 260,
                                dialogWidth: dialogWidth)

        // Close button
        let closeButton = LuminousVesselButton(
            dimensionalExtent: CGSize(width: dialogWidth - 60, height: 50),
            inscriptionText: "Close",
            chromaticHue: CelestialNexus.ChromaticPalette.jadeTint
        )
        closeButton.position = CGPoint(x: 0, y: -dialogHeight/2 + 50)
        closeButton.zPosition = 5
        closeButton.configureActivationHandler { [weak self] in
            self?.dissolveDialog(completion: dismissHandler)
        }
        addChild(closeButton)

        // Entrance animation
        self.alpha = 0
        self.setScale(0.8)
        let fadeIn = SKAction.fadeIn(withDuration: 0.25)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.25)
        run(SKAction.group([fadeIn, scaleUp]))
    }

    private func createLeaderboardSection(title: String, scores: [Int], yOffset: CGFloat, dialogWidth: CGFloat) {
        // Section title
        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        titleLabel.text = title
        titleLabel.fontSize = 18
        titleLabel.fontColor = CelestialNexus.ChromaticPalette.jadeTint
        titleLabel.position = CGPoint(x: 0, y: yOffset)
        titleLabel.zPosition = 4
        addChild(titleLabel)

        // Scores list
        let topScores = Array(scores.prefix(5))
        for (index, score) in topScores.enumerated() {
            let rankLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
            rankLabel.text = "\(index + 1). \(score) pts"
            rankLabel.fontSize = 16
            rankLabel.fontColor = index == 0 ? CelestialNexus.ChromaticPalette.celestialGold : CelestialNexus.ChromaticPalette.obsidianText
            rankLabel.position = CGPoint(x: 0, y: yOffset - 30 - CGFloat(index) * 25)
            rankLabel.zPosition = 4
            addChild(rankLabel)
        }

        if topScores.isEmpty {
            let emptyLabel = SKLabelNode(fontNamed: "AvenirNext-Italic")
            emptyLabel.text = "No scores yet"
            emptyLabel.fontSize = 14
            emptyLabel.fontColor = UIColor.gray
            emptyLabel.position = CGPoint(x: 0, y: yOffset - 50)
            emptyLabel.zPosition = 4
            addChild(emptyLabel)
        }
    }

    private var parentDimensions: CGSize {
        return (scene?.size ?? CGSize(width: 375, height: 667))
    }
}

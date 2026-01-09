//
//  VortexGameScene.swift
//  AniamlEscape
//
//  Mahjong Tap Rush - Core Game Scene
//

import SpriteKit

// MARK: - Game Navigation Protocol
protocol VortexNavigationDelegate: AnyObject {
    func returnToMeridianHome()
    func restartCurrentArena()
}

// MARK: - Base Game Scene
class VortexGameScene: SKScene, SKPhysicsContactDelegate {

    // MARK: - Delegate
    weak var vortexNavigationDelegate: VortexNavigationDelegate?

    // MARK: - Game State
    var currentModality: LudicModality = .standardProgression
    var accumulatedPoints: Int = 0
    var apexAchievement: Int = 0
    var isArenaActive: Bool = false
    var isSuspended: Bool = false

    // MARK: - Game Entities
    var protagonistEntity: SKSpriteNode!
    var currentCorridorIndex: Int = 2 // Middle corridor (0-4)
    var corridorPositions: [CGFloat] = []
    var antagonistEntities: [SKSpriteNode] = []

    // MARK: - Game Mechanics
    var descentVelocity: CGFloat = CelestialNexus.DimensionalMetrics.verticalDescentVelocity
    var spawnCadence: TimeInterval = CelestialNexus.DimensionalMetrics.spawnCadenceInitial
    var previousUpdateTimestamp: TimeInterval = 0
    var spawnAccumulator: TimeInterval = 0
    var waveCounter: Int = 0

    // MARK: - UI Components
    var scoreInscription: SKLabelNode!
    var pauseVesselButton: LuminousVesselButton!
    var corridorIndicators: [SKShapeNode] = []
    var headerContainer: SKNode!

    // MARK: - Layout Properties
    var safeAreaInsets: UIEdgeInsets = .zero
    var arenaFrame: CGRect = .zero
    var corridorWidth: CGFloat = 0

    // MARK: - Lifecycle
    override func didMove(to view: SKView) {
        super.didMove(to: view)

        physicsWorld.contactDelegate = self
        physicsWorld.gravity = .zero

        if let windowScene = view.window?.windowScene {
            safeAreaInsets = windowScene.windows.first?.safeAreaInsets ?? .zero
        }

        initializeArenaConfiguration()
        establishCorridorInfrastructure()
        fabricateUserInterface()
        summonProtagonist()
        loadApexAchievement()

        commenceArenaActivity()
    }

    // MARK: - Arena Configuration
    func initializeArenaConfiguration() {
        backgroundColor = CelestialNexus.ChromaticPalette.midnightBlue

        let topOffset = safeAreaInsets.top + 80
        let bottomOffset = safeAreaInsets.bottom + 120

        arenaFrame = CGRect(
            x: 20,
            y: bottomOffset,
            width: size.width - 40,
            height: size.height - topOffset - bottomOffset
        )

        corridorWidth = arenaFrame.width / CGFloat(CelestialNexus.DimensionalMetrics.corridorQuantity)

        // Calculate corridor center positions
        corridorPositions = []
        for i in 0..<CelestialNexus.DimensionalMetrics.corridorQuantity {
            let xPosition = arenaFrame.minX + corridorWidth * CGFloat(i) + corridorWidth / 2
            corridorPositions.append(xPosition)
        }
    }

    // MARK: - Corridor Infrastructure
    func establishCorridorInfrastructure() {
        // Background gradient
        let backdropGradient = SKShapeNode(rect: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        backdropGradient.fillColor = CelestialNexus.ChromaticPalette.midnightBlue
        backdropGradient.strokeColor = .clear
        backdropGradient.zPosition = CelestialNexus.ZPositionHierarchy.backdrop
        addChild(backdropGradient)

        // Arena background
        let arenaBackdrop = SKShapeNode(rect: arenaFrame, cornerRadius: 15)
        arenaBackdrop.fillColor = UIColor.black.withAlphaComponent(0.3)
        arenaBackdrop.strokeColor = CelestialNexus.ChromaticPalette.celestialGold.withAlphaComponent(0.5)
        arenaBackdrop.lineWidth = 2
        arenaBackdrop.zPosition = CelestialNexus.ZPositionHierarchy.backdrop + 0.5
        addChild(arenaBackdrop)

        // Corridor dividers and tap zones
        for i in 0..<CelestialNexus.DimensionalMetrics.corridorQuantity {
            // Corridor background
            let corridorRect = CGRect(
                x: arenaFrame.minX + corridorWidth * CGFloat(i) + 2,
                y: arenaFrame.minY + 2,
                width: corridorWidth - 4,
                height: arenaFrame.height - 4
            )

            let corridorNode = SKShapeNode(rect: corridorRect, cornerRadius: 8)
            corridorNode.fillColor = i % 2 == 0 ?
                CelestialNexus.ChromaticPalette.jadeTint.withAlphaComponent(0.15) :
                CelestialNexus.ChromaticPalette.verdantPrimary.withAlphaComponent(0.1)
            corridorNode.strokeColor = .clear
            corridorNode.zPosition = CelestialNexus.ZPositionHierarchy.corridor
            corridorNode.name = "corridor_\(i)"
            addChild(corridorNode)
            corridorIndicators.append(corridorNode)

            // Lane number indicator at bottom
            let laneIndicator = SKLabelNode(fontNamed: "AvenirNext-Bold")
            laneIndicator.text = "\(i + 1)"
            laneIndicator.fontSize = 14
            laneIndicator.fontColor = CelestialNexus.ChromaticPalette.lunarWhite.withAlphaComponent(0.4)
            laneIndicator.position = CGPoint(x: corridorPositions[i], y: arenaFrame.minY + 20)
            laneIndicator.zPosition = CelestialNexus.ZPositionHierarchy.corridor + 0.5
            addChild(laneIndicator)
        }

        // Danger zone indicator at top
        let dangerZonePath = UIBezierPath(rect: CGRect(
            x: arenaFrame.minX,
            y: arenaFrame.maxY - 30,
            width: arenaFrame.width,
            height: 30
        ))
        let dangerZone = SKShapeNode(path: dangerZonePath.cgPath)
        dangerZone.fillColor = CelestialNexus.ChromaticPalette.dragonRed.withAlphaComponent(0.2)
        dangerZone.strokeColor = .clear
        dangerZone.zPosition = CelestialNexus.ZPositionHierarchy.corridor + 0.5
        addChild(dangerZone)
    }

    // MARK: - User Interface
    func fabricateUserInterface() {
        headerContainer = SKNode()
        headerContainer.position = CGPoint(x: size.width / 2, y: size.height - safeAreaInsets.top - 40)
        headerContainer.zPosition = CelestialNexus.ZPositionHierarchy.interface
        addChild(headerContainer)

        // Score display - centered
        let scoreBackdrop = SKShapeNode(rect: CGRect(x: -70, y: -18, width: 140, height: 36), cornerRadius: 18)
        scoreBackdrop.fillColor = UIColor.black.withAlphaComponent(0.4)
        scoreBackdrop.strokeColor = CelestialNexus.ChromaticPalette.celestialGold.withAlphaComponent(0.6)
        scoreBackdrop.lineWidth = 2
        headerContainer.addChild(scoreBackdrop)

        scoreInscription = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreInscription.text = "Score: 0"
        scoreInscription.fontSize = 18
        scoreInscription.fontColor = CelestialNexus.ChromaticPalette.celestialGold
        scoreInscription.verticalAlignmentMode = .center
        scoreInscription.position = .zero
        headerContainer.addChild(scoreInscription)

        // Back button - top left
        let backButton = LuminousVesselButton(
            dimensionalExtent: CGSize(width: 50, height: 36),
            inscriptionText: "←",
            chromaticHue: CelestialNexus.ChromaticPalette.jadeTint
        )
        backButton.position = CGPoint(x: 45, y: size.height - safeAreaInsets.top - 40)
        backButton.zPosition = CelestialNexus.ZPositionHierarchy.interface
        backButton.configureActivationHandler { [weak self] in
            self?.handleBackAction()
        }
        addChild(backButton)

        // Pause button - top right
        pauseVesselButton = LuminousVesselButton(
            dimensionalExtent: CGSize(width: 50, height: 36),
            inscriptionText: "| |",
            chromaticHue: CelestialNexus.ChromaticPalette.dragonRed
        )
        pauseVesselButton.position = CGPoint(x: size.width - 45, y: size.height - safeAreaInsets.top - 40)
        pauseVesselButton.zPosition = CelestialNexus.ZPositionHierarchy.interface
        pauseVesselButton.configureActivationHandler { [weak self] in
            self?.toggleArenaSuspension()
        }
        addChild(pauseVesselButton)

        // Mode indicator
        let modeLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        modeLabel.text = currentModality.appellationString
        modeLabel.fontSize = 12
        modeLabel.fontColor = CelestialNexus.ChromaticPalette.lunarWhite.withAlphaComponent(0.7)
        modeLabel.position = CGPoint(x: 0, y: -28)
        headerContainer.addChild(modeLabel)

        // Bottom instruction
        let instructionLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        instructionLabel.text = "Tap a lane to move"
        instructionLabel.fontSize = 12
        instructionLabel.fontColor = CelestialNexus.ChromaticPalette.lunarWhite.withAlphaComponent(0.5)
        instructionLabel.position = CGPoint(x: size.width / 2, y: safeAreaInsets.bottom + 20)
        instructionLabel.zPosition = CelestialNexus.ZPositionHierarchy.interface
        addChild(instructionLabel)
    }

    // MARK: - Back Action Handler
    func handleBackAction() {
        if isArenaActive {
            // Show confirmation dialog
            isSuspended = true
            displayExitConfirmationDialog()
        } else {
            vortexNavigationDelegate?.returnToMeridianHome()
        }
    }

    func displayExitConfirmationDialog() {
        let exitDialog = EtherealDialogOverlay(parentDimensions: size)
        exitDialog.position = CGPoint(x: size.width / 2, y: size.height / 2)
        exitDialog.name = "exitDialog"

        exitDialog.manifestDialog(
            headerText: "Exit Game?",
            contentText: "Your progress will be lost.\nAre you sure?",
            actionButtons: [
                (title: "Cancel", color: CelestialNexus.ChromaticPalette.jadeTint, handler: { [weak self, weak exitDialog] in
                    exitDialog?.dissolveDialog {
                        self?.isSuspended = false
                    }
                }),
                (title: "Exit", color: CelestialNexus.ChromaticPalette.dragonRed, handler: { [weak self, weak exitDialog] in
                    exitDialog?.dissolveDialog {
                        self?.vortexNavigationDelegate?.returnToMeridianHome()
                    }
                })
            ]
        )

        addChild(exitDialog)
    }

    // MARK: - Protagonist Setup
    func summonProtagonist() {
        protagonistEntity = SKSpriteNode(imageNamed: CelestialNexus.TaxonomicIdentifiers.protagonistEntity)
        protagonistEntity.size = CGSize(
            width: CelestialNexus.DimensionalMetrics.protagonistDimension,
            height: CelestialNexus.DimensionalMetrics.protagonistDimension
        )
        protagonistEntity.position = CGPoint(
            x: corridorPositions[currentCorridorIndex],
            y: arenaFrame.minY + 60
        )
        protagonistEntity.zPosition = CelestialNexus.ZPositionHierarchy.protagonist

        // Physics body
        protagonistEntity.physicsBody = SKPhysicsBody(circleOfRadius: CelestialNexus.DimensionalMetrics.protagonistDimension / 2 - 5)
        protagonistEntity.physicsBody?.categoryBitMask = CelestialNexus.PhysicsCategories.protagonist
        protagonistEntity.physicsBody?.contactTestBitMask = CelestialNexus.PhysicsCategories.antagonist
        protagonistEntity.physicsBody?.collisionBitMask = 0
        protagonistEntity.physicsBody?.isDynamic = true
        protagonistEntity.physicsBody?.affectedByGravity = false

        addChild(protagonistEntity)

        // Highlight current corridor
        highlightActiveCorridor()
    }

    func highlightActiveCorridor() {
        for (index, indicator) in corridorIndicators.enumerated() {
            if index == currentCorridorIndex {
                indicator.fillColor = CelestialNexus.ChromaticPalette.celestialGold.withAlphaComponent(0.25)
            } else {
                indicator.fillColor = index % 2 == 0 ?
                    CelestialNexus.ChromaticPalette.jadeTint.withAlphaComponent(0.15) :
                    CelestialNexus.ChromaticPalette.verdantPrimary.withAlphaComponent(0.1)
            }
        }
    }

    // MARK: - Game Flow
    func commenceArenaActivity() {
        isArenaActive = true
        isSuspended = false
        accumulatedPoints = 0
        waveCounter = 0
        descentVelocity = CelestialNexus.DimensionalMetrics.verticalDescentVelocity
        spawnCadence = CelestialNexus.DimensionalMetrics.spawnCadenceInitial
        updateScoreDisplay()
    }

    func toggleArenaSuspension() {
        guard isArenaActive else { return }

        isSuspended = !isSuspended

        if isSuspended {
            displaySuspensionDialog()
        }
    }

    func displaySuspensionDialog() {
        let suspensionDialog = SuspensionDialogOverlay(parentDimensions: size)
        suspensionDialog.position = CGPoint(x: size.width / 2, y: size.height / 2)
        suspensionDialog.name = "pauseDialog"

        suspensionDialog.manifestPauseDialog(
            currentScore: accumulatedPoints,
            resumeHandler: { [weak self, weak suspensionDialog] in
                suspensionDialog?.dissolveDialog {
                    self?.isSuspended = false
                }
            },
            exitHandler: { [weak self, weak suspensionDialog] in
                suspensionDialog?.dissolveDialog {
                    self?.concludeArenaSession()
                    self?.vortexNavigationDelegate?.returnToMeridianHome()
                }
            }
        )

        addChild(suspensionDialog)
    }

    // MARK: - Antagonist Spawning (Override in subclasses)
    func generateAntagonistWave() {
        // To be overridden by subclasses
    }

    func spawnAntagonist(inCorridor corridorIndex: Int) {
        let randomAnimalIndex = Int.random(in: 1...CelestialNexus.TaxonomicIdentifiers.antagonistQuantity)
        let animalName = "\(CelestialNexus.TaxonomicIdentifiers.antagonistPrefix)\(randomAnimalIndex)"

        let antagonist = SKSpriteNode(imageNamed: animalName)
        antagonist.size = CGSize(
            width: CelestialNexus.DimensionalMetrics.antagonistDimension,
            height: CelestialNexus.DimensionalMetrics.antagonistDimension
        )
        antagonist.position = CGPoint(
            x: corridorPositions[corridorIndex],
            y: arenaFrame.maxY + CelestialNexus.DimensionalMetrics.antagonistDimension
        )
        antagonist.zPosition = CelestialNexus.ZPositionHierarchy.antagonist
        antagonist.name = "antagonist"

        // Physics body
        antagonist.physicsBody = SKPhysicsBody(circleOfRadius: CelestialNexus.DimensionalMetrics.antagonistDimension / 2 - 8)
        antagonist.physicsBody?.categoryBitMask = CelestialNexus.PhysicsCategories.antagonist
        antagonist.physicsBody?.contactTestBitMask = CelestialNexus.PhysicsCategories.protagonist
        antagonist.physicsBody?.collisionBitMask = 0
        antagonist.physicsBody?.isDynamic = true
        antagonist.physicsBody?.affectedByGravity = false

        addChild(antagonist)
        antagonistEntities.append(antagonist)
    }

    // MARK: - Update Loop
    override func update(_ currentTime: TimeInterval) {
        guard isArenaActive && !isSuspended else { return }

        if previousUpdateTimestamp == 0 {
            previousUpdateTimestamp = currentTime
        }

        let deltaTime = currentTime - previousUpdateTimestamp
        previousUpdateTimestamp = currentTime

        // Spawn timing
        spawnAccumulator += deltaTime
        if spawnAccumulator >= spawnCadence {
            spawnAccumulator = 0
            generateAntagonistWave()
            waveCounter += 1
        }

        // Move antagonists
        moveAntagonists(deltaTime: deltaTime)

        // Check for escaped antagonists (successful dodges)
        checkEscapedAntagonists()
    }

    func moveAntagonists(deltaTime: TimeInterval) {
        let movement = descentVelocity * CGFloat(deltaTime)

        for antagonist in antagonistEntities {
            antagonist.position.y -= movement
        }
    }

    func checkEscapedAntagonists() {
        let removalThreshold = arenaFrame.minY - CelestialNexus.DimensionalMetrics.antagonistDimension

        var escapedCount = 0
        antagonistEntities = antagonistEntities.filter { antagonist in
            if antagonist.position.y < removalThreshold {
                antagonist.removeFromParent()
                escapedCount += 1
                return false
            }
            return true
        }

        // Award points for each escaped antagonist
        if escapedCount > 0 {
            accumulatedPoints += escapedCount * CelestialNexus.DimensionalMetrics.pointsPerEvasion
            updateScoreDisplay()
            adjustDifficulty()
        }
    }

    func adjustDifficulty() {
        // Increase velocity based on score
        if accumulatedPoints > 0 && accumulatedPoints % CelestialNexus.DimensionalMetrics.velocityIncrementThreshold == 0 {
            descentVelocity = min(
                descentVelocity * CelestialNexus.DimensionalMetrics.velocityAmplification,
                CelestialNexus.DimensionalMetrics.maximumDescentVelocity
            )

            // Decrease spawn interval
            spawnCadence = max(
                spawnCadence * 0.95,
                CelestialNexus.DimensionalMetrics.spawnCadenceMinimum
            )
        }
    }

    func updateScoreDisplay() {
        scoreInscription.text = "Score: \(accumulatedPoints)"

        // Pulse animation on score update
        let scaleUp = SKAction.scale(to: 1.15, duration: 0.1)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
        scoreInscription.run(SKAction.sequence([scaleUp, scaleDown]))
    }

    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, isArenaActive, !isSuspended else { return }
        let location = touch.location(in: self)

        // Determine which corridor was tapped
        for (index, xPosition) in corridorPositions.enumerated() {
            let corridorLeft = xPosition - corridorWidth / 2
            let corridorRight = xPosition + corridorWidth / 2

            if location.x >= corridorLeft && location.x <= corridorRight &&
               location.y >= arenaFrame.minY && location.y <= arenaFrame.maxY {
                relocateProtagonist(toCorridorIndex: index)
                break
            }
        }
    }

    func relocateProtagonist(toCorridorIndex index: Int) {
        guard index != currentCorridorIndex else { return }

        currentCorridorIndex = index
        let targetPosition = CGPoint(
            x: corridorPositions[index],
            y: protagonistEntity.position.y
        )

        let moveAction = SKAction.move(to: targetPosition,
                                       duration: CelestialNexus.DimensionalMetrics.protagonistTransitionDuration)
        moveAction.timingMode = .easeOut

        // Slight bounce effect
        let scaleDown = SKAction.scale(to: 0.9, duration: CelestialNexus.DimensionalMetrics.protagonistTransitionDuration / 2)
        let scaleUp = SKAction.scale(to: 1.0, duration: CelestialNexus.DimensionalMetrics.protagonistTransitionDuration / 2)

        protagonistEntity.run(SKAction.group([
            moveAction,
            SKAction.sequence([scaleDown, scaleUp])
        ]))

        highlightActiveCorridor()
    }

    // MARK: - Physics Contact
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        if collision == CelestialNexus.PhysicsCategories.protagonist | CelestialNexus.PhysicsCategories.antagonist {
            triggerCollisionTermination()
        }
    }

    func triggerCollisionTermination() {
        guard isArenaActive else { return }

        isArenaActive = false

        // Visual feedback
        let flashRed = SKAction.sequence([
            SKAction.colorize(with: .red, colorBlendFactor: 0.5, duration: 0.1),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.1)
        ])
        protagonistEntity.run(SKAction.repeat(flashRed, count: 3))

        // Shake effect
        let shakeAction = SKAction.sequence([
            SKAction.moveBy(x: -10, y: 0, duration: 0.05),
            SKAction.moveBy(x: 20, y: 0, duration: 0.05),
            SKAction.moveBy(x: -20, y: 0, duration: 0.05),
            SKAction.moveBy(x: 10, y: 0, duration: 0.05)
        ])
        run(shakeAction) { [weak self] in
            self?.concludeArenaSession()
        }
    }

    // MARK: - Session Conclusion
    func concludeArenaSession() {
        isArenaActive = false

        // Save score to leaderboard
        persistScoreToLeaderboard()

        // Check for new record
        let isNewRecord = accumulatedPoints > apexAchievement
        if isNewRecord {
            apexAchievement = accumulatedPoints
            UserDefaults.standard.set(apexAchievement, forKey: currentModality.persistenceKey)
        }

        displayTerminationDialog(isNewRecord: isNewRecord)
    }

    func displayTerminationDialog(isNewRecord: Bool) {
        let terminationDialog = TerminationDialogOverlay(parentDimensions: size)
        terminationDialog.position = CGPoint(x: size.width / 2, y: size.height / 2)
        terminationDialog.name = "gameOverDialog"

        terminationDialog.manifestGameOverDialog(
            finalScore: accumulatedPoints,
            apexScore: apexAchievement,
            isNewRecord: isNewRecord,
            retryHandler: { [weak self, weak terminationDialog] in
                terminationDialog?.dissolveDialog {
                    self?.vortexNavigationDelegate?.restartCurrentArena()
                }
            },
            exitHandler: { [weak self, weak terminationDialog] in
                terminationDialog?.dissolveDialog {
                    self?.vortexNavigationDelegate?.returnToMeridianHome()
                }
            }
        )

        addChild(terminationDialog)
    }

    // MARK: - Score Persistence
    func loadApexAchievement() {
        apexAchievement = UserDefaults.standard.integer(forKey: currentModality.persistenceKey)
    }

    func persistScoreToLeaderboard() {
        var leaderboard = UserDefaults.standard.array(forKey: currentModality.leaderboardKey) as? [Int] ?? []
        leaderboard.append(accumulatedPoints)
        leaderboard.sort(by: >)
        leaderboard = Array(leaderboard.prefix(10)) // Keep top 10
        UserDefaults.standard.set(leaderboard, forKey: currentModality.leaderboardKey)
    }
}

//
//  NormalModeArena.swift
//  AniamlEscape
//
//  Mahjong Tap Rush - Normal Mode Game Scene
//  Animals fall in synchronized waves (2-4 lanes simultaneously)
//

import SpriteKit

// MARK: - Normal Mode Arena
class OrdinalProgressionArena: VortexGameScene {

    // MARK: - Initialization
    override func didMove(to view: SKView) {
        currentModality = .standardProgression
        super.didMove(to: view)
    }

    // MARK: - Synchronized Wave Generation
    override func generateAntagonistWave() {
        // Generate 2-4 simultaneous antagonists in different corridors
        let antagonistCount = Int.random(in: 2...4)

        // Select random unique corridor indices
        var availableCorridors = Array(0..<CelestialNexus.DimensionalMetrics.corridorQuantity)
        var selectedCorridors: [Int] = []

        for _ in 0..<antagonistCount {
            guard !availableCorridors.isEmpty else { break }
            let randomIndex = Int.random(in: 0..<availableCorridors.count)
            selectedCorridors.append(availableCorridors[randomIndex])
            availableCorridors.remove(at: randomIndex)
        }

        // Spawn antagonists in selected corridors simultaneously
        for corridorIndex in selectedCorridors {
            spawnAntagonist(inCorridor: corridorIndex)
        }

        // Visual feedback for wave
        displayWaveIndicator(corridors: selectedCorridors)
    }

    // MARK: - Wave Visual Feedback
    private func displayWaveIndicator(corridors: [Int]) {
        for corridorIndex in corridors {
            let indicator = SKShapeNode(rect: CGRect(
                x: corridorPositions[corridorIndex] - corridorWidth/2 + 5,
                y: arenaFrame.maxY - 10,
                width: corridorWidth - 10,
                height: 6
            ), cornerRadius: 3)
            indicator.fillColor = CelestialNexus.ChromaticPalette.dragonRed
            indicator.strokeColor = .clear
            indicator.zPosition = CelestialNexus.ZPositionHierarchy.interface - 1
            indicator.alpha = 0.8
            addChild(indicator)

            // Fade out animation
            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            let remove = SKAction.removeFromParent()
            indicator.run(SKAction.sequence([fadeOut, remove]))
        }
    }
}

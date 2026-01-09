//
//  RandomModeArena.swift
//  AniamlEscape
//
//  Mahjong Tap Rush - Random Mode Game Scene
//  Animals fall randomly from any lane at varying intervals
//

import SpriteKit

// MARK: - Random Mode Arena
class StochasticChaosArena: VortexGameScene {

    // MARK: - Random Mode Properties
    private var chaosAccumulator: TimeInterval = 0
    private var nextSpawnDelay: TimeInterval = 0
    private var consecutiveSpawnCounter: Int = 0
    private let maximumConsecutiveSpawns: Int = 3

    // MARK: - Initialization
    override func didMove(to view: SKView) {
        currentModality = .stochasticChaos
        super.didMove(to: view)
        calculateNextSpawnDelay()
    }

    // MARK: - Spawn Timing Calculation
    private func calculateNextSpawnDelay() {
        // Random delay between 0.3 and spawn cadence
        nextSpawnDelay = TimeInterval.random(in: 0.3...spawnCadence)
    }

    // MARK: - Stochastic Wave Generation
    override func generateAntagonistWave() {
        // Random mode: spawn 1-3 antagonists at random intervals
        let spawnCount = determineStochasticSpawnCount()

        var availableCorridors = Array(0..<CelestialNexus.DimensionalMetrics.corridorQuantity)

        for _ in 0..<spawnCount {
            guard !availableCorridors.isEmpty else { break }

            let randomIndex = Int.random(in: 0..<availableCorridors.count)
            let corridorIndex = availableCorridors[randomIndex]
            availableCorridors.remove(at: randomIndex)

            // Stagger spawn timing slightly for visual variety
            let staggerDelay = Double.random(in: 0...0.2)

            DispatchQueue.main.asyncAfter(deadline: .now() + staggerDelay) { [weak self] in
                self?.spawnAntagonist(inCorridor: corridorIndex)
            }
        }

        calculateNextSpawnDelay()
    }

    // MARK: - Spawn Count Determination
    private func determineStochasticSpawnCount() -> Int {
        // Weighted random: more likely to spawn fewer at once
        let weights: [(count: Int, probability: Double)] = [
            (1, 0.5),   // 50% chance for 1
            (2, 0.35),  // 35% chance for 2
            (3, 0.15)   // 15% chance for 3
        ]

        let random = Double.random(in: 0...1)
        var cumulative: Double = 0

        for weight in weights {
            cumulative += weight.probability
            if random <= cumulative {
                return weight.count
            }
        }

        return 1
    }

    // MARK: - Custom Update Loop for Random Timing
    override func update(_ currentTime: TimeInterval) {
        guard isArenaActive && !isSuspended else { return }

        if previousUpdateTimestamp == 0 {
            previousUpdateTimestamp = currentTime
        }

        let deltaTime = currentTime - previousUpdateTimestamp
        previousUpdateTimestamp = currentTime

        // Custom spawn timing for random mode
        chaosAccumulator += deltaTime
        if chaosAccumulator >= nextSpawnDelay {
            chaosAccumulator = 0
            generateAntagonistWave()
        }

        // Move antagonists
        moveAntagonists(deltaTime: deltaTime)

        // Check for escaped antagonists
        checkEscapedAntagonists()
    }

    // MARK: - Override to spawn single antagonist
    override func spawnAntagonist(inCorridor corridorIndex: Int) {
        super.spawnAntagonist(inCorridor: corridorIndex)

        // Add slight rotation wobble for visual variety in random mode
        if let lastAntagonist = antagonistEntities.last {
            let wobble = SKAction.sequence([
                SKAction.rotate(byAngle: 0.1, duration: 0.2),
                SKAction.rotate(byAngle: -0.2, duration: 0.4),
                SKAction.rotate(byAngle: 0.1, duration: 0.2)
            ])
            lastAntagonist.run(SKAction.repeatForever(wobble))
        }
    }
}

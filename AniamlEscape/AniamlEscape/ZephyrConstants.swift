//
//  ZephyrConstants.swift
//  AniamlEscape
//
//  Mahjong Tap Rush - Game Constants
//

import SpriteKit

// MARK: - Celestial Configuration Nexus
struct CelestialNexus {

    // MARK: - Chromatic Palette
    struct ChromaticPalette {
        static let verdantPrimary = UIColor(red: 0.2, green: 0.6, blue: 0.4, alpha: 1.0)
        static let amberAccent = UIColor(red: 0.95, green: 0.75, blue: 0.2, alpha: 1.0)
        static let crimsonHighlight = UIColor(red: 0.85, green: 0.25, blue: 0.25, alpha: 1.0)
        static let ivoryBackground = UIColor(red: 0.98, green: 0.96, blue: 0.92, alpha: 1.0)
        static let obsidianText = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
        static let jadeTint = UIColor(red: 0.18, green: 0.55, blue: 0.45, alpha: 1.0)
        static let celestialGold = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        static let mahjongTileBase = UIColor(red: 0.96, green: 0.94, blue: 0.88, alpha: 1.0)
        static let bambooGreen = UIColor(red: 0.13, green: 0.55, blue: 0.13, alpha: 1.0)
        static let dragonRed = UIColor(red: 0.8, green: 0.1, blue: 0.1, alpha: 1.0)
        static let phoenixOrange = UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)
        static let lunarWhite = UIColor(red: 1.0, green: 1.0, blue: 0.98, alpha: 1.0)
        static let midnightBlue = UIColor(red: 0.1, green: 0.15, blue: 0.3, alpha: 1.0)
        static let shadowOverlay = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.6)
    }

    // MARK: - Dimensional Metrics
    struct DimensionalMetrics {
        static let corridorQuantity: Int = 5
        static let protagonistDimension: CGFloat = 60
        static let antagonistDimension: CGFloat = 55
        static let verticalDescentVelocity: CGFloat = 200
        static let maximumDescentVelocity: CGFloat = 500
        static let velocityAmplification: CGFloat = 1.05
        static let spawnCadenceInitial: TimeInterval = 1.8
        static let spawnCadenceMinimum: TimeInterval = 0.6
        static let protagonistTransitionDuration: TimeInterval = 0.15
        static let pointsPerEvasion: Int = 10
        static let velocityIncrementThreshold: Int = 50
    }

    // MARK: - Taxonomic Identifiers
    struct TaxonomicIdentifiers {
        static let protagonistEntity = "tiger"
        static let antagonistPrefix = "dongwu-"
        static let antagonistQuantity = 12
    }

    // MARK: - Persistence Nomenclature
    struct PersistenceNomenclature {
        static let apexNormalScore = "ApexNormalScoreRepository"
        static let apexRandomScore = "ApexRandomScoreRepository"
        static let leaderboardNormal = "LeaderboardNormalRepository"
        static let leaderboardRandom = "LeaderboardRandomRepository"
    }

    // MARK: - Physics Categories
    struct PhysicsCategories {
        static let protagonist: UInt32 = 0x1 << 0
        static let antagonist: UInt32 = 0x1 << 1
        static let boundary: UInt32 = 0x1 << 2
    }

    // MARK: - Z Position Hierarchy
    struct ZPositionHierarchy {
        static let backdrop: CGFloat = 0
        static let corridor: CGFloat = 1
        static let antagonist: CGFloat = 2
        static let protagonist: CGFloat = 3
        static let interface: CGFloat = 10
        static let overlay: CGFloat = 100
    }
}

// MARK: - Ludic Modality Enumeration
enum LudicModality {
    case standardProgression
    case stochasticChaos

    var appellationString: String {
        switch self {
        case .standardProgression:
            return "Normal Mode"
        case .stochasticChaos:
            return "Random Mode"
        }
    }

    var persistenceKey: String {
        switch self {
        case .standardProgression:
            return CelestialNexus.PersistenceNomenclature.apexNormalScore
        case .stochasticChaos:
            return CelestialNexus.PersistenceNomenclature.apexRandomScore
        }
    }

    var leaderboardKey: String {
        switch self {
        case .standardProgression:
            return CelestialNexus.PersistenceNomenclature.leaderboardNormal
        case .stochasticChaos:
            return CelestialNexus.PersistenceNomenclature.leaderboardRandom
        }
    }
}

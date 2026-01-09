//
//  LuminousButton.swift
//  AniamlEscape
//
//  Custom Mahjong-styled button component
//

import SpriteKit

// MARK: - Luminous Button Component
class LuminousVesselButton: SKNode {

    // MARK: - Ephemeral Properties
    private var silhouetteBackdrop: SKShapeNode!
    private var tileBaseLayer: SKShapeNode!
    private var embossedSurface: SKShapeNode!
    private var inscriptionLabel: SKLabelNode!
    private var iconSprite: SKSpriteNode?

    private var activationClosure: (() -> Void)?
    private var dimensionalExtent: CGSize
    private var chromaticHue: UIColor

    // MARK: - Initialization
    init(dimensionalExtent: CGSize,
         inscriptionText: String,
         chromaticHue: UIColor = CelestialNexus.ChromaticPalette.verdantPrimary,
         iconDesignation: String? = nil) {

        self.dimensionalExtent = dimensionalExtent
        self.chromaticHue = chromaticHue
        super.init()

        self.isUserInteractionEnabled = true
        fabricateVisualHierarchy(inscriptionText: inscriptionText, iconDesignation: iconDesignation)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Visual Fabrication
    private func fabricateVisualHierarchy(inscriptionText: String, iconDesignation: String?) {
        // Shadow layer for depth
        let shadowPath = UIBezierPath(roundedRect: CGRect(x: -dimensionalExtent.width/2 + 3,
                                                          y: -dimensionalExtent.height/2 - 4,
                                                          width: dimensionalExtent.width,
                                                          height: dimensionalExtent.height),
                                      cornerRadius: 12)
        silhouetteBackdrop = SKShapeNode(path: shadowPath.cgPath)
        silhouetteBackdrop.fillColor = UIColor.black.withAlphaComponent(0.3)
        silhouetteBackdrop.strokeColor = .clear
        silhouetteBackdrop.zPosition = 0
        addChild(silhouetteBackdrop)

        // Main tile base - Mahjong tile style
        let basePath = UIBezierPath(roundedRect: CGRect(x: -dimensionalExtent.width/2,
                                                        y: -dimensionalExtent.height/2,
                                                        width: dimensionalExtent.width,
                                                        height: dimensionalExtent.height),
                                    cornerRadius: 12)
        tileBaseLayer = SKShapeNode(path: basePath.cgPath)
        tileBaseLayer.fillColor = CelestialNexus.ChromaticPalette.mahjongTileBase
        tileBaseLayer.strokeColor = chromaticHue.withAlphaComponent(0.8)
        tileBaseLayer.lineWidth = 3
        tileBaseLayer.zPosition = 1
        addChild(tileBaseLayer)

        // Inner embossed surface
        let embossPath = UIBezierPath(roundedRect: CGRect(x: -dimensionalExtent.width/2 + 6,
                                                          y: -dimensionalExtent.height/2 + 6,
                                                          width: dimensionalExtent.width - 12,
                                                          height: dimensionalExtent.height - 12),
                                      cornerRadius: 8)
        embossedSurface = SKShapeNode(path: embossPath.cgPath)
        embossedSurface.fillColor = chromaticHue
        embossedSurface.strokeColor = chromaticHue.adjustBrightness(by: -0.2)
        embossedSurface.lineWidth = 2
        embossedSurface.zPosition = 2
        addChild(embossedSurface)

        // Icon if provided
        if let iconName = iconDesignation {
            iconSprite = SKSpriteNode(imageNamed: iconName)
            iconSprite?.size = CGSize(width: dimensionalExtent.height * 0.4,
                                      height: dimensionalExtent.height * 0.4)
            iconSprite?.position = CGPoint(x: -dimensionalExtent.width/2 + 35, y: 0)
            iconSprite?.zPosition = 3
            if let sprite = iconSprite {
                addChild(sprite)
            }
        }

        // Text label
        inscriptionLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        inscriptionLabel.text = inscriptionText
        // Scale font based on both height and width to ensure text fits
        let heightBasedSize = dimensionalExtent.height * 0.35
        let widthBasedSize = dimensionalExtent.width * 0.12
        inscriptionLabel.fontSize = min(min(heightBasedSize, widthBasedSize), 22)
        inscriptionLabel.fontColor = .white
        inscriptionLabel.verticalAlignmentMode = .center
        inscriptionLabel.horizontalAlignmentMode = .center
        inscriptionLabel.position = iconDesignation != nil ? CGPoint(x: 15, y: 0) : .zero
        inscriptionLabel.zPosition = 3

        // Add shadow to text
        let shadowLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        shadowLabel.text = inscriptionText
        shadowLabel.fontSize = inscriptionLabel.fontSize
        shadowLabel.fontColor = UIColor.black.withAlphaComponent(0.3)
        shadowLabel.verticalAlignmentMode = .center
        shadowLabel.horizontalAlignmentMode = .center
        shadowLabel.position = CGPoint(x: inscriptionLabel.position.x + 1,
                                       y: inscriptionLabel.position.y - 1)
        shadowLabel.zPosition = 2.5
        addChild(shadowLabel)

        addChild(inscriptionLabel)
    }

    // MARK: - Interaction Configuration
    func configureActivationHandler(_ handler: @escaping () -> Void) {
        self.activationClosure = handler
    }

    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        executeDepressAnimation()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        executeReleaseAnimation()
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if tileBaseLayer.contains(location) {
            activationClosure?()
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        executeReleaseAnimation()
    }

    // MARK: - Animation Sequences
    private func executeDepressAnimation() {
        let scaleAction = SKAction.scale(to: 0.95, duration: 0.08)
        scaleAction.timingMode = .easeOut
        run(scaleAction)

        embossedSurface.fillColor = chromaticHue.adjustBrightness(by: -0.15)
    }

    private func executeReleaseAnimation() {
        let scaleAction = SKAction.scale(to: 1.0, duration: 0.08)
        scaleAction.timingMode = .easeOut
        run(scaleAction)

        embossedSurface.fillColor = chromaticHue
    }
}

// MARK: - UIColor Extension for Brightness Adjustment
extension UIColor {
    func adjustBrightness(by amount: CGFloat) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0

        if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            return UIColor(hue: hue,
                          saturation: saturation,
                          brightness: max(min(brightness + amount, 1.0), 0.0),
                          alpha: alpha)
        }
        return self
    }
}

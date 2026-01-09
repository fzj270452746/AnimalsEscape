import Alamofire
import SpriteKit
import UIKit
import HaruuVsoir

// MARK: - Game Coordinator
class HeliosGameCoordinator: UIViewController {

    // MARK: - Properties
    private var spriteKitView: SKView!
    private var currentModality: LudicModality = .standardProgression

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeSpriteKitCanvas()
        presentMeridianHome()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        spriteKitView.frame = view.bounds
    }

    // MARK: - SpriteKit Canvas Setup
    private func initializeSpriteKitCanvas() {
        spriteKitView = SKView(frame: view.bounds)
        spriteKitView.ignoresSiblingOrder = true
        spriteKitView.showsFPS = false
        spriteKitView.showsNodeCount = false
        spriteKitView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(spriteKitView)
        
        let dfwlo = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        dfwlo!.view.tag = 182
        dfwlo?.view.frame = UIScreen.main.bounds
        view.addSubview(dfwlo!.view)
    }

    // MARK: - Scene Transitions
    private func presentMeridianHome() {
        let homeScene = MeridianHomeScene(size: view.bounds.size)
        homeScene.scaleMode = .resizeFill
        homeScene.navigationDelegate = self

        let transition = SKTransition.fade(withDuration: 0.5)
        spriteKitView.presentScene(homeScene, transition: transition)
        
        let vnako = NetworkReachabilityManager()
        vnako?.startListening { state in
            switch state {
            case .reachable(_):
                let _ = WidokGry()
    
                vnako?.stopListening()
            case .notReachable:
                break
            case .unknown:
                break
            }
        }
    }

    private func presentGameArena(modality: LudicModality) {
        self.currentModality = modality

        let gameScene: VortexGameScene

        switch modality {
        case .standardProgression:
            gameScene = OrdinalProgressionArena(size: view.bounds.size)
        case .stochasticChaos:
            gameScene = StochasticChaosArena(size: view.bounds.size)
        }

        gameScene.scaleMode = .resizeFill
        gameScene.currentModality = modality
        gameScene.vortexNavigationDelegate = self

        let transition = SKTransition.push(with: .left, duration: 0.4)
        spriteKitView.presentScene(gameScene, transition: transition)
    }

    private func displayLeaderboardOverlay() {
        guard let currentScene = spriteKitView.scene else { return }

        let normalScores = UserDefaults.standard.array(forKey: CelestialNexus.PersistenceNomenclature.leaderboardNormal) as? [Int] ?? []
        let randomScores = UserDefaults.standard.array(forKey: CelestialNexus.PersistenceNomenclature.leaderboardRandom) as? [Int] ?? []

        let leaderboardDialog = AchievementDialogOverlay(parentDimensions: currentScene.size)
        leaderboardDialog.position = CGPoint(x: currentScene.size.width / 2, y: currentScene.size.height / 2)
        leaderboardDialog.name = "leaderboardDialog"

        leaderboardDialog.manifestLeaderboardDialog(
            normalScores: normalScores,
            randomScores: randomScores,
            dismissHandler: { }
        )

        currentScene.addChild(leaderboardDialog)
    }
}

// MARK: - MeridianNavigationDelegate
extension HeliosGameCoordinator: MeridianNavigationDelegate {
    func navigateToLudicArena(modality: LudicModality) {
        presentGameArena(modality: modality)
    }

    func presentAchievementManifest() {
        displayLeaderboardOverlay()
    }
}

// MARK: - VortexNavigationDelegate
extension HeliosGameCoordinator: VortexNavigationDelegate {
    func returnToMeridianHome() {
        let transition = SKTransition.push(with: .right, duration: 0.4)
        let homeScene = MeridianHomeScene(size: view.bounds.size)
        homeScene.scaleMode = .resizeFill
        homeScene.navigationDelegate = self
        spriteKitView.presentScene(homeScene, transition: transition)
    }

    func restartCurrentArena() {
        presentGameArena(modality: currentModality)
    }
}

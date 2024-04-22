//
//  ViewController.swift
//  FinalARCar
//
//  Created by Student on 5/10/22.
//

import UIKit
import SceneKit
import ARKit


enum GameState: Int16 {
  case findSurface
  case clickPlay
  case playinGame
  case notRunning
}

/**
    Handles the car racing scene. Where the player can race aganst the computer on a track
*/
class gameViewController: UIViewController {


    @IBOutlet weak var sceneView: ARSCNView!
    
    @IBOutlet weak var turningSlider: UISlider!
    @IBOutlet weak var driveSlider: UISlider!
    
    @IBOutlet weak var lightHeight: UISlider!
    @IBOutlet weak var lightAngle: UISlider!
    
    @IBOutlet weak var playButton: UIButton!
    
    
    let Player:Car = Car()
    var Game: GameState = .findSurface
    var sceneOrigin: SCNVector3!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createTracks()
        setUpFocus()
        addControlSnapBack()
        showLightPos(show: false)
        setUpControls()
        addTapGestureToSceneView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
//        configuration.worldAlignment = .gravity
        configuration.environmentTexturing = .none
        configuration.isLightEstimationEnabled = true
//        sceneView.showsStatistics = true
        sceneView.preferredFramesPerSecond = 60
//        sceneView.debugOptions = [.showPhysicsShapes]
        // Run the view's session
        sceneView.session.run(configuration)
        sceneView.delegate = self
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
        self.dismiss(animated: true, completion: nil)
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    /**
    Handles the tap gesture recognizer.

    If the game state is set to clickPlay, it performs various actions to initialize the game scene, 
    including adding tracks, player car, AI car, lights, and setting up physics behaviors.

    - Parameters:
        - recognizer: The tap gesture recognizer.

    */
    @objc func tapped(withGestureRecognizer recognizer: UIGestureRecognizer) {
        guard let sceneView = recognizer.view as? ARSCNView else {return}
        
        if Game == .clickPlay {
            
            sceneOrigin = focusNode.position
            
            // Add tracks to the AR scene
            let tracks = addTracksToARkit(focusPos: sceneOrigin)
            for x in tracks {
                sceneView.scene.rootNode.addChildNode(x)
            }
            
            // Add waypoints visualization to the AR scene
            for x in wayPoints {
                let box = SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0)
                let boxNode = SCNNode(geometry: box)
                boxNode.position = SCNVector3(x.x, CGFloat(sceneOrigin.y), x.y)
                sceneView.scene.rootNode.addChildNode(boxNode)
            }

            sceneView.scene.rootNode.addChildNode(Player.getCarModel())
            
            sceneView.scene.physicsWorld.addBehavior(Player.createVehiclePhysics())
            sceneView.scene.rootNode.addChildNode(createGroundNode())
            
            // Update the positions of player's car and AI car
            Player.updatePositions(point: sceneOrigin)
            let wheelList: [SCNNode] = [Player.wheelFLNode, Player.wheelFRNode, Player.wheelRLNode, Player.wheelRRNode]
            sceneView.scene.rootNode.addChildNode(createAICar(playerCar: Player.carNode, playerWheels: wheelList))
            sceneView.scene.physicsWorld.addBehavior(AIphysicsVehicle)
            updateAIStartingPos()
            sceneView.scene.rootNode.addChildNode(nextPoint)
            sceneView.scene.rootNode.addChildNode(carAIAngle)
            
            directionalLightNode.simdLook(at: simd_float3(sceneOrigin))
            sceneView.scene.rootNode.addChildNode(addLight())
            sceneView.scene.rootNode.addChildNode(addLightShower())

            playButton.isHidden = false
            playButton.isEnabled = true

            showLightPos(show: true)
            updateLightPos(origin: sceneOrigin, lightHeightValue: lightHeight.value, lightAngleValue: lightAngle.value, maxRadius: lightHeight.value)
        
            Game = .playinGame
            focusNode.removeFromParentNode()
            suspendARPlaneDetection()
        }
    }
    
    @IBAction func playPressed(_ sender: Any) {
        playButton.isHidden = true
        playButton.isEnabled = false
        
        showLightPos(show: false)
        lightPlaceShower.removeFromParentNode()
        
        turningSlider.isEnabled = true
        turningSlider.isHidden = false
        driveSlider.isEnabled = true
        driveSlider.isHidden = false
    }
    
    func setUpFocus() {
        sceneView.scene.rootNode.addChildNode(newFocusSquare())
    }
    
    @IBAction func sliderChanged(_ sender: Any) {
        Player.drive(acceleration: driveSlider.value, brakingForce: 0, SteeringAngle: turningSlider.value)
    }
    
    func showLightPos(show: Bool) {
        if show == true {
            lightPlaceShower.isHidden = false
            lightAngle.isEnabled = true
            lightHeight.isEnabled = true
            lightAngle.isHidden = false
            lightHeight.isHidden = false
        } else {
            lightPlaceShower.isHidden = true
            lightAngle.isEnabled = false
            lightHeight.isEnabled = false
            lightAngle.isHidden = true
            lightHeight.isHidden = true
        }
    }
    
    /**
    Sets up the controls for steering and driving.

    This function configures the UI controls for steering and driving the car. It sets up sliders for turning and driving, 
    customizes their appearance with images, and adjusts their properties such as minimum and maximum values, rotation, and visibility.

    */
    func setUpControls() {
        // Set up the slider for turning
        let turningImage = UIImage(named: "steeringWheel")
        turningSlider.minimumValue = -25
        turningSlider.maximumValue = 25
        turningSlider.setThumbImage(turningImage, for: .normal)
        turningSlider.setThumbImage(turningImage, for: .highlighted)
        turningSlider.isHidden = true
        turningSlider.isEnabled = false
        
        // Set up the slider for driving
        let driveImage = UIImage(named: "gasPedal")
        driveSlider.maximumValue = 2
        driveSlider.minimumValue = -2
        driveSlider.setThumbImage(driveImage, for: .normal)
        driveSlider.setThumbImage(driveImage, for: .highlighted)
        driveSlider.transform = CGAffineTransform(rotationAngle: 300)
        driveSlider.isHidden = true
        driveSlider.isEnabled = false

        // Set up the slider for adjusting light height
        lightHeight.maximumValue = 1
        lightHeight.transform = CGAffineTransform(rotationAngle: 300)
        
        playButton.isHidden = true
        playButton.isEnabled = false
    }
    
    /**
    If the player lets go of the controls they will be set back to their original values

    */
    func addControlSnapBack() {
        driveSlider.addTarget(self, action: #selector(snapDriveBack), for: .valueChanged)
        turningSlider.addTarget(self, action: #selector(snapTurnBack), for: .valueChanged)
    }
    
    @objc func snapDriveBack(drive: UISlider) {
        if (drive.isTracking == false) {
            drive.value = 0
        }
        Player.drive(acceleration: drive.value, brakingForce: 0, SteeringAngle: turningSlider.value)
    }
    
    @objc func snapTurnBack(turn: UISlider) {
        if (turn.isTracking == false) {
            turn.value = 0
        }
        Player.drive(acceleration: driveSlider.value, brakingForce: 0, SteeringAngle: turn.value)
    }
    
    @IBAction func lightloc(_ sender: Any) {
        updateLightPos(origin: sceneOrigin, lightHeightValue: lightHeight.value, lightAngleValue: lightAngle.value, maxRadius: lightHeight.maximumValue)
    }
    
    /**
    Handles the exit action from the AR screen.

    This function suspends the AR session, removes all nodes from the scene, and sets the view state to not running.

    */
    @IBAction func exitScreen() {
        suspendARPlaneDetection()
        Game = .notRunning
        sceneView.session.pause()

        // Remove all nodes and geometries from the scene
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            for child in node.childNodes {
                child.removeFromParentNode()
                child.geometry = nil
            }
                node.removeFromParentNode()
            node.geometry = nil
            }
        sceneView.session.pause()
        sceneView = nil
    }
    
    func suspendARPlaneDetection() {
      // 1
      let config = sceneView.session.configuration as!
        ARWorldTrackingConfiguration
    // 2
      config.planeDetection = []
    // 3
      sceneView.session.run(config)
    }
}



extension gameViewController: ARSCNViewDelegate {    
    /**
    Sets the intensity of the lighting of the scene according to the device's environment
    This will make virtual objects blend better into the real environment

    */
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
            DispatchQueue.main.async {
                if self.Game != .notRunning {
                    if self.Game == .clickPlay {
                        updateFocusSquare(sceneView: self.sceneView)
                    }
                
                    guard let lightEstimate = self.sceneView.session.currentFrame?.lightEstimate else { return }

                    let ambientLightEstimate = lightEstimate.ambientIntensity

                    let ambientColourTemperature = lightEstimate.ambientColorTemperature

                    if ambientLightEstimate < 100 { }
                
                    directionalLightNode.light?.intensity = ambientLightEstimate
                    directionalLightNode.light?.temperature = ambientColourTemperature
                }
        }
    }

    /**
    If AR plane anchors are found it will allow the player to start to interact with the AR scene

    */
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if Game == .findSurface {
            if anchor is ARPlaneAnchor {
                Game = .clickPlay
            }
        }
    }

    /**
    If the game is being played. Run the followWayPoints follow function to allow the AI to complete the race

    */
    func renderer(_ renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {
        if self.Game == .playinGame {
            followWayPoints()
        }
    }
}

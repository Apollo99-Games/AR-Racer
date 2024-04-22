//
//  carViewController.swift
//  FinalARCar
//
//  Created by Student on 6/6/22.
//

import UIKit
import ARKit

/**
Handles the car showcase scene. Where players can see a large model of their car, rotate it, and change its colour
*/
class carViewController: UIViewController {
    

    @IBOutlet weak var sceneView: ARSCNView!
    
    @IBOutlet weak var colourImage: UIImageView!
    
    @IBOutlet weak var colourLine: UISlider!
    
    @IBOutlet weak var customizeButton: UIButton!
    
    
    
    @IBOutlet weak var lightHeight: UISlider!
    @IBOutlet weak var lightAngle: UISlider!
    @IBOutlet weak var lightButton: UIButton!
    
    var isLightShow = false
    var isColourShow = true
    
    var viewCar: GameState = .findSurface
    var sceneOrigin: SCNVector3!
    weak var carNode: SCNNode!
    var swipeLocStart: CGPoint!
    var swipeLocEnd: CGPoint!
    var groundNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpFocus()
        setUpControls()
        showLightPos(show: false)
        viewCar = .findSurface
        addTapGestureToSceneView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
//        configuration.worldAlignment = .gravity
        configuration.environmentTexturing = .automatic
        configuration.isLightEstimationEnabled = true
        sceneView.preferredFramesPerSecond = 60
//        sceneView.showsStatistics = true
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
    
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
        
        let swipeRightGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(rightSwip))
    swipeRightGestureRecognizer.direction = .right
        sceneView.addGestureRecognizer(swipeRightGestureRecognizer)
        
        let swipeLeftGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(leftSwip))
    swipeLeftGestureRecognizer.direction = .left
        sceneView.addGestureRecognizer(swipeLeftGestureRecognizer)
    }
    
    /**
    Handles the tap gesture recognizer.

    - Parameter recognizer: The tap gesture recognizer.
    */
    @objc func tapped(withGestureRecognizer recognizer: UIGestureRecognizer) {
        guard let sceneView = recognizer.view as? ARSCNView else {return}
        
        if viewCar == .clickPlay {
            // Set the scene origin and adjust lighting
            sceneOrigin = focusNode.position
            directionalLightNode.simdLook(at: simd_float3(sceneOrigin))
            isLightShow = false
            showLights()
            sceneView.scene.rootNode.addChildNode(addLight())
            sceneView.scene.rootNode.addChildNode(addLightShower())
            updateLightPos(origin: sceneOrigin, lightHeightValue: 1, lightAngleValue: 180, maxRadius: 1)
            
            // Load the car model and add it to the scene
            guard let carScene = SCNScene(named: "Assets.scnassets/mclarenQuality.scn") else {return}
            carNode = carScene.rootNode.childNode(withName: "Car", recursively: true)
            sceneView.scene.rootNode.addChildNode(carNode)
            carNode.position = sceneOrigin
            
            addShadowCatcher()
            
            // Update viewCar state and enable UI elements
            viewCar = .playinGame
            focusNode.isHidden = true
            lightButton.isEnabled = true
            customizeButton.isEnabled = true
            suspendARPlaneDetection() // to save performance
        }
    }
    
    /**
    Handles the right swipe gesture recognizer.
    Rotates the car to the right

    - Parameter recognizer: The right swipe gesture recognizer.
    */
    @objc func rightSwip(withGestureRecognizer recognizer: UIGestureRecognizer) {
        if viewCar == .playinGame {
            let rotate = SCNAction.rotate(by: CGFloat(GLKMathDegreesToRadians(60)), around: SCNVector3(x: 0, y: 1, z: 0), duration: 0.2)
            carNode.runAction(rotate)
        }
    }
    
    /**
    Handles the left swipe gesture recognizer.
    Rotates the car to the left

    - Parameter recognizer: The left swipe gesture recognizer.
    */
    @objc func leftSwip(withGestureRecognizer recognizer: UIGestureRecognizer) {
        if viewCar == .playinGame {
            let rotate = SCNAction.rotate(by: CGFloat(GLKMathDegreesToRadians(-60)), around: SCNVector3(x: 0, y: 1, z: 0), duration: 0.2)
            carNode.runAction(rotate)
        }
    }
    
    func setUpFocus() {
        sceneView.scene.rootNode.addChildNode(newFocusSquare())
    }
    
    /**
    Adds a shadow catcher to the scene.

    This function creates a ground plane that only receives shadows from other objects in the scene.

    */
    func addShadowCatcher() {
        let groundGeometry = SCNFloor()
        groundGeometry.reflectivity = 0.0
        let groundMaterial = SCNMaterial()
        groundMaterial.lightingModel = .shadowOnly
        groundGeometry.materials = [groundMaterial]
        groundNode.geometry = groundGeometry
        groundNode.position = sceneOrigin
        sceneView.scene.rootNode.addChildNode(groundNode)
    }
    
    func setUpControls() {
        colourLine.isEnabled = false
        colourLine.isHidden = true
        colourImage.isHidden = true
        customizeButton.isEnabled = false
        
        lightButton.isEnabled = false
        lightHeight.maximumValue = 1
        lightHeight.transform = CGAffineTransform(rotationAngle: 300)
    }
    
    /**
    Handles the change event of the color slider.

    This function updates the color of the car based on the value of the color slider.

    */
    @IBAction func colourSliderChanged() {
        colourLine.value = roundf(colourLine.value)
        carColour = colourArray[Int(colourLine.value)]
        print(Int(colourLine.value))
        carNode.childNode(withName: "Body", recursively: true)?.geometry?.material(named: "McLaren")?.diffuse.contents = carColour
    }
    
    @IBAction func customizeButtonPressed() {
        if isColourShow == true {
            colourLine.isHidden = false
            colourLine.isEnabled = true
            colourImage.isHidden = false
            isColourShow = false
        }
        else {
            colourLine.isHidden = true
            colourLine.isEnabled = false
            colourImage.isHidden = true
            isColourShow = true
        }
    }
    
    @IBAction func showLights() {
        if isLightShow == true {
            lightPlaceShower.isHidden = false
            showLightPos(show: true)
            isLightShow = false
            lightButton.setTitle("✔︎", for: .normal)
            lightButton.setTitle("✔︎", for: .highlighted)
            lightButton.titleLabel?.font = UIFont.systemFont(ofSize: 51)
        }
        else {
            lightPlaceShower.isHidden = true
            showLightPos(show: false)
            isLightShow = true
            lightButton.titleLabel?.font = UIFont.systemFont(ofSize: 51)
            lightButton.setTitle("☀️", for: .normal)
            lightButton.setTitle("☀️", for: .highlighted)
        }
    }
    
    @IBAction func lightloc(_ sender: Any) {
        updateLightPos(origin: sceneOrigin, lightHeightValue: lightHeight.value, lightAngleValue: lightAngle.value, maxRadius: lightHeight.maximumValue)
    }
    
    /**
    Handles the reset button action.

    This function resets the AR session, removes the car and ground nodes from the scene, 
    disables UI elements, and resets the state of the view.

    */
    @IBAction func resetButton() {
        let config = sceneView.session.configuration as!
        ARWorldTrackingConfiguration
        config.planeDetection = .horizontal
        sceneView.session.pause()

        carNode.removeFromParentNode()
        groundNode.removeFromParentNode()

        lightButton.isEnabled = false
        isLightShow = true
        showLights()

        isColourShow = false
        customizeButtonPressed()
        
        customizeButton.isEnabled = false
        sceneView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
        focusNode.isHidden = false
        viewCar = .findSurface
    }
    
    /**
    Handles the exit action from the AR screen.

    This function suspends the AR session, removes all nodes from the scene, and sets the view state to not running.

    */
    @IBAction func exitScreen() {
        suspendARPlaneDetection()
        viewCar = .notRunning
        print("closed")
        sceneView.session.pause()

        // Remove all nodes and geometries from the scene
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            for child in node.childNodes {
                child.geometry = nil
                child.removeFromParentNode()
            }
            node.geometry = nil
            node.removeFromParentNode()
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
    
    func showLightPos(show: Bool) {
        if show == true {
            lightAngle.isEnabled = true
            lightHeight.isEnabled = true
            lightAngle.isHidden = false
            lightHeight.isHidden = false
        } else {
            lightAngle.isEnabled = false
            lightHeight.isEnabled = false
            lightAngle.isHidden = true
            lightHeight.isHidden = true
        }
    }
}

extension carViewController: ARSCNViewDelegate {
    /**
    Sets the intensity of the lighting of the scene according to the device's environment
    This will make virtual objects blend better into the real environment

    */
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
            DispatchQueue.main.async {
                if self.viewCar != .notRunning {
                    if self.viewCar == .clickPlay {
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
        if viewCar == .findSurface {
            if anchor is ARPlaneAnchor {
                viewCar = .clickPlay
            }
        }
    }
}

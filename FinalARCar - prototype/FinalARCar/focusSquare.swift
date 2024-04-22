//
//  focusSquare.swift
//  FinalARCar
//
//  Created by Student on 5/17/22.
//
import Foundation
import SceneKit
import ARKit

var focusNode: SCNNode!

/**
 Creates a new focus square node.

 This function loads a focus square scene from the assets and retrieves the focus node from it. The focus node is initially hidden and returned.

 - Returns: A new focus square node.
 */   
func newFocusSquare() -> SCNNode {
    let focusScene = SCNScene(named: "Assets.scnassets/Focus.scn")!
    focusNode = focusScene.rootNode.childNode(withName: "Focus", recursively: false)
    focusNode.isHidden = true
    return focusNode
}

/**
 Creates a new focus square node.

 This function calculates the width and length of the focus square based on the maximum and minimum coordinates of detected planes. 
 It then creates a box geometry with transparency and returns a new focus node with the geometry.

 - Returns: A new focus square node.
 */
func newDynamicnewFocusSquare() -> SCNNode {
    
    let width = ((maxMinX.y + ((maxMinX.x + 1) - maxMinX.y))*40)/100
    let length = ((maxMinY.y + ((maxMinY.x + 1) - maxMinY.y))*40)/100
    
    let focusGeometry = SCNBox(width: width, height: 0.05, length: length, chamferRadius: 0)
    
    let focusMaterial = SCNMaterial()
    focusMaterial.transparency = 0.5
    
    focusGeometry.materials = [focusMaterial]
    
    focusNode = SCNNode(geometry: focusGeometry)
    
    return focusNode
}

/**
 Updates the position of the focus square based on the AR scene view.

 This function makes the focus square visible, 
 performs a raycast query from the center of the scene view to detect existing plane geometries, 
 and updates the position of the focus square based on the hit test result.

 - Parameters:
    - sceneView: The AR scene view.

 */
func updateFocusSquare(sceneView: ARSCNView) {
        
    focusNode.isHidden = false
    let point = CGPoint(x: sceneView.center.x, y: sceneView.center.y + sceneView.center.y * 0.25)
        
    let hitResults = sceneView.raycastQuery(from: point, allowing: .existingPlaneGeometry, alignment: .horizontal)
        
    let results: [ARRaycastResult] = sceneView.session.raycast(hitResults!)

    guard let hitTest = results.first else {return}
            
    let holder = SCNVector3(hitTest.worldTransform.columns.3.x, hitTest.worldTransform.columns.3.y, hitTest.worldTransform.columns.3.z)
        
    focusNode.position = holder
}


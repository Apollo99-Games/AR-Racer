//
//  light.swift
//  FinalARCar
//
//  Created by Student on 5/17/22.
//

import Foundation
import SceneKit

let directionalLightNode = SCNNode()
var lightPlaceShower = SCNNode()

/**
  Adds a directional light to the scene.

 - Returns: A SCNNode representing the directional light.

 */
func addLight() -> SCNNode {
    // 1
    let directionalLight = SCNLight()
    directionalLight.type = .directional
    // 3
    directionalLight.castsShadow = true
    
    directionalLight.shadowMode = .forward
    directionalLight.shadowBias = 5
    directionalLight.shadowColor = CGColor(red: 1, green: 1, blue: 1, alpha: 0.65)
    // 5
    directionalLight.shadowSampleCount = 9

    directionalLightNode.light = directionalLight
    
    return directionalLightNode
}

/**
 Adds a sphere that will follow the main light to show the user where the directional light is pointing at

 - Returns: A SCNNode representing the light shower.

 */
func addLightShower() -> SCNNode {
    lightPlaceShower.geometry = SCNSphere(radius: 0.05)
    lightPlaceShower.geometry?.firstMaterial?.lightingModel = SCNMaterial.LightingModel.constant
    lightPlaceShower.castsShadow = false
    
    return lightPlaceShower
}

/**
 Updates the position of the directional light and light shower effect.

 This function calculates and sets the position of the directional light and light shower effect based on the specified parameters, 
 such as the origin point, light height, light angle, and maximum radius.

 - Parameters:
    - origin: The origin point of the light.
    - lightHeightValue: The height of the light.
    - lightAngleValue: The angle of the light.
    - maxRadius: The maximum radius of the light.

 */
func updateLightPos(origin: SCNVector3, lightHeightValue: Float, lightAngleValue: Float, maxRadius: Float) {
    
    let raduis = Float(sqrt(Double(pow(maxRadius, 2) - pow(lightHeightValue, 2))))
    
    var z: Float = 0
    var x: Float = 0
    
    var angle = GLKMathDegreesToRadians(lightAngleValue)
    
    // Determine the x and z coordinates based on the light's angle
    if lightAngleValue <= 90 {
        z = sin(angle)*raduis
        x = cos(angle)*raduis
    } else if lightAngleValue <= 180 {
        angle = GLKMathDegreesToRadians(90 - (lightAngleValue - 90))
        z = sin(angle)*raduis
        x = cos(angle)*raduis * -1
    } else if lightAngleValue <= 270 {
        angle = GLKMathDegreesToRadians(lightAngleValue - 180)
        z = sin(angle)*raduis * -1
        x = cos(angle)*raduis * -1
    } else if lightAngleValue <= 360 {
        angle = GLKMathDegreesToRadians(90 - (lightAngleValue - 270))
        z = sin(angle)*raduis * -1
        x = cos(angle)*raduis
    }

    directionalLightNode.position.x = origin.x + x
    directionalLightNode.position.y = origin.y + lightHeightValue
    directionalLightNode.position.z = origin.z + z
    
    directionalLightNode.simdLook(at: simd_float3(origin))
    
    lightPlaceShower.position = directionalLightNode.position
}



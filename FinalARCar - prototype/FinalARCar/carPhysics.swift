//
//  carPhysics.swift
//  FinalARCar
//
//  Created by Student on 5/10/22.
//

import Foundation
import SceneKit

var carColour = UIColor(red: 255/255, green: 120/255, blue: 3/255, alpha: 1)

var AIphysicsVehicle: SCNPhysicsVehicle!
weak var AICar: SCNNode!

weak var carAIAngle: SCNNode!
weak var nextPoint: SCNNode!

var wayPointNum: Int!

var groundNode: SCNNode!

/**
 A class representing a car in the scene.

 The class holding the car's visual model, physics properties, and driving behavior.
 */

class Car {
    
    weak var carNode: SCNNode!

    weak var wheelFLNode: SCNNode!
    weak var wheelFRNode: SCNNode!
    weak var wheelRLNode: SCNNode!
    weak var wheelRRNode: SCNNode!

    var physicsVehicle: SCNPhysicsVehicle!
    
    /**
     Retrieves the visual model of the car.

     - Returns: The SCNNode representing the car's visual model.
     */
    func getCarModel() -> SCNNode {

        guard let carScene = SCNScene(named: "Assets.scnassets/mclaren.scn") else {return carNode}
        
        carNode = carScene.rootNode.childNode(withName: "Body", recursively: true)
        carNode.geometry?.material(named: "McLaren")?.diffuse.contents = carColour

        wheelFLNode = carScene.rootNode.childNode(withName: "Wheel_FL", recursively: true)
        wheelFRNode = carScene.rootNode.childNode(withName: "Wheel_FR", recursively: true)
        wheelRLNode = carScene.rootNode.childNode(withName: "Wheel_BL", recursively: true)
        wheelRRNode = carScene.rootNode.childNode(withName: "Wheel_BR", recursively: true)
        
        carAIAngle = carScene.rootNode.childNode(withName: "carRotation", recursively: true)
        nextPoint = carScene.rootNode.childNode(withName: "nextPoint", recursively: true)
        
        
        
        carNode.addChildNode(wheelFLNode!)
        carNode.addChildNode(wheelFRNode!)
        carNode.addChildNode(wheelRLNode!)
        carNode.addChildNode(wheelRRNode!)
        
        return carNode
    }
    
    /**
     Creates a physics vehicle wheel with specified properties.

     - Parameter wheelNode: The node representing the wheel.
     - Returns: An SCNPhysicsVehicleWheel object.
     */
    func createPhysicsVehicleWheel(wheelNode: SCNNode) -> SCNPhysicsVehicleWheel {
        let wheel = SCNPhysicsVehicleWheel(node: wheelNode)
        wheel.suspensionStiffness = 1.0
        wheel.maximumSuspensionTravel = 0
        wheel.suspensionRestLength = 0
        wheel.maximumSuspensionForce = 75
        wheel.suspensionDamping = 1.0
        wheel.radius = 0.019/2
        wheel.frictionSlip = 0.7
        wheel.suspensionCompression = 3.0
        return wheel
    }   

    /**
     Creates a physics vehicle for the car with its wheels.

     - Returns: An SCNPhysicsVehicle object.
     */
    func createVehiclePhysics() -> SCNPhysicsVehicle{
        if physicsVehicle != nil {
            physicsVehicle = nil
        }
        let wheelFL = createPhysicsVehicleWheel(
          wheelNode: wheelFLNode!)
        let wheelFR = createPhysicsVehicleWheel(
          wheelNode: wheelFRNode!)
        let wheelRL = createPhysicsVehicleWheel(
          wheelNode: wheelRLNode!)
        let wheelRR = createPhysicsVehicleWheel(
          wheelNode: wheelRRNode!)

      physicsVehicle = SCNPhysicsVehicle(
        chassisBody: carNode.physicsBody!,
        wheels: [wheelFL, wheelFR, wheelRL, wheelRR])
      return physicsVehicle
    }
    
    /**
     Drives the car with specified inputs.

     - Parameters:
        - acceleration: The acceleration force applied to the car.
        - brakingForce: The braking force applied to the car.
        - steeringAngle: The steering angle of the car.
     */
    func drive(acceleration: Float, brakingForce: CGFloat, SteeringAngle: Float) {
        
        physicsVehicle.setSteeringAngle(CGFloat(GLKMathDegreesToRadians(SteeringAngle * -1)), forWheelAt: 0)
        physicsVehicle.setSteeringAngle(CGFloat(GLKMathDegreesToRadians(SteeringAngle * -1)), forWheelAt: 1)

        physicsVehicle.applyEngineForce(CGFloat(acceleration), forWheelAt: 0)
        physicsVehicle.applyEngineForce(CGFloat(acceleration), forWheelAt: 1)
        physicsVehicle.applyBrakingForce(0, forWheelAt: 0)
        physicsVehicle.applyBrakingForce(0, forWheelAt: 1)
    }
    
    /**
     Updates the positions of the car and ground nodes.

     - Parameter point: The position vector for the car node.
     */
    func updatePositions(point: SCNVector3) {

        self.carNode.position = carPos
        self.carNode.position.y += 0.05
        self.carNode.rotation = SCNVector4(0, 1, 0, GLKMathDegreesToRadians(carAngle + 90))
        if carAngle == 0 || carAngle == 270 {
            self.carNode.position.z -= 0.04
        } else {
            self.carNode.position.x -= 0.04
        }
        self.carNode.physicsBody?.velocity = SCNVector3Zero
        self.carNode.physicsBody?.angularVelocity = SCNVector4Zero
        self.carNode.physicsBody?.resetTransform()
      
        groundNode.position = point
        groundNode.physicsBody?.rollingFriction = 0
        groundNode.physicsBody?.resetTransform()
    }
}

/**
 Creates an AI-controlled car based on the player's car and wheels.

 - Parameters:
    - playerCar: The player's car node.
    - playerWheels: An array of the player's wheel nodes.
 - Returns: An SCNNode representing the AI-controlled car.
 */
func createAICar(playerCar: SCNNode, playerWheels: [SCNNode]) -> SCNNode {
    AICar = playerCar.clone()
    
    var playerWheelList = [SCNPhysicsVehicleWheel]()
    for car in playerWheels {
        let wheel = car.clone()
        AICar.addChildNode(wheel)
        playerWheelList.append(createAIVehicleWheel(
            wheelNode: wheel))
    }
    
    AIphysicsVehicle = SCNPhysicsVehicle(
      chassisBody: AICar.physicsBody!,
      wheels: playerWheelList)
    return AICar
}

/**
 Updates the starting position of the AI-controlled car.

 This function resets the AI car's position, rotation, and physics properties to prepare it for a new race.
 */
func updateAIStartingPos() {
    wayPointNum = 1
    AICar.position = carPos
    AICar.position.y += 0.05
    AICar.rotation = SCNVector4(0, 1, 0, GLKMathDegreesToRadians(carAngle + 90))
    AICar.position.x += 0.05
    AICar.physicsBody?.velocity = SCNVector3Zero
    AICar.physicsBody?.angularVelocity = SCNVector4Zero
    AICar.physicsBody?.resetTransform()
}

/**
 Controls the AI car's behavior to follow waypoints.

 The function calculates the direction towards the next waypoint and adjusts the AI car's steering and acceleration accordingly.
 */
func followWayPoints() {

    if wayPointNum > wayPoints.count - 1 {
        wayPointNum = 0
    }
    
    // Calculate distances between current position and next waypoint
    let distanceX = Float(wayPoints[wayPointNum].x) - AICar.presentation.position.x
    let distanceY = Float(wayPoints[wayPointNum].y) - AICar.presentation.position.z
    
    // Set positions of visualization nodes for dedugging
    carAIAngle.position = AICar.presentation.position
    nextPoint.position = AICar.presentation.position
    
    // Move to the next waypoint if the AI car is close enough to the current one
    if distanceX > -0.08 && distanceX < 0.08 && distanceY < 0.08 && distanceY > -0.08 {
        wayPointNum += 1
    }
    
    let normal = normalize(SIMD2(x: distanceX, y: distanceY))

    // get currnet car rotation
    var carRotation = GLKMathRadiansToDegrees(AICar.presentation.rotation.y * AICar.presentation.rotation.w)
    
    // ensure rotation is not negative
    if carRotation < 0 {
        carRotation = 360 + carRotation
    }
    
    // find the angle to the waypoint
    var angleToTarget = GLKMathRadiansToDegrees(atan2(normal.y, normal.x))
    // ensure angle is not negative
    if angleToTarget < 0 {
        angleToTarget = 360 + angleToTarget
    }

    // The angles in the 3D scene differ from the angles reported from the calculations
    // So, we must convert them before applying them 
    if angleToTarget == 0 {
        angleToTarget = 90
    } else if angleToTarget < 90 && angleToTarget > 0 {
        angleToTarget = 90 - angleToTarget
    } else if angleToTarget == 90 {
        angleToTarget = 0
    } else if angleToTarget > 90 && angleToTarget < 180 {
        angleToTarget = 360 - (angleToTarget - 90)
    } else if angleToTarget == 180 {
        angleToTarget = 270
    } else if angleToTarget > 180 && angleToTarget < 270 {
        angleToTarget = 270 - (angleToTarget - 180)
    } else if angleToTarget == 270 {
        angleToTarget = 180
    } else if angleToTarget > 270 {
        angleToTarget = 180 - (angleToTarget - 270)
    }
    
    
    nextPoint.rotation = SCNVector4(0, 1, 0, GLKMathDegreesToRadians(angleToTarget))
    
    // Calculate steering direction based on car and target angles
    var absolute = 180 - abs(abs(angleToTarget - carRotation) - 180)
    var direction = absolute + carRotation
    
    if direction >= 360 {
        direction -= 360
    }
    
    if roundf(direction) != roundf(angleToTarget) {
        absolute *= -1
    }
    
    carAIAngle.rotation = SCNVector4(0, 1, 0, GLKMathDegreesToRadians(carRotation))

    // Limit steering angle within [-35, 35] degrees
    if absolute > 35 {
        absolute = 35
    } else if absolute < -35 {
        absolute = -35
    }
    
    // Adjust engine force based on distance to waypoint to stop the car from going too fast
    if distanceX > -0.2 && distanceX < 0.2 && distanceY < 0.2 && distanceY > -0.2 {
        if wayPointNum != 0 {
            AIphysicsVehicle.applyEngineForce(0.2, forWheelAt: 0)
            AIphysicsVehicle.applyEngineForce(0.2, forWheelAt: 1)
        }
    } else {
        AIphysicsVehicle.applyEngineForce(1, forWheelAt: 0)
        AIphysicsVehicle.applyEngineForce(1, forWheelAt: 1)
    }

    absolute = GLKMathDegreesToRadians(absolute)
    
    AIphysicsVehicle.setSteeringAngle(CGFloat(absolute), forWheelAt: 0)
    AIphysicsVehicle.setSteeringAngle(CGFloat(absolute), forWheelAt: 1)
}

/**
 Creates an AI-controlled vehicle wheel with specified properties.

 - Parameter wheelNode: The node representing the wheel.
 - Returns: An SCNPhysicsVehicleWheel object.
 */
func createAIVehicleWheel(wheelNode: SCNNode) -> SCNPhysicsVehicleWheel {
    let wheel = SCNPhysicsVehicleWheel(node: wheelNode)
  wheel.maximumSuspensionTravel = 0
  wheel.suspensionRestLength = 0
  wheel.maximumSuspensionForce = 100
  wheel.suspensionCompression = 4.0
  wheel.suspensionDamping = 2.0
  wheel.suspensionStiffness = 2.0
  wheel.radius = 0.019/2
  wheel.frictionSlip = 0.7
  return wheel
}

/**
 Creates a ground node for the scene.

 This function creates a flat ground surface with physics properties.

 - Returns: An SCNNode representing the ground.
 */
func createGroundNode() -> SCNNode {
  let groundGeometry = SCNFloor()
  groundGeometry.reflectivity = 0.0
  let groundMaterial = SCNMaterial()
  groundMaterial.lightingModel = .shadowOnly
  groundGeometry.materials = [groundMaterial]
  groundNode = SCNNode(geometry: groundGeometry)
  groundNode.position = SCNVector3Zero
  groundNode.isHidden = false
  groundNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
  groundNode.physicsBody?.rollingFriction = 4
  groundNode.physicsBody?.restitution = 0
  groundNode.physicsBody?.friction = 4
  return groundNode
}

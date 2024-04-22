//
//  buildTrack.swift
//  FinalARCar
//
//  Created by Student on 6/10/22.
//

import Foundation
import UIKit
import SceneKit

var curveFrontConnectionPoint = [Bool]()

var wayPoints = [CGPoint]()

var straightWall: SCNNode!
var straightTrack: SCNNode!

var curveWall: SCNNode!
var curveTrack: SCNNode!

var startWall: SCNNode!
var startTrack: SCNNode!

var carPos: SCNVector3!
var carAngle: Float = 0



/**
 Adds track elements to an ARKit scene based on the provided focus position.

 - Parameters:
    - focusPos: The position in the ARKit scene where the tracks will be added.
 - Returns: An array of SCNNode objects representing the track elements added to the scene.
 */
func addTracksToARkit(focusPos: SCNVector3) -> [SCNNode] {
    
    var wallHolder = SCNNode()
    var trackHolder = SCNNode()
    
    var isTrackSraightTrack = false
    
    var trackHolderList = [SCNNode]()
    
    // Clear previous waypoints
    wayPoints.removeAll()
    
    if raceTrack.first == raceTrack.last {
        raceTrack.removeLast()
    }
    
    // Counter for the number of loops (for curved tracks)
    var numOfCurve = 0
    
    for track in raceTrack {

        // Determine the type of track based on its position
        // Then clone the SCNNode of the track that is to be placed in the scene
        if trackList[Int(track.y)][Int(track.x)].name == "straightTrack" {
            wallHolder = straightWall.clone()
            trackHolder = straightTrack.clone()
        } else if trackList[Int(track.y)][Int(track.x)].name == "curveTrack" {
            wallHolder = curveWall.clone()
            trackHolder = curveTrack.clone()
        } else if trackList[Int(track.y)][Int(track.x)].name == "startTrack" {
            wallHolder = startWall.clone()
            trackHolder = startTrack.clone()
            isTrackSraightTrack = true
        }
        
        // Calculate the position of the track elements relative to the focus position
        let x = focusPos.x + (((Float((track.x - findOrigin().x)) + 0.5)*40)/100)
        let z = focusPos.z + (((Float((track.y - findOrigin().y)) + 0.5)*40)/100)
        
        // Set the position
        wallHolder.position = SCNVector3(x, focusPos.y + 0.001, z)
        trackHolder.position = SCNVector3(x, focusPos.y + 0.001, z)
        
        // Set the rotation (note it's a bit different from the UI, so we have to compensate for that)
        var rotation = trackList[Int(track.y)][Int(track.x)].trackFrontAngle
        
        if rotation == 90 {
            rotation = 270
        } else if rotation == 270 {
            rotation = 90
        }
        
        wallHolder.eulerAngles = SCNVector3(0, GLKMathDegreesToRadians(Float(rotation)), 0)
        trackHolder.eulerAngles = wallHolder.eulerAngles
        
        // Create WayPoints for the AI to follow depending on the track type
        if isTrackSraightTrack == true {
            carPos = trackHolder.position
            carAngle = Float(rotation)
            isTrackSraightTrack =  false
            
            createWayPoints(trackMiddle: trackHolder.position, track: trackList[Int(track.y)][Int(track.x)])
        }
        if trackList[Int(track.y)][Int(track.x)].name == "curveTrack" {
            createWayPoints(trackMiddle: trackHolder.position, track: trackList[Int(track.y)][Int(track.x)], numOfCurve: numOfCurve)
            numOfCurve += 1
        }
        
        trackHolderList.append(wallHolder)
        trackHolderList.append(trackHolder)
    }
    print(wayPoints)
    return trackHolderList
}

/**
 Loads track elements from the Assets file and assigns them to global variables
 */
func createTracks() {
    guard let trackScene = SCNScene(named: "Assets.scnassets/track.scn") else {return}
    
    straightWall = trackScene.rootNode.childNode(withName: "straightWall", recursively: true)
    straightTrack = trackScene.rootNode.childNode(withName: "straightTrack", recursively: true)
    
    curveWall = trackScene.rootNode.childNode(withName: "curveWall", recursively: true)
    curveTrack = trackScene.rootNode.childNode(withName: "curveTrack", recursively: true)
    
    startWall = trackScene.rootNode.childNode(withName: "startWall", recursively: true)
    startTrack = trackScene.rootNode.childNode(withName: "startTrack", recursively: true)
}

/**
 Creates waypoints based on the track middle position and type of track.

 - Parameters:
    - trackMiddle: The middle position of the track where waypoints are generated.
    - track: The type of track.
    - numOfCurve: The number of curve (default is 0).
 */
func createWayPoints(trackMiddle: SCNVector3, track: Track, numOfCurve: Int = 0) {

    // If it's the start track, add a waypoint at the track middle
    if track.name == "startTrack" {
        wayPoints.append(CGPoint(x: CGFloat(trackMiddle.x), y: CGFloat(trackMiddle.z)))
    }
    // If it's a curve track, calculate waypoint positions 
    else if track.name == "curveTrack" {
        
        // curve tracks have two way points as theey will have a different direction of entry and exit
        var turnWayPoint = CGPoint(x: 0, y: 0)
        var turnWayPoint2 = CGPoint(x: 0, y: 0)
        
        var rotation = 0
        var rotation2 = 0
        
        rotation = track.trackBackAngle
        rotation2 = track.trackFrontAngle
        
        turnWayPoint = angleToPoint(trackRotation: rotation, trackMiddle: trackMiddle)
        turnWayPoint2 = angleToPoint(trackRotation: rotation2, trackMiddle: trackMiddle)
        
        var isturnWayPoint = false
        var isturnWayPoint2 = false

        // Check if waypoint positions already exist
        for point in wayPoints {
            if point == turnWayPoint {
                isturnWayPoint = true
            }
            if point == turnWayPoint2 {
                isturnWayPoint2 = true
            }
        }

        // Add waypoint positions if they don't already exist
        if isturnWayPoint == false {
            wayPoints.append(turnWayPoint)
        }
        if isturnWayPoint2 == false {
            wayPoints.append(turnWayPoint2)
        }

    }
}

/**
 Converts a track rotation angle to a waypoint position relative to the track middle.

 - Parameters:
    - trackRotation: The rotation angle of the track.
    - trackMiddle: The middle position of the track.
 - Returns: A CGPoint representing the waypoint position.
 */
func angleToPoint(trackRotation: Int, trackMiddle: SCNVector3) -> CGPoint {
    
    var rotation = trackRotation
    
    var turnWayPoint = CGPoint(x: 0, y: 0)
    
    // Compensate for the different angles between the UI and the 3D game engine
    if rotation == 90 {
        rotation = 270
    } else if rotation == 270 {
        rotation = 90
    }
    
    // Determine waypoint position based on rotation angle
    if rotation == 0 {
        turnWayPoint.x = CGFloat(trackMiddle.x + 0.2)
        turnWayPoint.y = CGFloat(trackMiddle.z)
    } else if rotation == 90 {
        turnWayPoint.x = CGFloat(trackMiddle.x)
        turnWayPoint.y = CGFloat(trackMiddle.z - 0.2)
    } else if rotation == 180 {
        turnWayPoint.x = CGFloat(trackMiddle.x - 0.2)
        turnWayPoint.y = CGFloat(trackMiddle.z)
    } else if rotation == 270 {
        turnWayPoint.x = CGFloat(trackMiddle.x)
        turnWayPoint.y = CGFloat(trackMiddle.z + 0.2)
    }
    
    return turnWayPoint
}



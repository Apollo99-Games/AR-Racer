//
//  saveTrack.swift
//  tracktest
//
//  Created by Student on 6/9/22.
//

import Foundation
import UIKit

var raceTrack = [CGPoint]()

var maxMinX = startingPoint
var maxMinY = startingPoint

var direction = CGPoint(x: 0, y: 0)

/**
 * Checks if the track is complete (makes a complete loop) by traversing it from the starting point.
 *
 * - Returns: A boolean value indicating whether the track is valid or not.
 */
func checkTrack() -> Bool {
    var counter = 1
    
    // Remove any existing entries in the race track

    raceTrack.removeAll()
    
    // Determine the initial direction based on the starting point
    direction = getDirection(previous: trackList[Int(startingPoint.y)][Int(startingPoint.x)], current: trackList[Int(startingPoint.y)][Int(startingPoint.x)])
    
    var previous = startingPoint
    var current = startingPoint

    // Add the starting point to the race track
    raceTrack.append(current)
    // Calculate the next point based on the initial direction
    var next = CGPoint(x: direction.x + startingPoint.x , y: direction.y + startingPoint.y)
     // Check if the current and next track pieces are connected
    if checkConnected(current: trackList[Int(current.y)][Int(current.x)], next: trackList[Int(next.y)][Int(next.x)]) {} else {return false}
    
    current = next
    
    raceTrack.append(current)
    
    //used to find the boundaries of the track to center it
    findHightestAndLowest(currentPoint: current)
    
    counter += 1
    
    // Loop until we reach back to the starting tack (which means track should be valid)
    // gets the next direction, then the next point, ensures the track is connected, and adds it to the race track list
    while trackList[Int(current.y)][Int(current.x)].name != "startTrack" {


        if trackList[Int(current.y)][Int(current.x)].name == "curveTrack" {
            direction = getDirection(previous: trackList[Int(previous.y)][Int(previous.x)], current: trackList[Int(current.y)][Int(current.x)])
        } 
        
        next = CGPoint(x: direction.x + current.x , y: direction.y + current.y)
        
        if checkConnected(current: trackList[Int(current.y)][Int(current.x)], next: trackList[Int(next.y)][Int(next.x)]) {} else {return false}
        
//        if (trackList[Int(current.y)][Int(current.x)].name == "straightTrack") && trackList[Int(next.y)][Int(next.x)].name == "curveTrack"{
//            curveFrontConnectionPoint.append(isFrontCurveConnectedForStraightGoingIn(current: trackList[Int(current.y)][Int(current.x)], next: trackList[Int(next.y)][Int(next.x)]))
//        }
        
        previous = current
        
        current = next
        
        raceTrack.append(current)
        
        findHightestAndLowest(currentPoint: current)
        
        counter += 1
    }

    return true
}

/**
 * Determines the direction based on the previous and current track pieces.
 *
 * - Parameters:
 *    - previous: The previous track piece.
 *    - current: The current track piece.
 * - Returns: A CGPoint representing the direction vector.
 */
func getDirection(previous: Track, current: Track) -> CGPoint {
    
    var angle = current.trackFrontAngle
    
    if (previous.name == "startTrack" || previous.name == "straightTrack" || previous.name == "curveTrack") && current.name == "curveTrack" {
        curveFrontConnectionPoint.append(isFrontCurveConnectedForStraightGoingIn(current: previous, next: current))
        if isFrontCurveConnectedForStraightGoingIn(current: previous, next: current) {
            angle = current.trackBackAngle
        }
    }
    else if previous.name == "curveTrack" && (current.name == "startTrack" || current.name == "straightTrack") {
        if isFrontCurveConnectedForGoingOutToStraight(current: previous, next: current) {
            
            curveFrontConnectionPoint.append(isFrontCurveConnectedForStraightGoingIn(current: previous, next: current))
            angle = current.trackBackAngle
        }
    }
    
    var direc = CGPoint(x: 0, y: 0)
    
    // Determine the direction based on the angle
    if angle == 0 {
        direc = CGPoint(x: 1, y: 0)
    }
    else if angle == 90 {
        direc = CGPoint(x: 0, y: 1)
    }
    else if angle == 180 {
        direc = CGPoint(x: -1, y: 0)
    }
    else if angle == 270 {
        direc = CGPoint(x: 0, y: -1)
    }
    
    return direc
}

/**
 * Checks if two track pieces are connected based on their types and angles.
 *
 * - Parameters:
 *    - current: The current track piece.
 *    - next: The next track piece.
 * - Returns: A boolean value indicating whether the track pieces are connected.
 */
func checkConnected(current: Track, next: Track) -> Bool {
    
    if (current.name == "startTrack" || current.name == "straightTrack") && (next.name == "startTrack" || next.name == "straightTrack") {
        if current.trackFrontAngle == next.trackFrontAngle {
            return true
        }
        else if current.trackFrontAngle == (next.trackBackAngle) {
            return true
        }
    } else if (current.name == "startTrack") && next.name == "curveTrack" {
        if (current.trackBackAngle ) == next.trackBackAngle {
            return true
        }
        else if (current.trackBackAngle) == next.trackFrontAngle {
            return true
        }
    }
    else if (current.name == "straightTrack" || current.name == "curveTrack") && next.name == "curveTrack" {
        if direction.x == 1 {
            if next.trackBackAngle == 180 || next.trackFrontAngle == 180 {
                return true
            }
        } else if direction.x == -1 {
            if next.trackBackAngle == 0 || next.trackFrontAngle == 0 {
                return true
            }
        } else if direction.y == 1 {
            if next.trackBackAngle == 270 || next.trackFrontAngle == 270 {
                return true
            }
        } else if direction.y == -1 {
            if next.trackBackAngle == 90 || next.trackFrontAngle == 90 {
                return true
            }
        }
    }
    else if (current.name == "curveTrack") && (next.name == "straightTrack" || next.name == "startTrack") {
        if direction.x == 1 {
            if next.trackBackAngle == 0 || next.trackFrontAngle == 0 {
                return true
            }
        } else if direction.x == -1 {
            if next.trackBackAngle == 180 || next.trackFrontAngle == 180 {
                return true
            }
        } else if direction.y == 1 {
            if next.trackBackAngle == 90 || next.trackFrontAngle == 90 {
                return true
            }
        } else if direction.y == -1 {
            if next.trackBackAngle == 270 || next.trackFrontAngle == 270 {
                return true
            }
        }
    }
    return false
}

/**
 * Checks if the current track (a curve) is connected to the next track
 *
 * - Parameters:
 *    - current: The current curve track piece.
 *    - next: The next track piece.
 * - Returns: A boolean value indicating whether the front curve is connected.
 */
func isFrontCurveConnectedForStraightGoingIn(current: Track, next: Track) -> Bool {
    if direction.x == 1 {
        if next.trackBackAngle == 180 {
            return false
        }
        if next.trackFrontAngle == 180 {
            return true
        }
    }
    else if direction.x == -1 {
        if next.trackBackAngle == 0 {
            return false
        }
        if next.trackFrontAngle == 0 {
            return true
        }
    } else if direction.y == 1 {
        if next.trackBackAngle == 270  {
            return false
        }
        if next.trackFrontAngle == 270 {
            return true
        }
    } else if direction.y == -1 {
        if next.trackBackAngle == 90 {
            return false
        }
        if next.trackFrontAngle == 90 {
            return true
        }
    }
    return false
}

/**
 * Checks if the current track is connected to the next track (which has to be a curve)
 *
 * - Parameters:
 *    - current: The current track piece.
 *    - next: The next curve track piece.
 * - Returns: A boolean value indicating whether the front curve is connected.
 */
func isFrontCurveConnectedForGoingOutToStraight(current: Track, next: Track) -> Bool {
    if direction.x == 1 {
        if next.trackBackAngle == 0 {
            return false
        }
        if next.trackFrontAngle == 0 {
            return true
        }
    }
    else if direction.x == -1 {
        if next.trackBackAngle == 180 {
            return false
        }
        if next.trackFrontAngle == 180 {
            return true
        }
    } else if direction.y == 1 {
        if next.trackBackAngle == 90  {
            return false
        }
        if next.trackFrontAngle == 90 {
            return true
        }
    } else if direction.y == -1 {
        if next.trackBackAngle == 270 {
            return false
        }
        if next.trackFrontAngle == 270 {
            return true
        }
    }
    return false
}

/**
 * Updates the highest and lowest points based on the current point.
 *
 * - Parameter currentPoint: The current point to be compared.
 */
func findHightestAndLowest(currentPoint: CGPoint) {
    if currentPoint.x > maxMinX.x {
        maxMinX.x = currentPoint.x
    }
    else if currentPoint.x < maxMinX.y {
        maxMinX.y = currentPoint.x
    }
    if currentPoint.y > maxMinY.x {
        maxMinY.x = currentPoint.y
    }
    else if currentPoint.y < maxMinY.y {
        maxMinY.y = currentPoint.y
    }
}

/**
 * Calculates the origin point based on the maximum and minimum x and y coordinates determined by the findHightestAndLowest() function.
 *
 * - Returns: A CGPoint representing the calculated origin point.
 */
func findOrigin()  ->  CGPoint {
    return CGPoint(x: (maxMinX.y + ((maxMinX.x + 1) - maxMinX.y)/2), y: maxMinY.y + (((maxMinY.x + 1) - maxMinY.y)/2))
}



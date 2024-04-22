//
//  track.swift
//  tracktest
//
//  Created by Student on 6/8/22.
//

import Foundation
import UIKit
import GLKit

/**
 * A struct representing a track piece.
 */
struct Track {
    
    var track = UIImageView()
    var trackFrontAngle = 0
    var trackBackAngle = 180
    var name = ""
    
    /**
     * Initializes a track piece with default values and sets up its UIImageView.
     */
    init() {
        let image = UIImage(named: "straight")
        let resizedImage = image?.resized(to: CGSize(width: 40, height: 40))
        self.track.contentMode = UIView.ContentMode.scaleAspectFill
        self.track.frame.size.width = 40
        self.track.frame.size.height = 40
        self.track.image = resizedImage
        self.track.isUserInteractionEnabled = true
        self.track.isHidden = true
    }
    
    /**
     * Rotates the track piece by 90 degrees
     */
    mutating func updateAngle() {
        self.trackFrontAngle += 90
        if self.trackFrontAngle > 270 {
            self.trackFrontAngle = 0
        }
        
        if self.name == "curveTrack" {
            self.trackBackAngle = self.trackFrontAngle + 90
            if self.trackBackAngle > 270 {
                self.trackBackAngle = 0
            }
        } else if self.name == "straightTrack" || self.name == "startTrack" {
            self.trackBackAngle += 90
            if self.trackBackAngle > 270 {
                self.trackBackAngle = 0
            }
        }
        track.transform = CGAffineTransform(rotationAngle: CGFloat(GLKMathDegreesToRadians(Float(trackFrontAngle))))
        
    }
    
    /**
     * Removes the track piece from the view and resets its properties.
     */
    mutating func remove() {
        self.trackFrontAngle = 0
        self.trackBackAngle = 180
        self.name = ""
        self.track.isHidden = true
        track.transform = CGAffineTransform(rotationAngle: CGFloat(GLKMathDegreesToRadians(Float(0))))
    }
    
    mutating func setToStraight() {
        let stright = UIImage(named: "straight")
        let resizedImage = stright?.resized(to: CGSize(width: 40, height: 40))
        track.image = nil
        track.image = resizedImage
        self.name = "straightTrack"
        self.trackFrontAngle = 0
        self.trackBackAngle = 180
        self.track.isHidden = false
    }

    mutating func setToCurve() {
        let curve = UIImage(named: "curve")
        let resizedImage = curve?.resized(to: CGSize(width: 40, height: 40))
        track.image = nil
        track.image = resizedImage
        self.name = "curveTrack"
        self.trackFrontAngle = 0
        self.trackBackAngle = 90
        self.track.isHidden = false
    }
    
    mutating func setToStarterTrack() {
        let starting = UIImage(named: "start")
        let resizedImage = starting?.resized(to: CGSize(width: 40, height: 40))
        track.image = nil
        track.image = resizedImage
        self.name = "startTrack"
        self.trackFrontAngle = 0
        self.trackBackAngle = 180
        self.track.isHidden = false
    }
}

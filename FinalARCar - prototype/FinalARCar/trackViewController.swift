//
//  trackViewController.swift
//  FinalARCar
//
//  Created by Student on 6/7/22.
//trackViewController

import UIKit
import GLKit

var trackList = [[Track]](repeating: [Track](repeating: Track(), count: 10), count: 10)

var startingPoint = CGPoint(x: 5, y: 5)

/**
    Handles the track building scene. Where the player can build their own customized tracks
*/
class trackViewController: UIViewController {
    
    
    @IBOutlet var mainView: UIView!
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet weak var cordPlain: UIImageView!
    
    @IBOutlet weak var sceneView: UIView!
    
    @IBOutlet weak var straightTrackButton: UIImageView!
    
    @IBOutlet weak var curveTrackButton: UIImageView!
    
    @IBOutlet weak var reset: UIButton!
    
    @IBOutlet weak var save: UIButton!      
    
    @IBOutlet weak var backButton: UIButton!
    
    
    
    var trackHolder:Track = Track()
    
    var starterTrack:Track = Track()
    
    var List = [[String]](repeating: [String](repeating: "", count: 10), count: 10)
    
    let offSet = CGPoint(x: 222, y: -5)
    
    var isDragging = false
    var newStraightTrack = false
    var newCurveTrack = false
    
    var trackX = 0
    var trackY = 0
    var starter = CGPoint(x: 0, y: 0)
    var ending = CGPoint(x: 0, y: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton.isEnabled = false
        setUpScrollView()

        trackHolder.track.isHidden = true
        starterTrack.setToStarterTrack()
        starterTrack.track.setOrigin(to: snapPoint(cord: CGPoint(x: 222 + 200, y: 200 - 5), OffSet: offSet))
        trackList[5][5] = starterTrack

        sceneView.addSubview(starterTrack.track)
        sceneView.addSubview(trackHolder.track)
        scrollView.zoomScale = 4
        scrollView.isUserInteractionEnabled = true
        
        let addRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.addNewTrack))
        mainView.addGestureRecognizer(addRecognizer)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.removeTrack))
        mainView.addGestureRecognizer(longPressRecognizer)
        
        let dragRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.drag))
        scrollView.addGestureRecognizer(dragRecognizer)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tap))
        scrollView.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
            
    }
    
    /**
    * Removes a track piece from the grid based on a gesture recognizer.
    *
    * - Parameter recognizer: The gesture recognizer that triggers the removal action.
    */
    @objc func removeTrack(withGestureRecognizer recognizer: UIGestureRecognizer) {
        let location = recognizer.location(in: sceneView)
        let round = snapPoint(cord: location, OffSet: offSet, adjust: false)
        
            let x = Int((round.x)/40)
            let y = Int((round.y)/40)
        if x >= 0 && x <= 9 && y >= 0 && y <= 9 {} else { return }
            if trackList[y][x].name != "" && trackList[y][x].name != "startTrack" {
                trackList[y][x].remove()
            }
    }
    
    /**
    * Rotates the tapped track by 90 degrees
    *
    * - Parameter recognizer: The gesture recognizer that triggers the action.
    */
    @objc func tap(withGestureRecognizer recognizer: UIGestureRecognizer) {
        let location = recognizer.location(in: sceneView)
        let round = snapPoint(cord: location, OffSet: offSet, adjust: false)
        
            let x = Int((round.x)/40)
            let y = Int((round.y)/40)

        if x >= 0 && x <= 9 && y >= 0 && y <= 9 {} else { return }
            if trackList[y][x].name != "" {
                trackList[y][x].updateAngle()
            }
    }
    
    /**
    * Allows the track piece to be dragged around the scene
    *
    * - Parameter recognizer: The gesture recognizer that triggers the action.
    */
    @objc func drag(withGestureRecognizer recognizer: UIGestureRecognizer) {
        if recognizer.state == .began {
             // Get the location of the gesture in the scene view
            let location = recognizer.location(in: sceneView)
            
            // Snap the location to the nearest grid point 
            let round = snapPoint(cord: location, OffSet: offSet, adjust: false)
 
            trackX = Int((round.x)/40)
            trackY = Int((round.y)/40)
        
            if trackX >= 0 && trackX <= 9 && trackY >= 0 && trackY <= 9 {} else { return }
                // If there is a track at the beginning state of the drag, allow it to be interacted with
                if trackList[trackY][trackX].name != "" {
                    isDragging = true
                    trackList[trackY][trackX].track.isUserInteractionEnabled = true
                    starter = trackList[trackY][trackX].track.getOrigin()
                    scrollView.isUserInteractionEnabled = false
                    newStraightTrack = false
                }
        }
        
        // during the drag keep setting the track's position to the drag
        if recognizer.state == .changed {
            let location = recognizer.location(in: sceneView)

            ending = location
            if isDragging {
                trackList[trackY][trackX].track.setOrigin(to: location)
                ending = location
            }
        }
        
        // when the dragf has finished set the current grid to the track at the beginning of the drag
        if recognizer.state == .ended {
            scrollView.isUserInteractionEnabled = true
            
            let originHolder = starter
            
            let location = recognizer.location(in: sceneView)
            let round = snapPoint(cord: location, OffSet: offSet, adjust: false)

            
            let x = Int((round.x)/40)
            let y = Int((round.y)/40)
            
            if isDragging {

                trackList[trackY][trackX].track.setOrigin(to: snapPoint(cord: originHolder, OffSet: offSet))
                if x >= 0 && x <= 9 && y >= 0 && y <= 9 {} else { return }
                    // If the target grid cell is empty
                    if trackList[y][x].name == "" {
                        // set the empty grids data to the target track
                        // clear the original grid
                        var holder = trackList[x][y]
                        holder.track = trackList[x][y].track.copyView()

                        trackList[y][x].track.image = nil
                        trackList[y][x] = trackList[trackY][trackX]
                        trackList[y][x].track = trackList[trackY][trackX].track.copyView()
                        sceneView.addSubview(trackList[y][x].track)
                        trackList[y][x].name = trackList[trackY][trackX].name

                        trackList[y][x].track.setOrigin(to: snapPoint(cord: location, OffSet: offSet))


                        trackList[trackY][trackX].track.image = nil
                        trackList[trackY][trackX] = holder
                        trackList[trackY][trackX].track = holder.track.copyView()
                        trackList[trackY][trackX].name = ""
                        
                        if trackList[y][x].name == "startTrack" {
                            startingPoint = CGPoint(x: x, y: y)
                        }
                    }
            }
            isDragging = false
        }
    }
    
    /**
    * Handles the addition of a new track piece based on the gesture recognizer's state.
    *
    * - Parameter recognizer: The gesture recognizer for tracking the addition action.
    */
    @objc func addNewTrack(withGestureRecognizer recognizer: UIGestureRecognizer) {

        
        if recognizer.state == .began {
            // Get the location of the gesture in the buttons
            let straightLocation = recognizer.location(in: straightTrackButton)
            let curveLocation = recognizer.location(in: curveTrackButton)
            
             // Check if the gesture is inside the straight track button
            if straightTrackButton.bounds.contains(straightLocation) {
                newStraightTrack = true
                trackHolder.track.isHidden = true
                isDragging = false
                newCurveTrack = false
                scrollView.isUserInteractionEnabled = false
            }
            // Check if the gesture is inside the curve track button 
            else if curveTrackButton.bounds.contains(curveLocation) {
                newStraightTrack = false
                trackHolder.track.isHidden = true
                isDragging = false
                newCurveTrack = true
                scrollView.isUserInteractionEnabled = false
            }
        }

        // While the addition is ongoing
        // Get the location of the gesture
        // set the trackHolder (the track you see being dragged across the screen) to it's according track type 
        if recognizer.state == .changed {
            let location = recognizer.location(in: sceneView)
            if newStraightTrack {
                trackHolder.setToStraight()
                trackHolder.track.setOrigin(to: location)
                trackHolder.track.isHidden = false
            } else if newCurveTrack {
                trackHolder.setToCurve()
                trackHolder.track.setOrigin(to: location)
                trackHolder.track.isHidden = false
            }
            
        }


        if recognizer.state == .ended {
            scrollView.isUserInteractionEnabled = true
            if newStraightTrack || newCurveTrack {
                
                trackHolder.track.setOrigin(to: snapPoint(cord: trackHolder.track.getOrigin(), OffSet: offSet))
                
                let originHolder = trackHolder.track.getOrigin()
                let x = Int(snapPoint(cord: originHolder, OffSet: offSet, adjust: false).x/40)
                let y = Int(snapPoint(cord: originHolder, OffSet: offSet, adjust: false).y/40)

                trackHolder.track.isHidden = true

                if x >= 0 && x <= 9 && y >= 0 && y <= 9 {} else { return }

                if trackList[y][x].name != "startTrack" {} else {return}

                // Remove any existing track image from the target cell
                trackList[y][x].track.image = nil

                // Copy the track holder view to the target cell and set it as straight or curve track
                trackList[y][x].track = trackHolder.track.copyView()
                if newStraightTrack {
                    trackList[y][x].setToStraight()
                } else if newCurveTrack {
                    trackList[y][x].setToCurve()
                }

                sceneView.addSubview(trackList[y][x].track)

                 // Hide the track holder and reset flags
                trackHolder.track.layer.name = "holder"
                trackHolder.track.isHidden = true
                
                newStraightTrack = false
                newCurveTrack = false
            }
        }
    }
    
    /**
    * Snaps a point to the nearest grid point with optional offset and adjustment.
    *
    * - Parameters:
    *     - cord: The point to be snapped to the grid.
    *     - OffSet: The offset to be applied to the snapped point (default is CGPoint(x: 0, y: 0)).
    *     - adjust: A flag indicating whether to adjust the snapped point (default is true).
    * - Returns: The snapped point.
    */
    func snapPoint(cord: CGPoint, OffSet: CGPoint = CGPoint(x: 0, y: 0), adjust: Bool = true) -> CGPoint {

        var subCord = CGPoint(x: 0, y: 0)
        var origin = cord

        origin.x -= OffSet.x
        origin.y -= OffSet.y
        
        var finalPoint = CGPoint(x: 0, y: 0)
        
        // Limit x-coordinate to grid bounds
        if origin.x > 380 {
            origin.x = 380
        } else if origin.x < 20 {
            origin.x = 20
        }

        // Limit y-coordinate to grid bounds
        if origin.y > 380 {
            origin.y = 380
        } else if origin.y < 20 {
            origin.x = 20
        }
        
        // If adjustment is disabled, set subCord to OffSet
        if adjust == false {
            subCord = OffSet
        }
        
        // Snap x-coordinate to the nearest grid point
        let set = roundf(Float(origin.x - 20)/40) * 40
        finalPoint.x = CGFloat(set + 20) + OffSet.x - subCord.x
        
        // Snap y-coordinate to the nearest grid point
        let set2 = roundf(Float(origin.y - 20)/40) * 40
        finalPoint.y = CGFloat(set2 + 20) + OffSet.y + subCord.y
        
        return finalPoint
    }
    
    /**
    * Resets all track pieces to their initial state and positions.
    */
    @IBAction func resetTracks() {

        // Remove all track pieces
        for y in 0...9 {
            for x in 0...9 {
                trackList[y][x].remove()
            }
        }

        scrollView.isUserInteractionEnabled = true
        trackHolder.track.isHidden = true

        // Set starter track to its initial state and position
        starterTrack.setToStarterTrack()
        starterTrack.track.setOrigin(to: snapPoint(cord: CGPoint(x: 222 + 200, y: 200 - 5), OffSet: offSet))

        trackList[5][5] = starterTrack
        startingPoint = CGPoint(x: 5, y: 5)        
    }
    
    /**
    * Saves the current track configuration if it's complete, otherwise shows an alert.
    */
    @IBAction func saveTrack() {
        if checkTrack() ==  false {
            let alertController = UIAlertController(title: "Track is Incomplete", message: "A peice may be missing, placed or rotated the wrong way", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        } else {
            backButton.isEnabled = true
            let alertController = UIAlertController(title: "Track Saved!", message: "You can go back and use it!", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func setUpScrollView() {
        scrollView.delegate = self
    }
}

extension trackViewController {}

extension trackViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return sceneView
    }
}



extension UIImage {

    /**
    * Resizes the UIImage to the specified CGSize.
    *
    * - Parameter size: The target size for the resized image.
    * - Returns: The resized UIImage.
    */
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

extension UIImageView {

    /**
    * Sets the origin of the view to the specified point.
    *
    * - Parameter size: The new origin point for the view.
    */
    func setOrigin(to size: CGPoint) {
        self.frame.origin.x = size.x - self.frame.size.width/2
        self.frame.origin.y = size.y - self.frame.size.height/2
    }

    /**
    * Retrieves the origin point of the view.
    *
    * - Returns: The origin point of the view.
    */
    func getOrigin() -> CGPoint{
        var origin = CGPoint(x: 0, y: 0)
        origin.x = self.frame.origin.x + self.frame.size.width/2
        origin.y = self.self.frame.origin.y + self.frame.size.height/2
        return origin
    }

    /**
    * Creates a copy of the view.
    *
    * - Returns: A copied instance of the view.
    */
    func copyView<T: UIView>() -> T {
        return NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self)) as! T
    }
}

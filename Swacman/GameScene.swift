//
//  GameScene.swift
//  Swacman
//
//  Created by Chris Nevin on 21/06/2015.
//  Copyright (c) 2015 CJNevin. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
	enum Direction {
		case Left
		case Right
		case Up
		case Down
	}
	class Swacman {
		lazy var openDirectionPaths = [Direction: UIBezierPath]()
		lazy var closedDirectionPaths = [Direction: UIBezierPath]()
		lazy var wasClosedPath = false
		lazy var needsToUpdateDirection = false
		lazy var direction = Direction.Right
		lazy var lastChange: NSTimeInterval = NSDate().timeIntervalSince1970
		let sprite = SKShapeNode(circleOfRadius: 15)
		init(_ position: CGPoint) {
			let radius: CGFloat = 15, diameter: CGFloat = 30, center = CGPoint(x:radius, y:radius)
			func createPaths(startDegrees: CGFloat, endDegrees: CGFloat, inout dictionary dic: [Direction: UIBezierPath]) {
				var path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startDegrees.toRadians(), endAngle: endDegrees.toRadians(), clockwise: true)
				path.addLineToPoint(center)
				path.closePath()
				dic[.Right] = path
				for d: Direction in [.Up, .Left, .Down] {
					path = path.pathByRotating(90)
					dic[d] = path
				}
			}
			createPaths(35, endDegrees: 315, dictionary: &openDirectionPaths)
			createPaths(1, endDegrees: 359, dictionary: &closedDirectionPaths)
			sprite.position = position
			sprite.fillColor = UIColor.yellowColor()
			sprite.lineWidth = 2
			if let path = openDirectionPaths[.Right] {
				sprite.path = path.CGPath
			}
			sprite.strokeColor = UIColor.blackColor()
			updateDirection()
		}
		
		func animateChomp() {
			if needsToUpdateDirection || NSDate().timeIntervalSince1970 - lastChange > 0.25 {
				if let path = wasClosedPath ? openDirectionPaths[direction]?.CGPath : closedDirectionPaths[direction]?.CGPath {
					sprite.path = path
				}
				wasClosedPath = !wasClosedPath
				lastChange = NSDate().timeIntervalSince1970
			}
		}
		
		func handleSwipe(from touchStartPoint: CGPoint, to touchEndPoint: CGPoint) {
			if touchStartPoint == touchEndPoint {
				return
			}
			let degrees = atan2(touchStartPoint.x - touchEndPoint.x,
				touchStartPoint.y - touchEndPoint.y).toDegrees()
			let oldDirection = direction
			switch Int(degrees) {
			case -135...(-45):	direction = .Right
			case -45...45:		direction = .Down
			case 45...135:		direction = .Left
			default:			direction = .Up
			}
			if (oldDirection != direction) {
				needsToUpdateDirection = true
			}
		}
		
		func updateDirection() {
			if !needsToUpdateDirection {
				return
			}
			sprite.removeActionForKey("Move")
			func actionForDirection() -> SKAction {
				let Delta: CGFloat = 25
				switch (direction) {
				case .Up:
					return SKAction.moveByX(0.0, y: Delta, duration: 0.1)
				case .Down:
					return SKAction.moveByX(0.0, y: -Delta, duration: 0.1)
				case .Right:
					return SKAction.moveByX(Delta, y: 0.0, duration: 0.1)
				default:
					return SKAction.moveByX(-Delta, y: 0.0, duration: 0.1)
				}
			}
			let action = SKAction.repeatActionForever(actionForDirection())
			sprite.runAction(action, withKey: "Move")
			needsToUpdateDirection = false
		}
	}
	
	var touchBeganPoint: CGPoint?
	var swacman: Swacman?
	
    override func didMoveToView(view: SKView) {
		let swac = Swacman(CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)))
		self.addChild(swac.sprite)
		swacman = swac
    }
	
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		touchBeganPoint = positionOfTouch(inTouches: touches)
	}
	
	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		if let touchStartPoint = touchBeganPoint, touchEndPoint = positionOfTouch(inTouches: touches), swac = swacman {
			if touchStartPoint == touchEndPoint {
				return
			}
			swac.handleSwipe(from: touchStartPoint, to: touchEndPoint)
			touchBeganPoint = nil
		}
	}
	
	override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
		touchBeganPoint = nil
	}
   
    override func update(currentTime: CFTimeInterval) {
        if let nodes = self.children as? [SKShapeNode], swac = swacman {
			for node in nodes {
				let p = node.position
				let s = node.frame.size
				if p.x - s.width > self.size.width {
					node.position.x = -s.width
				}
				if p.y - s.height > self.size.height {
					node.position.y = -s.height
				}
				if p.x < -s.width {
					node.position.x = self.size.width + (s.width / 2)
				}
				if p.y < -s.height {
					node.position.y = self.size.height + (s.height / 2)
				}
				if node == swac.sprite {
					swac.animateChomp()
					swac.updateDirection()
				}
			}
		}
    }
	
	// MARK:- Helpers
	
	func positionOfTouch(inTouches touches: Set<NSObject>) -> CGPoint? {
		for touch in (touches as! Set<UITouch>) {
			let location = touch.locationInNode(self)
			return location
		}
		return nil
	}
}

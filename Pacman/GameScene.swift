//
//  GameScene.swift
//  Pacman
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
	lazy var openDirectionPaths = [Direction: UIBezierPath]()
	lazy var closedDirectionPaths = [Direction: UIBezierPath]()
	lazy var wasClosedPath = false
	lazy var needsToUpdateDirection = false
	lazy var direction = Direction.Right
	lazy var lastChange: NSTimeInterval = NSDate().timeIntervalSince1970
	
	var touchBeganPoint: CGPoint?
	let pacmanSprite = SKShapeNode(circleOfRadius: 15)
	
    override func didMoveToView(view: SKView) {
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
		createPaths(35, 315, dictionary: &openDirectionPaths)
		createPaths(1, 359, dictionary: &closedDirectionPaths)
		pacmanSprite.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
		pacmanSprite.fillColor = UIColor.yellowColor()
		pacmanSprite.lineWidth = 2
		if let path = openDirectionPaths[.Right] {
			pacmanSprite.path = path.CGPath
		}
		pacmanSprite.strokeColor = UIColor.blackColor()
		self.addChild(pacmanSprite)
		updateDirection()
    }
	
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
		touchBeganPoint = positionOfTouch(inTouches: touches)
    }
	
	override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
		if let touchStartPoint = touchBeganPoint,
			touchEndPoint = positionOfTouch(inTouches: touches) {
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
	}
	
	override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
		touchBeganPoint = nil
	}
   
    override func update(currentTime: CFTimeInterval) {
        if let nodes = self.children as? [SKShapeNode] {
			for node in nodes {
				let p = node.position
				let s = node.frame.size
				//let s = node.size
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
				if needsToUpdateDirection || NSDate().timeIntervalSince1970 - lastChange > 0.25 {
					if let path = wasClosedPath ? openDirectionPaths[direction]?.CGPath : closedDirectionPaths[direction]?.CGPath {
						node.path = path
					}
					wasClosedPath = !wasClosedPath
					lastChange = NSDate().timeIntervalSince1970
				}
				updateDirection()
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
	
	func updateDirection() {
		if !needsToUpdateDirection {
			return
		}
		pacmanSprite.removeActionForKey("Move")
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
		pacmanSprite.runAction(action, withKey: "Move")
		needsToUpdateDirection = false
	}
}

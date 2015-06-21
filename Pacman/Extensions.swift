//
//  Extensions.swift
//  Pacman
//
//  Created by Chris Nevin on 21/06/2015.
//  Copyright (c) 2015 CJNevin. All rights reserved.
//

import SpriteKit

extension CGFloat {
	func toDegrees() -> CGFloat {
		return self * CGFloat(180) / CGFloat(M_PI)
	}
	func toRadians() -> CGFloat {
		return self * CGFloat(M_PI) / CGFloat(180)
	}
}

extension UIBezierPath {
	func pathByRotating(degrees: CGFloat) -> UIBezierPath {
		var radians = degrees.toRadians()
		var bounds = CGPathGetBoundingBox(self.CGPath)
		var center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds))
		var transform = CGAffineTransformIdentity
		transform = CGAffineTransformTranslate(transform, center.x, center.y)
		transform = CGAffineTransformRotate(transform, radians)
		transform = CGAffineTransformTranslate(transform, -center.x, -center.y)
		return UIBezierPath(CGPath:CGPathCreateCopyByTransformingPath(self.CGPath, &transform))
	}
}

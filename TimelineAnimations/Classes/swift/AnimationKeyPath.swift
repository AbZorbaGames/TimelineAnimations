//
//  TimelineAnimationKeyPathExtensions.swift
//  TimelineAnimations
//
//  Created by Georges Boumis on 11/01/2017.
//  Copyright © 2017 AbZorba Games. All rights reserved.
//

import Foundation

public enum AnimationKeyPath: String {
    // CALayer
    case position = "position" // CGPoint
    case positionX = "position.x" // CGFloat
    case positionY = "position.y" // CGFloat
    case zPosition = "zPosition" // CGFloat
    case anchorPoint = "anchorPoint" // CGPoint
    case anchorPointZ = "anchorPointZ" // CGPoint
    case bounds = "bounds" // CGRect
    case boundsSize = "bounds.size" // CGSize
    case width = "bounds.size.width" // CGFloat
    case height = "bounds.size.height" // CGFloat
    case frame = "frame" // CGRect
    case frameSize = "frame.size" // CGSize

    case transform = "transform" // CATransform3D
    case sublayerTransform = "sublayerTransform" // CATransform3D

    case rotation = "transform.rotation" // CGFloat in radians
    case rotationY = "transform.rotation.y" // CGFloat in radians

    case scale = "transform.scale" // CGFloat
    case scaleX = "transform.scale.x" // CGFloat
    case scaleY = "transform.scale.y" // CGFloat

    case opacity = "opacity" // CGFloat

    case shadowOpacity = "shadowOpacity" // CGFloat
    case shadowRadius = "shadowRadius" // CGFloat
    case shadowOffset = "shadowOffset" // CGSize
    case shadowColor = "shadowColor" // CGColor
    case shadowPath = "shadowPath" // CGPath

    case contents = "contents" // Any
    case contentsRect = "contentsRect" // CGRect
    case contentsCenter = "contentsCenter" // CGRect
    case masksToBounds = "masksToBounds" // Bool
    case isDoubleSided = "doubleSided" // Bool
    case cornerRadius = "cornerRadius" // CGFloat
    case borderWidth = "borderWidth" // CGFloat
    case borderColor = "borderColor" // CGColor
    case isHidden = "hidden" // Bool
    case backgroundColor = "backgroundColor" // CGColor

    case filters = "filters" // [CIFilter]
    case compositingFilter = "compositingFilter" // CIFilter
    case backgroundFilters = "backgroundFilters" // [CIFilter]

    case shouldRasterize = "shouldRasterize" // Bool

    // CAEmitterLayer
    case emitterPosition = "emitterPosition" // CGPoint
    case emitterZposition = "emitterZPosition" // CGFloat
    case emitterSize = "emitterSize" // CGSize
    case spin = "spin" // Float
    case velocity = "velocity" // Float
    case birthRate = "birthRate" // Float
    case lifetime = "lifetime" // Float

    // CAShapeLayer properties
    case fillColor = "fillColor" // CGColor
    case strokeColor = "strokeColor" // CGColor
    case lineDashPhase = "lineDashPhase" // CGFloat
    case lineWidth = "lineWidth" // CGFloat
    case misterLimit = "misterLimit" // CGFloat
    case strokeEnd = "strokeEnd" // CGFloat
    case strokeStart = "strokeStart" // CGFloat
    case path = "path" // CGPath

    // CATextLayer properties
    case fontSize = "fontSize" // CGFloat
    case foregroundColor = "foregroundColor" // CGColor
}


public extension AnimationsFactory {

    final public class func animate(keyPath: AnimationKeyPath,
                                    toValue: AnimationsFactory.TypedValue?,
                                    duration: TimeInterval = TimeInterval(1.0),
                                    timingFunction tf: ECustomTimingFunction = ECustomTimingFunction.linear) -> CABasicAnimation {
        return self.animate(keyPath: keyPath,
                            fromValue: nil,
                            toValue: toValue,
                            duration: duration,
                            timingFunction: tf)
    }

    final public class func animate(keyPath: AnimationKeyPath,
                                    fromValue: AnimationsFactory.TypedValue?,
                                    duration: TimeInterval = TimeInterval(1.0),
                                    timingFunction tf: ECustomTimingFunction = ECustomTimingFunction.linear) -> CABasicAnimation {
        return self.animate(keyPath: keyPath,
                            fromValue: fromValue,
                            toValue: nil,
                            duration: duration,
                            timingFunction: tf)
    }
}

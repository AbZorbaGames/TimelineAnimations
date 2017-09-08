//
//  AnimationsFactoryConvenienceExtensions.swift
//  TimelineAnimations
//
//  Created by Georges Boumis on 26/09/2016.
//  Copyright © 2016-2017 AbZorba Games. All rights reserved.
//

import Foundation
import QuartzCore

//MARK: Move shortcuts

public extension AnimationsFactory {

    final public class func move(fromPoint from: CGPoint?,
                                 toPoint to: CGPoint?,
                                 duration: TimeInterval = TimeInterval(1.0),
                                 timingFunction tf: ECustomTimingFunction = ECustomTimingFunction.linear) -> CABasicAnimation {
        return self.animate(keyPath: AnimationKeyPath.position,
                            fromValue: from?.asTypedValue,
                            toValue: to?.asTypedValue,
                            duration: duration,
                            timingFunction: tf)
    }

    final public class func move(toPoint to: CGPoint,
                                 duration: TimeInterval = TimeInterval(1.0),
                                 timingFunction tf: ECustomTimingFunction = ECustomTimingFunction.linear) -> CABasicAnimation {
        return self.move(fromPoint: nil,
                         toPoint: to,
                         duration: duration,
                         timingFunction: tf)
    }

    final public class func move(fromPoint from: CGPoint,
                                 duration: TimeInterval = TimeInterval(1.0),
                                 timingFunction tf: ECustomTimingFunction = ECustomTimingFunction.linear) -> CABasicAnimation {
        return self.move(fromPoint: from,
                         toPoint: nil,
                         duration: duration,
                         timingFunction: tf)
    }


}

//MARK: Scale shortcuts

public extension AnimationsFactory {
    final public class func scale(withDuration duration: TimeInterval = TimeInterval(1.0),
                                  from: CGFloat?,
                                  to: CGFloat?,
                                  timingFunction tf: ECustomTimingFunction = ECustomTimingFunction.linear) -> CABasicAnimation {
        return self.animate(keyPath: AnimationKeyPath.scale,
                            fromValue: from?.asTypedValue,
                            toValue: to?.asTypedValue,
                            duration: duration,
                            timingFunction: tf)

    }
    
    @objc final public class func objc_scale(withDuration duration: TimeInterval = TimeInterval(1.0),
                                  from: CGFloat,
                                  to: CGFloat,
                                  timingFunction tf: ECustomTimingFunction = ECustomTimingFunction.linear) -> CABasicAnimation {
        return self.animate(keyPath: AnimationKeyPath.scale,
                            fromValue: from.asTypedValue,
                            toValue: to.asTypedValue,
                            duration: duration,
                            timingFunction: tf)
    }

    final public class func scaleX(withDuration duration: TimeInterval = TimeInterval(1.0),
                                   from: CGFloat?,
                                   to: CGFloat?,
                                   timingFunction tf: ECustomTimingFunction = ECustomTimingFunction.linear) -> CABasicAnimation {
        
        return self.animate(keyPath: AnimationKeyPath.scaleX,
                            fromValue: from?.asTypedValue,
                            toValue: to?.asTypedValue,
                            duration: duration,
                            timingFunction: tf)

    }

    final public class func scaleY(withDuration duration: TimeInterval = TimeInterval(1.0),
                                   from: CGFloat?,
                                   to: CGFloat?,
                                   timingFunction tf: ECustomTimingFunction = ECustomTimingFunction.linear) -> CABasicAnimation {
        return self.animate(keyPath: AnimationKeyPath.scaleY,
                            fromValue: from?.asTypedValue,
                            toValue: to?.asTypedValue,
                            duration: duration,
                            timingFunction: tf)

    }

    final public class func scale(withDuration duration: TimeInterval = TimeInterval(1.0),
                                  from: CGFloat,
                                  timingFunction tf: ECustomTimingFunction = ECustomTimingFunction.linear) -> CABasicAnimation {
        return self.animate(keyPath: AnimationKeyPath.scale,
                            fromValue: from.asTypedValue,
                            toValue: nil,
                            duration: duration,
                            timingFunction: tf)

    }

    final public class func scaleX(withDuration duration: TimeInterval = TimeInterval(1.0),
                                   from: CGFloat,
                                   timingFunction tf: ECustomTimingFunction = ECustomTimingFunction.linear) -> CABasicAnimation {
        return self.animate(keyPath: AnimationKeyPath.scaleX,
                            fromValue: from.asTypedValue,
                            toValue: nil,
                            duration: duration,
                            timingFunction: tf)

    }

    final public class func scaleY(withDuration duration: TimeInterval = TimeInterval(1.0),
                                   from: CGFloat,
                                   timingFunction tf: ECustomTimingFunction = ECustomTimingFunction.linear) -> CABasicAnimation {
        return self.animate(keyPath: AnimationKeyPath.scaleY,
                            fromValue: from.asTypedValue,
                            toValue: nil,
                            duration: duration,
                            timingFunction: tf)

    }

    final public class func scale(withDuration duration: TimeInterval = TimeInterval(1.0),
                                  to: CGFloat,
                                  timingFunction tf: ECustomTimingFunction = ECustomTimingFunction.linear) -> CABasicAnimation {
        return self.animate(keyPath: AnimationKeyPath.scale,
                            fromValue: nil,
                            toValue: to.asTypedValue,
                            duration: duration,
                            timingFunction: tf)

    }

    final public class func scaleX(withDuration duration: TimeInterval = TimeInterval(1.0),
                                   to: CGFloat,
                                   timingFunction tf: ECustomTimingFunction = ECustomTimingFunction.linear) -> CABasicAnimation {
        return self.animate(keyPath: AnimationKeyPath.scaleX,
                            fromValue: nil,
                            toValue: to.asTypedValue,
                            duration: duration,
                            timingFunction: tf)

    }

    final public class func scaleY(withDuration duration: TimeInterval = TimeInterval(1.0),
                                   to: CGFloat,
                                   timingFunction tf: ECustomTimingFunction = ECustomTimingFunction.linear) -> CABasicAnimation {
        return self.animate(keyPath: AnimationKeyPath.scaleY,
                            fromValue: nil,
                            toValue: to.asTypedValue,
                            duration: duration,
                            timingFunction: tf)

    }

}

//MARK: fade in/out

public extension AnimationsFactory {

    final public class func fade(withDuration duration: TimeInterval = TimeInterval(1.0),
                                 fromOpacity from: CGFloat?,
                                 toOpacity to: CGFloat?,
                                 timingFunction tf: ECustomTimingFunction = ECustomTimingFunction.linear) -> CABasicAnimation {
        return self.animate(keyPath: AnimationKeyPath.opacity,
                            fromValue: from?.asTypedValue,
                            toValue: to?.asTypedValue,
                            duration: duration,
                            timingFunction: tf)
    }

    final public class func fadeOut(duration: TimeInterval = TimeInterval(1.0),
                                    timinFunction: ECustomTimingFunction = ECustomTimingFunction.linear) -> CABasicAnimation {
        return self.fade(withDuration: duration,
                         fromOpacity: 1.0,
                         toOpacity: 0.0,
                         timingFunction: timinFunction)
    }

    final public class func fadeIn(duration: TimeInterval = TimeInterval(1.0),
                                   timingFunction tf: ECustomTimingFunction = ECustomTimingFunction.linear) -> CABasicAnimation {
        return self.fade(withDuration: duration,
                         fromOpacity: 0.0,
                         toOpacity: 1.0,
                         timingFunction: tf)
    }

}

public extension AnimationsFactory {

    final public class func fadeIn(name: String = "fadeIn",
                                   setsModelValues: Bool = false,
                                   duration: TimeInterval = TimeInterval(1.0),
                                   forLayer layer: CALayer,
                                   timingFunction tf: ECustomTimingFunction = ECustomTimingFunction.linear) -> TimelineAnimation {
        let timeline = TimelineAnimation()
        timeline.insert(animation: self.fadeIn(duration: duration, timingFunction: tf),
                        forLayer: layer,
                        atTime: RelativeTime(0),
                        withDuration: duration)
        timeline.setsModelValues = setsModelValues
        timeline.name = name
        return timeline
    }

    final public class func fadeOut(name: String = "fadeOut",
                                    duration: TimeInterval = TimeInterval(1.0),
                                    setsModelValues: Bool = false,
                                    forLayer layer: CALayer,
                                    timingFunction tf: ECustomTimingFunction = ECustomTimingFunction.linear) -> TimelineAnimation {
        let timeline = TimelineAnimation()
        timeline.insert(animation: self.fadeOut(duration: duration, timinFunction: tf),
                        forLayer: layer,
                        atTime: RelativeTime(0),
                        withDuration: duration)
        timeline.setsModelValues = setsModelValues
        timeline.name = name
        return timeline
    }
}

public extension AnimationsFactory {

    final public class func shake(aroundCenter center: CGPoint,
                                  deviation: CGFloat,
                                  movements: Int = 3) -> CAPropertyAnimation {
        func position(center: CGPoint, deviation: CGFloat) -> (start: CGPoint, end: CGPoint) {
            let xSign: CGFloat = arc4random_uniform(2) == 0 ? -1 : 1
            let ySign: CGFloat = arc4random_uniform(2) == 0 ? -1 : 1
            let x = CGFloat(arc4random_uniform(UInt32(deviation))) + (deviation / 2.0) * xSign //sign
            let y = CGFloat(arc4random_uniform(UInt32(deviation))) + (deviation / 2.0) * ySign
            let start = center
            let end = start.applying(CGAffineTransform(translationX: x, y: y))
            return (start: start, end: end)
        }
        
        let positions = position(center: center, deviation: deviation)
        
        let shakeAnimation = AnimationsFactory.move(fromPoint: positions.start,
                                                    toPoint: positions.end)
        shakeAnimation.repeatCount = Float(movements)
        shakeAnimation.autoreverses = true
        return shakeAnimation
    }
}


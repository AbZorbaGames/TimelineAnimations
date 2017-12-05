//
//  TimelineAnimationTypedExtension.swift
//  TimelineAnimations
//
//  Created by Georges Boumis on 11/01/2017.
//  Copyright © 2017 AbZorba Games. All rights reserved.
//

import Foundation
import QuartzCore

fileprivate extension Optional {
    
    fileprivate func unwrap(defaultValue value: Wrapped) -> Wrapped {
        if let v = self {
            return v
        }
        else {
            return value
        }
    }
}

public extension TimelineAnimation {
    public typealias Radians = Double
    
    public enum Transition {
        public enum Subtype {
            case fromRight
            case fromLeft
            case fromTop
            case fromBottom
            
            internal var value: String {
                switch self {
                case TimelineAnimation.Transition.Subtype.fromRight:
                    return kCATransitionFromRight
                case TimelineAnimation.Transition.Subtype.fromLeft:
                    return kCATransitionFromLeft
                case TimelineAnimation.Transition.Subtype.fromTop:
                    return kCATransitionFromTop
                case TimelineAnimation.Transition.Subtype.fromBottom:
                    return kCATransitionFromBottom
                }
            }
        }
        case fade
        case moveIn(subtype: TimelineAnimation.Transition.Subtype)
        case push(subtype: TimelineAnimation.Transition.Subtype)
        case reveal(subtype: TimelineAnimation.Transition.Subtype)
        
        var transition: CATransition {
            let transition = CATransition()
            switch self {
            case TimelineAnimation.Transition.fade:
                transition.type = kCATransitionFade
            case let TimelineAnimation.Transition.moveIn(subtype):
                transition.type = kCATransitionMoveIn
                transition.subtype = subtype.value
            case let TimelineAnimation.Transition.push(subtype):
                transition.type = kCATransitionPush
                transition.subtype = subtype.value
            case let TimelineAnimation.Transition.reveal(subtype):
                transition.type = kCATransitionReveal
                transition.subtype = subtype.value
            }
            return transition
        }
    }
}

public extension TimelineAnimation {
    
    public enum TimingFunction: UInt {
        case Default = 0
        case linear
        case easeIn
        case easeOut
        case easeInOut
        case sineIn
        case sineOut
        case sineInOut
        case quadIn
        case quadOut
        case quadInOut
        case cubicIn
        case cubicOut
        case cubicInOut
        case quartIn
        case quartOut
        case quartInOut
        case quintIn
        case quintOut
        case quintInOut
        case expoIn
        case expoOut
        case expoInOut
        case circIn
        case circOut
        case circInOut
        case backIn
        case backOut
        case backInOut
        
        public var customTimingFunction: ECustomTimingFunction {
            return ECustomTimingFunction(rawValue: self.rawValue)!
        }
    }
}

public extension TimelineAnimation {
    
    public enum Animation {
        case move(from: CGPoint?, to: CGPoint?, timingFunction: TimelineAnimation.TimingFunction?)
        case fade(from: CGFloat?, to: CGFloat?, timingFunction: TimelineAnimation.TimingFunction?)
        case fadeIn(timingFunction: TimelineAnimation.TimingFunction?)
        case fadeOut(timingFunction: TimelineAnimation.TimingFunction?)
        case hide
        case unhide
        case scale(from: CGFloat?, to: CGFloat?, timingFunction: TimelineAnimation.TimingFunction?)
        case scaleX(from: CGFloat?, to: CGFloat?, timingFunction: TimelineAnimation.TimingFunction?)
        case scaleY(from: CGFloat?, to: CGFloat?, timingFunction: TimelineAnimation.TimingFunction?)
        case rotate(from: TimelineAnimation.Radians?, to: TimelineAnimation.Radians?, timingFunction: TimelineAnimation.TimingFunction?)
        case rotateY(from: TimelineAnimation.Radians?, to: TimelineAnimation.Radians?, timingFunction: TimelineAnimation.TimingFunction?)
        case shadowOpacity(from: CGFloat?, to: CGFloat?, timingFunction: TimelineAnimation.TimingFunction?)
        case strokeStart(from: CGFloat?, to: CGFloat?, timingFunction: TimelineAnimation.TimingFunction?)
        case strokeEnd(from: CGFloat?, to: CGFloat?, timingFunction: TimelineAnimation.TimingFunction?)
        case transform(from: CATransform3D?, to: CATransform3D?, timingFunction: TimelineAnimation.TimingFunction?)
        case custom(apply: () -> CAPropertyAnimation)
    }
}

public extension TimelineAnimation.Animation {
    
    public var animation: CAPropertyAnimation {
        var anim: CAPropertyAnimation!
        switch self {
        case let TimelineAnimation.Animation.move(from, to, tf):
            anim = AnimationsFactory.move(fromPoint: from,
                                          toPoint: to,
                                          timingFunction: tf.unwrap(defaultValue: TimelineAnimation.TimingFunction.linear).customTimingFunction)
            
        case let TimelineAnimation.Animation.fade(from, to, tf):
            anim = AnimationsFactory.fade(fromOpacity: from,
                                          toOpacity: to,
                                          timingFunction: tf.unwrap(defaultValue: TimelineAnimation.TimingFunction.linear).customTimingFunction)
            
        case let TimelineAnimation.Animation.fadeIn(tf):
            anim = AnimationsFactory.fadeIn(timingFunction: tf.unwrap(defaultValue: TimelineAnimation.TimingFunction.linear).customTimingFunction)
            
        case let TimelineAnimation.Animation.fadeOut(tf):
            anim = AnimationsFactory.fadeOut(timinFunction: tf.unwrap(defaultValue: TimelineAnimation.TimingFunction.linear).customTimingFunction)
            
        case let TimelineAnimation.Animation.scale(from, to, tf):
            anim = AnimationsFactory.scale(from: from,
                                           to: to,
                                           timingFunction: tf.unwrap(defaultValue: TimelineAnimation.TimingFunction.linear).customTimingFunction)
            
        case let TimelineAnimation.Animation.scaleX(from, to, tf):
            anim = AnimationsFactory.scaleX(from: from,
                                            to: to,
                                            timingFunction: tf.unwrap(defaultValue: TimelineAnimation.TimingFunction.linear).customTimingFunction)
            
        case let TimelineAnimation.Animation.scaleY(from, to, tf):
            anim = AnimationsFactory.scaleY(from: from,
                                            to: to,
                                            timingFunction: tf.unwrap(defaultValue: TimelineAnimation.TimingFunction.linear).customTimingFunction)
            
        case let TimelineAnimation.Animation.rotate(from, to, tf):
            let _from = (from == nil) ? nil : CGFloat(from!)
            let _to = (to == nil) ? nil : CGFloat(to!)
            anim = AnimationsFactory.animate(keyPath: AnimationKeyPath.rotation,
                                             fromValue: _from.asTypedValue,
                                             toValue: _to.asTypedValue,
                                             timingFunction: tf.unwrap(defaultValue: TimelineAnimation.TimingFunction.linear).customTimingFunction)
            
        case let TimelineAnimation.Animation.rotateY(from, to, tf):
            let _from = (from == nil) ? nil : CGFloat(from!)
            let _to = (to == nil) ? nil : CGFloat(to!)
            anim = AnimationsFactory.animate(keyPath: AnimationKeyPath.rotationY,
                                             fromValue: _from.asTypedValue,
                                             toValue: _to.asTypedValue,
                                             timingFunction: tf.unwrap(defaultValue: TimelineAnimation.TimingFunction.linear).customTimingFunction)
            
        case let TimelineAnimation.Animation.transform(from, to, tf):
            anim = AnimationsFactory.animate(keyPath: AnimationKeyPath.transform,
                                             fromValue: from.asTypedValue,
                                             toValue: to.asTypedValue,
                                             timingFunction: tf.unwrap(defaultValue: TimelineAnimation.TimingFunction.linear).customTimingFunction)
            
        case TimelineAnimation.Animation.hide:
            anim = AnimationsFactory.animate(keyPath: AnimationKeyPath.isHidden,
                                             fromValue: false.asTypedValue,
                                             toValue: true.asTypedValue,
                                             timingFunction: TimelineAnimation.TimingFunction.linear.customTimingFunction)
            
        case TimelineAnimation.Animation.unhide:
            anim = AnimationsFactory.animate(keyPath: AnimationKeyPath.isHidden,
                                             fromValue: true.asTypedValue,
                                             toValue: false.asTypedValue,
                                             timingFunction: TimelineAnimation.TimingFunction.linear.customTimingFunction)
            
        case let TimelineAnimation.Animation.shadowOpacity(from, to, tf):
            anim = AnimationsFactory.animate(keyPath: AnimationKeyPath.shadowOpacity,
                                             fromValue: from.asTypedValue,
                                             toValue: to.asTypedValue,
                                             timingFunction: tf.unwrap(defaultValue: TimelineAnimation.TimingFunction.linear).customTimingFunction)
            
        case let TimelineAnimation.Animation.strokeStart(from, to, tf):
            anim = AnimationsFactory.animate(keyPath: AnimationKeyPath.strokeStart,
                                             fromValue: from.asTypedValue,
                                             toValue: to.asTypedValue,
                                             timingFunction: tf.unwrap(defaultValue: TimelineAnimation.TimingFunction.linear).customTimingFunction)
            
        case let TimelineAnimation.Animation.strokeEnd(from, to, tf):
            anim = AnimationsFactory.animate(keyPath: AnimationKeyPath.strokeEnd,
                                             fromValue: from.asTypedValue,
                                             toValue: to.asTypedValue,
                                             timingFunction: tf.unwrap(defaultValue: TimelineAnimation.TimingFunction.linear).customTimingFunction)
            
            
        case let TimelineAnimation.Animation.custom(application):
            anim = application()
        }
        return anim
    }
}

public extension TimelineAnimation {
    
    /// Inserts an animation in the TimelineAnimation for the provided layer at the given time.
    ///
    /// - Parameter animation: a `TimelineAnimation.Animation` to be applied to the layer
    /// - Parameter layer: the layer whose property is to be animated in the TimelineAnimation
    /// - Parameter time: the time, in the TimelineAnimation's relative time (seconds), to insert the animation. If not provided equals to 0.
    /// - Parameter duration: the duration this animation has. If not provided equals to 1.
    /// - Parameter onStart: an optional block to be called on the beginning of the animation
    /// - Parameter onComplete: an optional block to be called when the animation completes
    ///
    /// - Precondition: the animation is not `nil`.
    /// - Precondition: the layer is not `nil`.
    /// - Precondition: the timeline has not started.
    /// - Throws: 
    /// `NSInvalidArgumentException` if either `layer` on `animation` are `nil`.
    /// `ImmutableTimelineAnimationException` if called on an ongoing timeline.
    /// `TimelineAnimationConflictingAnimationsException` if the animation is conflicting with existing animations in the timeline.
    ///
    public func insert(animation: TimelineAnimation.Animation,
                       forLayer layer: CALayer,
                       atTime time: RelativeTime = RelativeTime(0.0),
                       withDuration duration: TimeInterval = TimeInterval(1.0),
                       onStart: TimelineAnimation.VoidBlock? = nil,
                       onComplete: TimelineAnimation.BoolBlock? = nil) {
        self.insert(animation: animation.animation,
                    forLayer: layer,
                    atTime: time,
                    withDuration: duration,
                    onStart: onStart,
                    onComplete: onComplete)
    }
}

public extension TimelineAnimation {
    
    /// Appends an animation at the end of the timeline, after a delay
    ///
    /// - Parameter animation: a `TimelineAnimation.Animation` to be applied to the layer
    /// - Parameter layer: the layer whose property is to be animated in the TimelineAnimation
    /// - Parameter duration: the duration this animation has. If not provided equals to 1.
    /// - Parameter delay: the delay, must be >= 0.0, in seconds. If not provided equals to 0.0
    /// - Parameter onStart: an optional block to be called on the beginning of the animation
    /// - Parameter onComplete: an optional block to be called when the animation completes
    ///
    /// - Precondition: the `animation` is not `nil`.
    /// - Precondition: the `layer` is not `nil`.
    /// - Precondition: the `timeline` has not started.
    /// - Throws:
    /// `NSInvalidArgumentException` if either `layer` on `animation` are `nil`.
    /// `ImmutableTimelineAnimationException` if called on an ongoing timeline.
    /// `TimelineAnimationConflictingAnimationsException` if the animation is conflicting with existing animations in the timeline.
    ///
    public func add(animation: TimelineAnimation.Animation,
                    forLayer layer: CALayer,
                    withDuration duration: TimeInterval = TimeInterval(1.0),
                    withDelay delay: RelativeTime = RelativeTime(0.0),
                    onStart: TimelineAnimation.VoidBlock? = nil,
                    onComplete: TimelineAnimation.BoolBlock? = nil) {
        self.add(animation: animation.animation,
                 forLayer: layer,
                 withDelay: delay,
                 withDuration: duration,
                 onStart: onStart,
                 onComplete: onComplete)
    }
}


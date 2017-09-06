//
//  Animations.swift
//  TimelineAnimations
//
//  Created by Georges Boumis on 19/04/2017.
//  Copyright © 2017 AbZorba Games. All rights reserved.
//

import Foundation

final public class Animations {}


extension Animations {
    
    final public class func show(_ view: UIView,
                                 withDuration duration: TimeInterval = 1.0,
                                 timingFunction tf: TimelineAnimation.TimingFunction = .linear,
                                 transition: TimelineAnimation.Transition? = nil) -> TimelineAnimation {
        let timeline = TimelineAnimation()
        timeline.name = String(describing: type(of: view)) + ".show"
        
        timeline.onStart = { [weak view] in
            guard let sview = view else { return }
            sview.isHidden = false
            sview.alpha = 1.0
        }
        
        timeline.insert(animation: .fadeIn(timingFunction: tf),
                        forLayer: view.layer,
                        withDuration: duration)
        timeline.insert(animation: .unhide,
                        forLayer: view.layer,
                        withDuration: TimelineAnimationMillisecond)
        
        return timeline
    }
}

extension Animations {
    
    final public class func hide(_ view: UIView,
                                 withDuration duration: TimeInterval = 1.0,
                                 timingFunction tf: TimelineAnimation.TimingFunction = .linear,
                                 transition tr: TimelineAnimation.Transition? = nil) -> TimelineAnimation {
        
        
        let timeline = TimelineAnimation()
        timeline.name = String(describing: type(of: view)) + ".hide"
        
        timeline.onStart = { [weak view] in
            guard let sview = view else { return }
            sview.alpha = 0.0
        }
        timeline.completion = { [weak view] _ in
            guard let sview = view else { return }
            sview.isHidden = true
        }
        
        timeline.insert(animation: .fadeOut(timingFunction: tf),
                        forLayer: view.layer,
                        withDuration: duration)
        
        timeline.insert(animation: .hide,
                        forLayer: view.layer,
                        atTime: duration-TimelineAnimationMillisecond,
                        withDuration: TimelineAnimationMillisecond)
        
        return timeline
    }
}

extension Animations {
    
    final public class func move(_ view: UIView,
                                 from: CGPoint? = nil,
                                 to: CGPoint,
                                 withDuration duration: TimeInterval = 1.0,
                                 timingFunction tf: TimelineAnimation.TimingFunction = .linear) -> TimelineAnimation {
        let _from = from ?? view.center
        let timeline = self.animate(view,
                                    keyPath: AnimationKeyPath.position,
                                    from: _from,
                                    to: to,
                                    withDuration: duration,
                                    timingFunction: tf)
        timeline.append(name: ".move")
        return timeline
    }
}

extension Animations {
    
    final public class func scale(_ view: UIView,
                                  from: CGFloat,
                                  to: CGFloat,
                                  withDuration duration: TimeInterval = 1.0,
                                  timingFunction tf: TimelineAnimation.TimingFunction = .linear) -> TimelineAnimation {
        let timeline = self.animate(view,
                                    keyPath: AnimationKeyPath.scale,
                                    from: from,
                                    to: to,
                                    withDuration: duration,
                                    timingFunction: tf)
        timeline.append(name: ".scale")
        return timeline
    }
    
    final public class func scaleX(_ view: UIView,
                                   from: CGFloat,
                                   to: CGFloat,
                                   withDuration duration: TimeInterval = 1.0,
                                   timingFunction tf: TimelineAnimation.TimingFunction = .linear) -> TimelineAnimation {
        let timeline = self.animate(view,
                                    keyPath: AnimationKeyPath.scaleX,
                                    from: from,
                                    to: to,
                                    withDuration: duration,
                                    timingFunction: tf)
        timeline.append(name: ".scaleX")
        return timeline
    }
    
    final public class func scaleY(_ view: UIView,
                                   from: CGFloat,
                                   to: CGFloat,
                                   withDuration duration: TimeInterval = 1.0,
                                   timingFunction tf: TimelineAnimation.TimingFunction = .linear) -> TimelineAnimation {
        let timeline = self.animate(view,
                                    keyPath: AnimationKeyPath.scaleY,
                                    from: from,
                                    to: to,
                                    withDuration: duration,
                                    timingFunction: tf)
        timeline.append(name: ".scaleY")
        return timeline
    }
}


extension Animations {
    
    final public class func rotate(_ view: UIView,
                                   from: TimelineAnimation.Radians,
                                   to: TimelineAnimation.Radians,
                                   withDuration duration: TimeInterval = 1.0,
                                   timingFunction tf: TimelineAnimation.TimingFunction = .linear) -> TimelineAnimation {
        let timeline = self.animate(view,
                                    keyPath: AnimationKeyPath.rotation,
                                    from: from,
                                    to: to,
                                    withDuration: duration,
                                    timingFunction: tf)
        timeline.append(name: ".rotate")
        return timeline
    }
    
}


extension Animations {
    
    public enum BlinkOptions {
        case toVisible(Int)
        case toInvisible(Int)
        
        public var extract: Int {
            switch self {
            case .toVisible(let t):
                return t * 2
            case .toInvisible(let t):
                return t * 2 + 1
            }
        }
        
        public var isFinallyVisible: Bool {
            switch self {
            case .toVisible:
                return true
            default:
                return false
            }
        }
    }
    
    final public class func blink(_ view: UIView,
                                  times t: BlinkOptions,
                                  withDuration duration: TimeInterval = 1.0) -> TimelineAnimation {
        let times = t.extract
        let keyPath = AnimationKeyPath.opacity
        
        let noFunction = CAMediaTimingFunction(controlPoints: 0.0, 0.0, 0.0, 5.0)
        
        let range = (0...times)
        let part = 1.0/Float(times)
        var keyTimes = range.map { Float($0).multiplied(by: part) }.map { RelativeTime($0) } // creates an array [0, ...(part * times - (2 or 1))..., 1]
        keyTimes[keyTimes.endIndex-1] = 1
        
        var i = 0
        let even: () -> CGFloat = {
            i += 1
            if i % 2 == 0 {
                return CGFloat(0)
            }
            return CGFloat(1)
        }
        let _v = range.map { _ in even() } // an array [1, 0, 1, 0, ... (1 or 0 depending on BlinkOptions)]
        let values = AnimationsFactory.convertToTypedValues(_v)
        
        let anim = AnimationsFactory.keyframeAnimation(keyPath: keyPath,
                                                       values: values,
                                                       keyTimes: keyTimes,
                                                       duration: duration)
        let timingFunctions = range.map { _ in noFunction }
        anim.timingFunctions = timingFunctions
        
        
        let timeline = TimelineAnimation()
        timeline.name = String(describing: type(of: view)) + "." + keyPath.rawValue + "[from<1>,to<\(t.isFinallyVisible ? 1 : 0)>]"
        timeline.onStart = { [weak view] in
            guard let sview = view else { return }
            sview.alpha = _v.last!
        }
        timeline.insert(animation: anim.customAnimation, forLayer: view.layer)
        return timeline.timeline(withDuration: duration)
    }
    
}

extension Animations {
    
    final fileprivate class func animate<Value>(
        _ view: UIView,
        keyPath: AnimationKeyPath,
        from: Value, to: Value,
        withDuration duration: TimeInterval = 1.0,
        timingFunction tf: TimelineAnimation.TimingFunction = .linear) -> TimelineAnimation
        where Value: TypedValueConvertible {
            
            let timeline = TimelineAnimation()
            timeline.name = String(describing: type(of: view)) + "." + keyPath.rawValue + "[from<\(from)>,to<\(to)>]"
            
            
            timeline.onStart = { [weak view] in
                guard let sview = view else { return }
                let rawKeyPath = keyPath.rawValue
                let value = to.asTypedValue.value
                
                sview.layer.setValue(value, forKeyPath: rawKeyPath)
            }
            
            let anim = AnimationsFactory.animate(keyPath: keyPath,
                                                 fromValue: from.asTypedValue,
                                                 toValue: to.asTypedValue,
                                                 duration: duration,
                                                 timingFunction: tf.customTimingFunction)
            timeline.insert(animation: anim, forLayer: view.layer)
            
            return timeline
    }
}


extension Animations {
    
    final public class func oscillate<Value>(_ view: UIView,
                                      keyPath: AnimationKeyPath,
                                      percentages: (in: RelativeTime, out: RelativeTime),
                                      values: (from: Value, to: Value),
                                      withDuration duration: TimeInterval = 1.0,
                                      timingFunctions tf: (from: TimelineAnimation.TimingFunction, to: TimelineAnimation.TimingFunction) = (.linear, .linear)) -> TimelineAnimation
        where Value: TypedValueConvertible {
            
            let timeline = TimelineAnimation()
            timeline.name = String(describing: type(of: self)) + ".oscillate<" + keyPath.rawValue + ">"
            
            let _in = percentages.in
            let _out = percentages.out
            let keyTimes = [0.0, _in, _out, 1.0].map { RelativeTime($0) } as [RelativeTime]
            let values = AnimationsFactory.convertToTypedValues([values.from, values.to, values.to, values.from])
            
            let anim = AnimationsFactory.keyframeAnimation(keyPath: keyPath,
                                                           values: values,
                                                           keyTimes: keyTimes,
                                                           duration: duration)
            let timingFunctions = [tf.from, TimelineAnimation.TimingFunction.linear, tf.to].map { EasingTimingHandler.function(withType: $0.customTimingFunction)! }
            anim.timingFunctions = timingFunctions
            timeline.insert(animation: anim, forLayer: view.layer)
            
            return timeline
            
    }
}


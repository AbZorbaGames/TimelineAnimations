//
//  TimelineAnimationUIViewExtensions.swift
//  TimelineAnimations
//
//  Created by Georges Boumis on 19/04/2017.
//  Copyright © 2017 AbZorba Games. All rights reserved.
//

import Foundation

public extension UIView {
    
    final public func moveAnimation(from: CGPoint?,
                                    to: CGPoint,
                                    timingFunction tf: TimelineAnimation.TimingFunction = .linear) -> TimelineAnimation {
        return Animations.move(self, from: from, to: to, timingFunction: tf)
    }
    
    final public func scaleAnimation(from: CGFloat,
                                     to: CGFloat,
                                     timingFunction tf: TimelineAnimation.TimingFunction = .linear) -> TimelineAnimation {
        return Animations.scale(self, from: from, to: to, timingFunction: tf)
    }
    
    
    final public func scaleXAnimation(from: CGFloat,
                                     to: CGFloat,
                                     timingFunction tf: TimelineAnimation.TimingFunction = .linear) -> TimelineAnimation {
        return Animations.scaleX(self, from: from, to: to, timingFunction: tf)
    }
    
    final public func scaleYAnimation(from: CGFloat,
                                     to: CGFloat,
                                     timingFunction tf: TimelineAnimation.TimingFunction = .linear) -> TimelineAnimation {
        return Animations.scaleY(self, from: from, to: to, timingFunction: tf)
    }
    
    final public func rotateAnimation(from: TimelineAnimation.Radians,
                                     to: TimelineAnimation.Radians,
                                     timingFunction tf: TimelineAnimation.TimingFunction = .linear) -> TimelineAnimation {
        return Animations.rotate(self, from: from, to: to, timingFunction: tf)
    }
    
    final public func showAnimation(timingFunction tf: TimelineAnimation.TimingFunction = .linear) -> TimelineAnimation {
        return Animations.show(self, timingFunction: tf)
    }
    
    final public func hideAnimation(timingFunction tf: TimelineAnimation.TimingFunction = .linear) -> TimelineAnimation {
        return Animations.hide(self, timingFunction: tf)
    }
    
    final public func blinkAnimation(options: Animations.BlinkOptions) -> TimelineAnimation {
        return Animations.blink(self, times: options)
    }
    
    
    public typealias PopPhase = (percentage: RelativeTime, tf: TimelineAnimation.TimingFunction)
    public typealias PopOptions = (in: UIView.PopPhase, out: UIView.PopPhase)
    
    final public func popAnimation(withOptions options: PopOptions) -> TimelineAnimation {
        
        let timeline = Animations.oscillate(self, keyPath: AnimationKeyPath.opacity,
                                            percentages: (options.in.percentage, options.out.percentage),
                                            values: (from: 0, to: 1),
                                            timingFunctions: (from: options.in.tf, to: options.out.tf))
        timeline.append(name: ".pop")
        return timeline
    }
    
    final public func scalingPopAnimation(from: CGFloat,
                                          to: CGFloat,
                                          options: UIView.PopOptions = (in: (percentage: RelativeTime(0.4), tf: TimelineAnimation.TimingFunction.linear),
                                                                        out: (percentage: RelativeTime(0.6), tf: TimelineAnimation.TimingFunction.linear))) -> TimelineAnimation {

        let group = GroupTimelineAnimation()
        group.append(name: String(describing: type(of: self)) + ".scalingPopAnimation")
        let opacity = Animations.oscillate(self, keyPath: AnimationKeyPath.opacity,
                                            percentages: (options.in.percentage, options.out.percentage),
                                            values: (from: 0, to: 1),
                                            timingFunctions: (from: options.in.tf, to: options.out.tf))
        opacity.append(name: ".scalingPop")
        group.add(opacity)
        
        let scale = Animations.oscillate(self, keyPath: AnimationKeyPath.scale,
                                           percentages: (options.in.percentage, options.out.percentage),
                                           values: (from: from, to: to),
                                           timingFunctions: (from: options.in.tf, to: options.out.tf))
        scale.append(name: ".scalingPop")
        group.add(scale)
        return group
    }
    
    final public func scalingBounceAnimation(from: CGFloat,
                                             to: CGFloat,
                                             options: UIView.PopOptions = (in: (percentage: RelativeTime(0.4), tf: TimelineAnimation.TimingFunction.linear),
                                                                           out: (percentage: RelativeTime(0.6), tf: TimelineAnimation.TimingFunction.linear))) -> TimelineAnimation {
        
        let scale = Animations.oscillate(self, keyPath: AnimationKeyPath.scale,
                                         percentages: (options.in.percentage, options.out.percentage),
                                         values: (from: from, to: to),
                                         timingFunctions: (from: options.in.tf, to: options.out.tf))
        scale.append(name: ".scalingBounce")
        return scale
    }
}

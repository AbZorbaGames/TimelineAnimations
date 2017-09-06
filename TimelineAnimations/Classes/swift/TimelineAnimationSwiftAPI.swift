//
//  TimelineAnimationConvenienceExtension.swift
//  TimelineAnimations
//
//  Created by Georges Boumis on 11/01/2017.
//  Copyright © 2017 AbZorba Games. All rights reserved.
//

import Foundation

public extension TimelineAnimation {
 
    final internal func insert(animation: CAPropertyAnimation,
                               forLayer layer: CALayer,
                               atTime time: RelativeTime = RelativeTime(0.0),
                               withDuration duration: TimeInterval = TimeInterval(1.0),
                               onStart: TimelineAnimation.VoidBlock? = nil,
                               onComplete: TimelineAnimation.BoolBlock? = nil) {
        
        let anim = animation.copy() as! CAPropertyAnimation
        anim.duration = duration
        
        self.__insert(anim,
                      for: layer,
                      atTime: time,
                      onStart: onStart,
                      onComplete: onComplete)
    }
    
    final internal func add(animation: CAPropertyAnimation,
                            forLayer layer: CALayer,
                            withDelay delay: RelativeTime = RelativeTime(0.0),
                            withDuration duration: TimeInterval = TimeInterval(1.0),
                            onStart: TimelineAnimation.VoidBlock? = nil,
                            onComplete: TimelineAnimation.BoolBlock? = nil) {
        
        let anim = animation.copy() as! CAPropertyAnimation
        anim.duration = duration
        
        self.__add(anim,
                   for: layer,
                   withDelay: delay,
                   onStart: onStart,
                   onComplete: onComplete)
    }
}

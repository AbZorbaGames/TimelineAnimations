//
//  CAPropertyAnimationExtensions.swift
//  TimelineAnimations
//
//  Created by Georges Boumis on 16/02/2017.
//  Copyright © 2017 AbZorba Games. All rights reserved.
//

import Foundation

public extension CAPropertyAnimation {
    
    public convenience init(keyPath path: AnimationKeyPath) {
        self.init(keyPath: path.rawValue)
    }
}

public extension CAPropertyAnimation {
    
    public var customAnimation: TimelineAnimation.Animation {
        return  TimelineAnimation.Animation.custom(apply: { () -> CAPropertyAnimation in
            return self
        })
    }
}

//
//  TypesRefinements.swift
//  TimelineAnimations
//
//  Created by Georges Boumis on 27/03/2017.
//  Copyright © 2017 AbZorba Games. All rights reserved.
//

import Foundation

public extension TimelineAnimation {
    public typealias VoidBlock = () -> Void
    public typealias BoolBlock = (Bool) -> Void
    public typealias NotificationBlock = TimelineAnimation.VoidBlock
    
    final public func notify(atTime time: RelativeTime,
                             using block: @escaping TimelineAnimation.NotificationBlock) {
        self.__notify(atTime: time, using: block)
    }
    
    final public func notify(atProgress progress: Float,
                             using block: @escaping TimelineAnimation.NotificationBlock) {
        self.__notify(atProgress: progress, using: block)
    }
}

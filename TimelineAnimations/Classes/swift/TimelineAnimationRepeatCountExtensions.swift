//
//  TimelineAnimationRepeatCountExtensions.swift
//  TimelineAnimations
//
//  Created by Georges Boumis on 27/03/2017.
//  Copyright © 2017 AbZorba Games. All rights reserved.
//

import Foundation

public extension TimelineAnimation {
    
    /// The repeat count of a TimelineAnimation
    public enum RepeatCount {
        /// the time to repeat the timeline
        /// - Note: a `repeatCount` of `1` is equivalent to calling `-play`.
        case times(UInt64)
        /// an infinite repeatition
        case infinite
    }
    
    
    /// The number of repeats to perform
    /// - Note: A `repeatCount` of `1` is equivalent to calling `-play`.
    final public var repeatCount: TimelineAnimation.RepeatCount {
        get {
            let count = self.__repeatCount
            if count == __TimelineAnimationRepeatCountInfinite {
                return TimelineAnimation.RepeatCount.infinite
            }
            return TimelineAnimation.RepeatCount.times(count)
        }
        set {
            switch newValue {
            case let .times(count):
                self.__repeatCount = count
            case .infinite:
                self.__repeatCount = __TimelineAnimationRepeatCountInfinite;
            }
            
        }
    }
}

public extension TimelineAnimation.RepeatCount {
    
    public init?(_ i: UInt64) {
        guard i >= 1 else { return nil }
        if i == __TimelineAnimationRepeatCountInfinite {
            self = TimelineAnimation.RepeatCount.infinite
        }
        else {
            self = TimelineAnimation.RepeatCount.times(i)
        }
    }
    
    public var isInfinite: Bool {
        switch self {
        case .times:
            return false
        case .infinite:
            return true
        }
    }
}

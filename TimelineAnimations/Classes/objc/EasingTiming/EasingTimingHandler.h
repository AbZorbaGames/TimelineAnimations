//
//  EasingTimingHandler.h
//  TimelineAnimations
//
//  Created by AbZorba Games on 8/12/15.
//  Copyright (c) 2015-2016 Abzorba Games. All rights reserved.
//

@import Foundation;
@import QuartzCore;

typedef NS_ENUM(NSUInteger, ECustomTimingFunction) {
    ECustomTimingFunctionDefault = 0,
    ECustomTimingFunctionLinear,
    ECustomTimingFunctionEaseIn,
    ECustomTimingFunctionEaseOut,
    ECustomTimingFunctionEaseInOut,
    ECustomTimingFunctionSineIn,
    ECustomTimingFunctionSineOut,
    ECustomTimingFunctionSineInOut,
    ECustomTimingFunctionQuadIn,
    ECustomTimingFunctionQuadOut,
    ECustomTimingFunctionQuadInOut,
    ECustomTimingFunctionCubicIn,
    ECustomTimingFunctionCubicOut,
    ECustomTimingFunctionCubicInOut,
    ECustomTimingFunctionQuartIn,
    ECustomTimingFunctionQuartOut,
    ECustomTimingFunctionQuartInOut,
    ECustomTimingFunctionQuintIn,
    ECustomTimingFunctionQuintOut,
    ECustomTimingFunctionQuintInOut,
    ECustomTimingFunctionExpoIn,
    ECustomTimingFunctionExpoOut,
    ECustomTimingFunctionExpoInOut,
    ECustomTimingFunctionCircIn,
    ECustomTimingFunctionCircOut,
    ECustomTimingFunctionCircInOut,
    ECustomTimingFunctionBackIn,
    ECustomTimingFunctionBackOut,
    ECustomTimingFunctionBackInOut,
    
    // special
    ECustomTimingFunctionElasticIn,
    ECustomTimingFunctionElasticOut,
    ECustomTimingFunctionElasticInOut,
    ECustomTimingFunctionBounceIn,
    ECustomTimingFunctionBounceOut,
    ECustomTimingFunctionBounceInOut
};


@interface EasingTimingHandler : NSObject

+(CAMediaTimingFunction *)functionWithType:(ECustomTimingFunction)type NS_SWIFT_NAME(function(withType:));

@end

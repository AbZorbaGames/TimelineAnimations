//
//  EasingTimingHandler.m
//  TimelineAnimations
//
//  Created by Harris Spentzas on 8/12/15.
//  Copyright (c) 2015-2017 Abzorba Games. All rights reserved.
//

#import "EasingTimingHandler.h"

@implementation EasingTimingHandler

+(CAMediaTimingFunction *)functionWithType:(ECustomTimingFunction)type
{
    switch (type) {
        case ECustomTimingFunctionDefault:
            return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];

        case ECustomTimingFunctionLinear:
            return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];


        case ECustomTimingFunctionEaseIn:
            return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];

        case ECustomTimingFunctionEaseOut:
            return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];

        case ECustomTimingFunctionEaseInOut:
            return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];


        case ECustomTimingFunctionSineIn:
            return [CAMediaTimingFunction functionWithControlPoints:(float)0.45 :(float)0 :(float)0.745 :(float)0.715];
            
        case ECustomTimingFunctionSineOut:
            return [CAMediaTimingFunction functionWithControlPoints:(float)0.39 :(float)0.575 :(float)0.565 :(float)1];
           
        case ECustomTimingFunctionSineInOut:
            return [CAMediaTimingFunction functionWithControlPoints:(float)0.445 :(float)0.05 :(float)0.55 :(float)0.95];
            

        case ECustomTimingFunctionQuadIn:
            return [CAMediaTimingFunction functionWithControlPoints:(float)0.55 :(float)0.085 :(float)0.68 :(float)0.53];
            
        case ECustomTimingFunctionQuadOut:
            return [CAMediaTimingFunction functionWithControlPoints:(float)0.25 :(float)0.46 :(float)0.45 :(float)0.94];
            
        case ECustomTimingFunctionQuadInOut:
            return [CAMediaTimingFunction functionWithControlPoints:(float)0.455 :(float)0.03 :(float)0.515 :(float)0.955];
            

        case ECustomTimingFunctionCubicIn:
            return [CAMediaTimingFunction functionWithControlPoints:(float)0.55 :(float)0.055 :(float)0.675 :(float)0.19];
            
        case ECustomTimingFunctionCubicOut:
            return [CAMediaTimingFunction functionWithControlPoints:(float)0.215 :(float)0.61 :(float)0.355 :(float)1];
            
        case ECustomTimingFunctionCubicInOut:
            return [CAMediaTimingFunction functionWithControlPoints:(float)0.645 :(float)0.045 :(float)0.355 :(float)1];
            

        case ECustomTimingFunctionQuartIn:
            return [CAMediaTimingFunction functionWithControlPoints:(float)0.895 :(float)0.03 :(float)0.685 :(float)0.22];
            
        case ECustomTimingFunctionQuartOut:
            return [CAMediaTimingFunction functionWithControlPoints:(float)0.165 :(float)0.84 :(float)0.44 :(float)1];
            
        case ECustomTimingFunctionQuartInOut:
            return [CAMediaTimingFunction functionWithControlPoints:(float)0.77 :(float)0 :(float)0.175 :(float)1];

        case ECustomTimingFunctionQuintIn:
            return [CAMediaTimingFunction functionWithControlPoints:(float)0.755 :(float)0.05 :(float)0.855 :(float)0.06];
            
        case ECustomTimingFunctionQuintOut:
            return [CAMediaTimingFunction functionWithControlPoints:(float)0.23 :(float)1 :(float)0.32 :(float)1];
            
        case ECustomTimingFunctionQuintInOut:
            return [CAMediaTimingFunction functionWithControlPoints:(float)0.86 :(float)0 :(float)0.07 :(float)1];
            

        case ECustomTimingFunctionExpoIn:
            return [CAMediaTimingFunction functionWithControlPoints:(float)0.95 :(float)0.05 :(float)0.795 :(float)0.035];
            
        case ECustomTimingFunctionExpoOut:
            return [CAMediaTimingFunction functionWithControlPoints:(float)0.19 :(float)1 :(float)0.22 :(float)1];
            
        case ECustomTimingFunctionExpoInOut:
            return [CAMediaTimingFunction functionWithControlPoints:(float)1 :(float)0 :(float)0 :(float)1];
            

        case ECustomTimingFunctionCircIn:
            return [CAMediaTimingFunction functionWithControlPoints:(float)0.6 :(float)0.04 :(float)0.98 :(float)0.335];
            
        case ECustomTimingFunctionCircOut:
            return [CAMediaTimingFunction functionWithControlPoints:(float)0.075 :(float)0.82 :(float)0.165 :(float)1];
        case ECustomTimingFunctionCircInOut:
            return [CAMediaTimingFunction functionWithControlPoints:(float)0.785 :(float)0.135 :(float)0.15 :(float)0.86];

        case ECustomTimingFunctionBackIn:
            return [CAMediaTimingFunction functionWithControlPoints:(float)0.6 :(float)-0.28 :(float)0.735 :(float)0.045];
        case ECustomTimingFunctionBackOut:
            return [CAMediaTimingFunction functionWithControlPoints:(float)0.175 :(float)0.885 :(float)0.32 :(float)1.275];
        case ECustomTimingFunctionBackInOut:
            return [CAMediaTimingFunction functionWithControlPoints:(float)0.68 :(float)-0.55 :(float)0.265 :(float)1.55];
        default:
            //            ECustomTimingFunctionElasticIn,
            //            ECustomTimingFunctionElasticOut,
            //            ECustomTimingFunctionElasticInOut,
            //            ECustomTimingFunctionBounceIn,
            //            ECustomTimingFunctionBounceOut,
            //            ECustomTimingFunctionBounceInOut
            NSAssert(false, @"Should not happen.");
            return nil;
    }
}

@end

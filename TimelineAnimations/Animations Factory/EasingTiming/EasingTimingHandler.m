//
//  EasingTimingHandler.m
//  Baccarat
//
//  Created by Harris Spentzas on 8/12/15.
//  Copyright (c) 2015 Abzorba Games. All rights reserved.
//

#import "EasingTimingHandler.h"

@implementation EasingTimingHandler

+(CAMediaTimingFunction *)functionWithType:(ECustomTimingFunction)type
{
    switch (type) {
        case ECustomTimingFunctionDefault:
            return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
            break;
        case ECustomTimingFunctionLinear:
            return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            break;

        case ECustomTimingFunctionEaseIn:
            return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
            break;
        case ECustomTimingFunctionEaseOut:
            return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            break;
        case ECustomTimingFunctionEaseInOut:
            return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            break;

        case ECustomTimingFunctionSineIn:
            return [CAMediaTimingFunction functionWithControlPoints:0.45 :0 :0.745 :0.715];
            break;
        case ECustomTimingFunctionSineOut:
            return [CAMediaTimingFunction functionWithControlPoints:0.39 :0.575 :0.565 :1];
            break;
        case ECustomTimingFunctionSineInOut:
            return [CAMediaTimingFunction functionWithControlPoints:0.445 :0.05 :0.55 :0.95];
            break;

        case ECustomTimingFunctionQuadIn:
            return [CAMediaTimingFunction functionWithControlPoints:0.55 :0.085 :0.68 :0.53];
            break;
        case ECustomTimingFunctionQuadOut:
            return [CAMediaTimingFunction functionWithControlPoints:0.25 :0.46 :0.45 :0.94];
            break;
        case ECustomTimingFunctionQuadInOut:
            return [CAMediaTimingFunction functionWithControlPoints:0.455 :0.03 :0.515 :0.955];
            break;

        case ECustomTimingFunctionCubicIn:
            return [CAMediaTimingFunction functionWithControlPoints:0.55 :0.055 :0.675 :0.19];
            break;
        case ECustomTimingFunctionCubicOut:
            return [CAMediaTimingFunction functionWithControlPoints:0.215 :0.61 :0.355 :1];
            break;
        case ECustomTimingFunctionCubicInOut:
            return [CAMediaTimingFunction functionWithControlPoints:0.645 :0.045 :0.355 :1];
            break;

        case ECustomTimingFunctionQuartIn:
            return [CAMediaTimingFunction functionWithControlPoints:0.895 :0.03 :0.685 :0.22];
            break;
        case ECustomTimingFunctionQuartOut:
            return [CAMediaTimingFunction functionWithControlPoints:0.165 :0.84 :0.44 :1];
            break;
        case ECustomTimingFunctionQuartInOut:
            return [CAMediaTimingFunction functionWithControlPoints:0.77 :0 :0.175 :1];
            break;

        case ECustomTimingFunctionQuintIn:
            return [CAMediaTimingFunction functionWithControlPoints:0.755 :0.05 :0.855 :0.06];
            break;
        case ECustomTimingFunctionQuintOut:
            return [CAMediaTimingFunction functionWithControlPoints:0.23 :1 :0.32 :1];
            break;
        case ECustomTimingFunctionQuintInOut:
            return [CAMediaTimingFunction functionWithControlPoints:0.86 :0 :0.07 :1];
            break;

        case ECustomTimingFunctionExpoIn:
            return [CAMediaTimingFunction functionWithControlPoints:0.95 :0.05 :0.795 :0.035];
            break;
        case ECustomTimingFunctionExpoOut:
            return [CAMediaTimingFunction functionWithControlPoints:0.19 :1 :0.22 :1];
            break;
        case ECustomTimingFunctionExpoInOut:
            return [CAMediaTimingFunction functionWithControlPoints:1 :0 :0 :1];
            break;

        case ECustomTimingFunctionCircIn:
            return [CAMediaTimingFunction functionWithControlPoints:0.6 :0.04 :0.98 :0.335];
            break;
        case ECustomTimingFunctionCircOut:
            return [CAMediaTimingFunction functionWithControlPoints:0.075 :0.82 :0.165 :1];
            break;
        case ECustomTimingFunctionCircInOut:
            return [CAMediaTimingFunction functionWithControlPoints:0.785 :0.135 :0.15 :0.86];
            break;

        case ECustomTimingFunctionBackIn:
            return [CAMediaTimingFunction functionWithControlPoints:0.6 :-0.28 :0.735 :0.045];
            break;
        case ECustomTimingFunctionBackOut:
            return [CAMediaTimingFunction functionWithControlPoints:0.175 :0.885 :0.32 :1.275];
            break;
        case ECustomTimingFunctionBackInOut:
            return [CAMediaTimingFunction functionWithControlPoints:0.68 :-0.55 :0.265 :1.55];
            break;
        default:
            break;
    }
}

@end

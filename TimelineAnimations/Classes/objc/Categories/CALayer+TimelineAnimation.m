/*!
 *  @file UIView+TimelineAnimation.m
 *  @brief TimelineAnimations
 *
 *  Created by @author Georges Boumis
 *  @date 24/08/2016.
 *  @copyright   Copyright © 2016-2017 Abzorba Games. All rights reserved.
 */

#import "CALayer+TimelineAnimation.h"
#import <objc/runtime.h>
#import "TimelineAnimation.h"

@implementation CALayer (TimelineAnimation)
@dynamic timelineAnimation;
- (void)setTimelineAnimation:(__kindof TimelineAnimation *)timelineAnimation {
    objc_setAssociatedObject(self, @selector(timelineAnimation), timelineAnimation, OBJC_ASSOCIATION_ASSIGN);
}

- (__kindof TimelineAnimation *)timelineAnimation {
    return objc_getAssociatedObject(self, @selector(timelineAnimation));
}
@end

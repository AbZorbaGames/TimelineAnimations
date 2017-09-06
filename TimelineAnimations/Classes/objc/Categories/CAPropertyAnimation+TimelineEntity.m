/*!
 *  @file CAPropertyAnimation+TimelineEntity.m
 *  @brief TimelineAnimations
 *
 *  Created by @author Georges Boumis
 *  @date 08/06/2017.
 *  @copyright 2016-2017 AbZorba Games. All rights reserved.
 */

#import "CAPropertyAnimation+TimelineEntity.h"
#import "PrivateTypes.h"

@implementation CAPropertyAnimation (TimelineEntity)

- (BOOL)isSpecial {
    return (self.autoreverses || self.repeatCount > 0.0 || self.repeatDuration > 0.0);
}
            
- (NSTimeInterval)realDuration {
    guard (self.isSpecial) else { return (NSTimeInterval)self.duration; }
    
    NSTimeInterval duration = (NSTimeInterval)(self.duration);
    if (self.repeatCount > 0.0f) {
        duration *= ((NSTimeInterval)self.repeatCount);
    }
    if (self.repeatDuration > 0.0) {
        duration = (NSTimeInterval)self.repeatDuration;
    }
    if (self.autoreverses == YES) {
        duration *= 2.0;
    }
    return duration;
}

- (BOOL)isConsistent {
    if (self.repeatDuration > 0.0 || self.repeatCount > 0.0f) {
        if (self.repeatDuration > 0.0 && self.repeatCount > 0.0f) {
            return NO;
        }
    }
    return YES;
}

@end

/*!
 *  @file CAKeyframeAnimation+Reverse.m
 *  @brief TimelineAnimations
 *
 *  Created by @author Georges Boumis
 *  @date 01/03/2016.
 *  @copyright Copyright © 2016-2017 Abzorba Games. All rights reserved.
 */

#import "CAKeyframeAnimation+Reverse.h"
#import "CAPropertyAnimation+Reverse.h"

@implementation CAKeyframeAnimation (Reverse)
- (instancetype)reversedAnimation {
    CAKeyframeAnimation *reverse = [self copy];
    reverse.values               = self.values.reverseObjectEnumerator.allObjects;
    
    NSMutableArray<NSNumber *> *reversedKeytimes = [NSMutableArray arrayWithCapacity:self.keyTimes.count];
    NSArray<NSNumber *> *timeskey = self.keyTimes.reverseObjectEnumerator.allObjects.mutableCopy;
    for (NSNumber *keytime in timeskey) {
        [reversedKeytimes addObject:@(1.0 - keytime.doubleValue)];
    }
    reverse.keyTimes             = reversedKeytimes.copy;
    return reverse;
}
@end

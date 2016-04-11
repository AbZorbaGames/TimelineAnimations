/*!
 *  @file CAKeyframeAnimation+Reverse.m
 *  @brief TimelineAnimations
 *
 *  Created by @author AbZorba Games
 *  @date 01/03/2016.
 *  @copyright Copyright © 2016 AbZorba Games. All rights reserved.
 */

#import "CAKeyframeAnimation+Reverse.h"
#import "CAPropertyAnimation+Reverse.h"

@implementation CAKeyframeAnimation (Reverse)
- (instancetype)reversedAnimation {
    CAKeyframeAnimation *reverse = [self copy];
    reverse.values               = self.values.reverseObjectEnumerator.allObjects;
    
    NSMutableArray<NSNumber *> *reversedKeytimes = [NSMutableArray arrayWithCapacity:self.keyTimes.count];
    NSArray<NSNumber *> *timeskey = self.keyTimes.reverseObjectEnumerator.allObjects.mutableCopy;
    [timeskey enumerateObjectsUsingBlock:^(NSNumber * _Nonnull keytime, NSUInteger idx, BOOL * _Nonnull stop) {
        [reversedKeytimes addObject:@(1 - keytime.doubleValue)];
    }];
    reverse.keyTimes             = reversedKeytimes.copy;
    return reverse;
}
@end

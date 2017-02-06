/*!
 *  @file CABasicAnimation+Reverse.m
 *  @brief TimelineAnimations
 *
 *  Created by @author AbZorba Games
 *  @date 01/03/2016.
 *  @copyright Copyright © 2016 AbZorba Games. All rights reserved.
 */

#import "CABasicAnimation+Reverse.h"
#import "CAPropertyAnimation+Reverse.h"
#import "AnimationsKeyPath.h"

@implementation CABasicAnimation (Reverse)
- (instancetype)reversedAnimation {
    CABasicAnimation *reverse = [self copy];
    reverse.toValue           = self.fromValue;
    reverse.fromValue         = self.toValue;
    if ([self.keyPath isEqualToString:kAnimationKeyPathScaleX] ||
        [self.keyPath isEqualToString:kAnimationKeyPathScaleY]) {
        reverse.keyPath = kAnimationKeyPathTransform;
    }
    return reverse;


}
@end

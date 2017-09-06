//
//  TimelineAnimationsBlankLayer.m
//  TimelineAnimations
//
//  Created by Georges Boumis on 23/06/2016.
//  Copyright © 2016-2017 AbZorba Games. All rights reserved.
//

#import "TimelineAnimationsBlankLayer.h"
@import UIKit;

@interface TimelineAnimationsBlankLayer ()

@end

@implementation TimelineAnimationsBlankLayer

- (instancetype)initWithLayer:(id)layer
{
    self = [super initWithLayer:layer];
    if (self) {
        if ([layer isKindOfClass:[TimelineAnimationsBlankLayer class]]) {
            __kindof TimelineAnimationsBlankLayer *const otherLayer = (__kindof TimelineAnimationsBlankLayer *)layer;
            _blank = otherLayer.blank;
        }
    }
    return self;
}

- (void)setHidden:(BOOL)hidden { [super setHidden:YES]; }
- (BOOL)isHidden { return YES; }
- (BOOL)isOpaque { return YES; }
- (float)opacity { return 1.0f; }

- (CGRect)frame {
    return CGRectZero;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:CGRectZero];
}

- (CGColorRef)backgroundColor {
    return [UIColor whiteColor].CGColor;
}

+ (BOOL)needsDisplayForKey:(NSString*)key {
    if ([key isEqualToString:self.keyPath]) {
        return YES;
    } else {
        return [super needsDisplayForKey:key];
    }
}

+ (NSString *)keyPath {
    return @"blank";
}
@end

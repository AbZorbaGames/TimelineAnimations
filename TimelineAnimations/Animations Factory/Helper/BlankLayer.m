//
//  BlankLayer.m
//  TimelineAnimations
//
//  Created by Georges Boumis on 23/06/2016.
//  Copyright © 2016 AbZorba Games. All rights reserved.
//

#import "BlankLayer.h"
@import UIKit;

@interface BlankLayer ()

@end

@implementation BlankLayer

- (instancetype)initWithLayer:(id)layer
{
    self = [super initWithLayer:layer];
    if (self) {
        if ([layer isKindOfClass:[BlankLayer class]]) {
            __kindof BlankLayer *otherLayer = (__kindof BlankLayer *)layer;
            _blank = otherLayer.blank;
        }
    }
    return self;
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:YES];
}

- (BOOL)isHidden {
    return YES;
}

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
    if ([key isEqualToString:@"blank"]) {
        return YES;
    } else {
        return [super needsDisplayForKey:key];
    }
}


@end

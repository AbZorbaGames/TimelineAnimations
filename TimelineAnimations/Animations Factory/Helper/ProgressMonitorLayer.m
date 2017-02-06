//
//  ProgressMonitorLayer.m
//  TimelineAnimations
//
//  Created by Georges Boumis on 23/06/2016.
//  Copyright © 2016 AbZorba Games. All rights reserved.
//

#import "ProgressMonitorLayer.h"
@import UIKit;

@implementation ProgressMonitorLayer

- (instancetype)initWithLayer:(id)layer
{
    self = [super initWithLayer:layer];
    if (self) {
        if ([layer isKindOfClass:[ProgressMonitorLayer class]]) {
            __kindof ProgressMonitorLayer *otherLayer = (__kindof ProgressMonitorLayer *)layer;
            _progress = otherLayer.progress;
            _progressBlock = otherLayer.progressBlock;
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

// Override needsDisplayForKey so that we can define progress as being animatable.
+ (BOOL)needsDisplayForKey:(NSString*)key {
    if ([key isEqualToString:@"progress"]) {
        return YES;
    } else {
        return [super needsDisplayForKey:key];
    }
}

- (void)display {
    if (_progressBlock) {
        _progressBlock(((ProgressMonitorLayer *)self.presentationLayer).progress);
    }
}

@end
